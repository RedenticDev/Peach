#import "PCHLinkTableViewCell.h"

#define BUNDLE_PATH @"/Library/Application Support/PeachAssets.bundle"

@implementation PCHLinkTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		// Icon
		self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
		self.icon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		self.icon.center = CGPointMake(self.icon.center.x + self.separatorInset.left, self.contentView.center.y);
		self.icon.clipsToBounds = YES;
		self.icon.layer.cornerRadius = self.icon.frame.size.width / 2;
		[self.contentView addSubview:self.icon];

		// Activity indicator for icon
		self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:self.icon.bounds];
		self.activityIndicator.hidesWhenStopped = YES;
		[self.icon addSubview:self.activityIndicator];

		// Main label
		self.titleLabel = [[UILabel alloc] init];
		self.titleLabel.textColor = [UIColor systemBlueColor];
		self.titleLabel.numberOfLines = 1;
		self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
		self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
		[self.contentView addSubview:self.titleLabel];

		// Detail label
		self.detailLabel = [[UILabel alloc] init];
		self.detailLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize] - 2.0];
		self.detailLabel.numberOfLines = 1;
		self.detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
		self.detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
		[self.contentView addSubview:self.detailLabel];

		NSDictionary *views = @{
			@"title" : self.titleLabel,
			@"detail" : self.detailLabel
		};

		[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[title]-5-[detail]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views]];
		[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[title]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views]];
		[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[detail]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views]];
		[self.contentView addConstraints:@[
			[NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.icon attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],
			[NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.icon attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]
		]];

		self.contentView.frame = CGRectInset(self.contentView.frame, self.separatorInset.left, self.separatorInset.right);
	}
	return self;
}

- (void)linkCellWithText:(NSString *)text URL:(NSURL *)url {
	self.titleLabel.text = text;
	NSString *detailElement = [[[url host] componentsSeparatedByString:@"."] objectAtIndex:0];
	self.detailLabel.text = [[url absoluteString] hasPrefix:@"mailto:"] ? @"Mail" : [detailElement stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[detailElement substringToIndex:1] capitalizedString]];
	[self setAccessoryViewWithImage:[UIImage imageWithContentsOfFile:[[NSBundle bundleWithPath:BUNDLE_PATH] pathForResource:@"safari" ofType:@"png"]]];
	self.url = url;
}

- (void)twitterCellWithName:(NSString *)name profile:(NSString *)profile {
	BOOL isSupported = [profile isEqualToString:@"RedenticDev"]; // sry twitter api lol
	[self setAccessoryViewWithImage:[UIImage imageWithContentsOfFile:[[NSBundle bundleWithPath:BUNDLE_PATH] pathForResource:@"twitter" ofType:@"png"]]];
	self.titleLabel.text = name;
	self.detailLabel.text = [@"@" stringByAppendingString:profile];
	self.url = [NSURL URLWithString:[@"https://twitter.com/" stringByAppendingString:profile]];

	if (isSupported) {
		[self.activityIndicator startAnimating];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://raw.githubusercontent.com/RedenticDev/RedenticDev/main/Me.png"]];
			UIImage *picture = [UIImage imageWithData:data];
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.activityIndicator stopAnimating];
				[self.activityIndicator removeFromSuperview];
				self.icon.image = picture;
			});
		});
	}

	[self.contentView removeConstraints:self.contentView.constraints];

	NSDictionary *views = @{
		@"icon" : self.icon,
		@"title" : self.titleLabel,
		@"detail" : self.detailLabel
	};

	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[title]-3-[detail]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views]];
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:isSupported ? @"H:|-[icon]-[title]-|" : @"H:|-[title]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views]];
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:isSupported ? @"H:|-[icon]-[detail]-|" : @"H:|-[detail]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views]];
}

- (void)setAccessoryViewWithImage:(UIImage *)image {
	self.accessoryView = [[UIImageView alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
	self.accessoryView.tintColor = [UIColor grayColor];
}

@end
