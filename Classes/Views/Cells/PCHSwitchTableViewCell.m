#import "PCHSwitchTableViewCell.h"

@implementation PCHSwitchTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
		self.accessoryView = self.switchView;
	}
	return self;
}

- (void)configureCellWithLabel:(NSString *)label defaultValue:(BOOL)value key:(NSString *)key majorSetting:(BOOL)major {
	self.textLabel.text = label;
	self.major = major;
	HBPreferences *preferences = [HBPreferences preferencesForIdentifier:@"dev.redentic.peach"];
	if ([preferences objectForKey:key]) {
		self.switchView.on = [preferences boolForKey:key];
	} else {
		self.switchView.on = value;
		[preferences setBool:value forKey:key];
	}
	[self.switchView addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
	self.key = key;
}

- (void)valueChanged:(UISwitch *)sender {
	[self.delegate key:self.key didChangeTo:sender.isOn needingRestart:self.major];
}

@end
