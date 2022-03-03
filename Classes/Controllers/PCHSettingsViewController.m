#import "PCHSettingsViewController.h"

static NSString *VERSION = @"1.4.0";

@implementation PCHSettingsViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
	if (@available(iOS 13.0, *)) {
		return self = [super initWithStyle:UITableViewStyleInsetGrouped];
	} else {
		return self = [super initWithStyle:UITableViewStyleGrouped];
	}
}

- (void)loadView {
    [super loadView];

    self.title = @"Peach 🍑";
    self.navigationController.navigationBar.prefersLargeTitles = YES;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeSettings:)];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.pendingPrefs = [NSMutableDictionary new];
    if (@available(iOS 13.0, *)) {
        self.navigationController.presentationController.delegate = self;
    }
}

- (void)closeSettings:(UIBarButtonItem *)sender {
    // Save in preferences
    HBPreferences *prefs = [HBPreferences preferencesForIdentifier:@"dev.redentic.peach"];
    for (NSString *key in [self.pendingPrefs allKeys]) {
        [prefs setBool:[self.pendingPrefs[key] boolValue] forKey:key];
    }
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("dev.redentic.peach/ReloadPrefs"), NULL, NULL, true);
    // Restart or not
    if (sender.tintColor == [UIColor systemRedColor]) {
        [[UIApplication sharedApplication] suspend];
        exit(0);
    } else {
	    [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Adaptive Presentation Controller delegate
- (void)presentationControllerDidDismiss:(UIPresentationController *)controller {
    HBPreferences *prefs = [HBPreferences preferencesForIdentifier:@"dev.redentic.peach"];
    for (NSString *key in [self.pendingPrefs allKeys]) {
        [prefs setBool:[self.pendingPrefs[key] boolValue] forKey:key];
    }
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("dev.redentic.peach/ReloadPrefs"), NULL, NULL, true);
}

#pragma mark - Switch delegate
- (void)key:(NSString *)key didChangeTo:(BOOL)value needingRestart:(BOOL)restart {
    // Save in temporary dictionary
    self.pendingPrefs[key] = [NSNumber numberWithBool:value]; 
    // UIBarButtonItem
    if (restart) {
        HBPreferences *prefs = [HBPreferences preferencesForIdentifier:@"dev.redentic.peach"];
        if ([prefs objectForKey:key]) {
            BOOL needsToClose = [prefs boolForKey:key] != value;
            UIBarButtonItem *item;
            if (needsToClose) {
                item = [[UIBarButtonItem alloc] initWithTitle:@"Close app" style:UIBarButtonItemStyleDone target:self action:@selector(closeSettings:)];
                item.tintColor = [UIColor systemRedColor];
            } else {
	            item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeSettings:)];
            }
            [self.navigationItem setRightBarButtonItem:item animated:YES];
            if (@available(iOS 13.0, *)) {
                self.modalInPresentation = needsToClose;
            }
        }
    }
}

#pragma mark - Table View Delegate
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 1:
			return @"UI Theming";

		case 2:
			return @"Image opener";

		case 3:
			return @"Features";

		case 4:
			return @"Support";

		case 0:
		default:
			return [super tableView:tableView titleForHeaderInSection:section];
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	if (section == [self numberOfSectionsInTableView:tableView] - 1) {
		UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width - self.tableView.separatorInset.left * 2, 100)];
		UILabel *footerLabel = [[UILabel alloc] initWithFrame:footerView.frame];
		footerLabel.text = [NSString stringWithFormat:@"Made with ❤️ by RedenticDev\n\nv%@", VERSION];
		footerLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize] - 1.0];
		footerLabel.textColor = [UIColor grayColor];
		footerLabel.textAlignment = NSTextAlignmentCenter;
        footerLabel.numberOfLines = 0;
		[footerView addSubview:footerLabel];

		return footerView;
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (section == [self numberOfSectionsInTableView:tableView] - 1) {
		return 100;
	}
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = [NSString stringWithFormat:@"s%li-r%li", (long)indexPath.section, (long)indexPath.row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		switch (indexPath.section) {
            case 0: // redentic + enable
                switch (indexPath.row) {
                    case 0:
                        cell = [[PCHLinkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                        [(PCHLinkTableViewCell *)cell twitterCellWithName:@"Redentic" profile:@"RedenticDev"];
                        break;

                    case 1: {
                        cell = [[PCHSwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                        [(PCHSwitchTableViewCell *)cell configureCellWithLabel:@"Enable tweak" defaultValue:YES key:@"enabled" majorSetting:YES];
                        ((PCHSwitchTableViewCell *)cell).delegate = self;
                        break;
                    }

                    default:
                        break;
                }
                break;

            case 1: // ui theming
                cell = [[PCHSwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                ((PCHSwitchTableViewCell *)cell).delegate = self;
                switch (indexPath.row) {
                    case 0:
                        [(PCHSwitchTableViewCell *)cell configureCellWithLabel:@"iOS 13+ dynamic dark mode" defaultValue:YES key:@"enableDarkMode" majorSetting:YES];
                        break;

                    default:
                        break;
                }
                break;

            case 2: // image opener
                cell = [[PCHSwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                ((PCHSwitchTableViewCell *)cell).delegate = self;
                switch (indexPath.row) {
                    case 0:
                        [(PCHSwitchTableViewCell *)cell configureCellWithLabel:@"Long press to open images" defaultValue:YES key:@"enableImageVC" majorSetting:NO];
                        break;

                    case 1:
                        [(PCHSwitchTableViewCell *)cell configureCellWithLabel:@"Haptics when opening images" defaultValue:YES key:@"enableLongPressHaptics" majorSetting:NO];
                        break;

                    case 2:
                        [(PCHSwitchTableViewCell *)cell configureCellWithLabel:@"Ask confirmation for save" defaultValue:NO key:@"askSaveConfirmation" majorSetting:NO];
                        break;

                    default:
                        break;
                }
                break;

            case 3: // features
                cell = [[PCHSwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                ((PCHSwitchTableViewCell *)cell).delegate = self;
                switch (indexPath.row) {
                    case 0:
                        [(PCHSwitchTableViewCell *)cell configureCellWithLabel:@"Images unblurring" defaultValue:YES key:@"enableUnblur" majorSetting:NO];
                        break;

                    case 1:
                        [(PCHSwitchTableViewCell *)cell configureCellWithLabel:@"Haptics on unblur" defaultValue:YES key:@"enableUnblurHaptics" majorSetting:NO];
                        break;

                    case 2:
                        [(PCHSwitchTableViewCell *)cell configureCellWithLabel:@"Haptics on like/pass buttons" defaultValue:YES key:@"enableLikePassHaptics" majorSetting:NO];
                        break;

                    case 3:
                        [(PCHSwitchTableViewCell *)cell configureCellWithLabel:@"Instagram parser" defaultValue:YES key:@"enableParser" majorSetting:NO];
                        break;

                    case 4:
                        [(PCHSwitchTableViewCell *)cell configureCellWithLabel:@"Loading spinners" defaultValue:YES key:@"enableSpinners" majorSetting:NO];
                        break;

                    default:
                        break;
                }
                break;

            case 4: // support
                cell = [[PCHLinkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                switch (indexPath.row) {
                    case 0:
                        [(PCHLinkTableViewCell *)cell linkCellWithText:@"☕️ Buy me a coffee" URL:[NSURL URLWithString:@"https://paypal.me/redenticdev"]];
                        break;

                    case 1:
                        [(PCHLinkTableViewCell *)cell linkCellWithText:@"💡 Feature request?" URL:[NSURL URLWithString:@"mailto:hello@redentic.dev?subject=Peach%20Feature%20Request"]];
                        break;

                    case 2:
                        [(PCHLinkTableViewCell *)cell linkCellWithText:@"🐞 Found a bug?" URL:[NSURL URLWithString:@"https://github.com/RedenticDev/Peach/issues/new"]];
                        break;

                    case 3:
                        [(PCHLinkTableViewCell *)cell linkCellWithText:@"💻 Source code (Private)" URL:[NSURL URLWithString:@"https://github.com/RedenticDev/Peach"]];
                        break;

                    default:
                        break;
                }
                break;

            default:
                break;
		}
	}

	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
        case 0: // twitter + enable
            return 2;

        case 1: // ui theming
            return 1;

        case 2: // image opener
            return 3;

        case 3: // features
            return 5;

        case 4: // support
            return 4;

        default:
            return [super tableView:tableView numberOfRowsInSection:section];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
	if ([cell isKindOfClass:[PCHLinkTableViewCell class]]) {
		return 60;
	}
	return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[PCHLinkTableViewCell class]]) {
        [[UIApplication sharedApplication] openURL:((PCHLinkTableViewCell *)cell).url options:@{} completionHandler:nil];
    }
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
