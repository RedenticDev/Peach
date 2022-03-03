#import "PCHImageViewController.h"

@implementation PCHImageViewController

- (instancetype)initWithImage:(UIImage *)image {
	if (self = [super init]) {
		self.image = image;
	}
	return self;
}

- (void)loadView {
	[super loadView];

	self.navigationItem.leftBarButtonItems = @[
		[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveImage:)],
		[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareImage:)]
	];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeDetails:)];
}

- (void)saveImage:(id)sender {
	void (^saveBlock)() = ^{
		// Populate toolbar
		UILabel *statusLabel = [[UILabel alloc] init];
		statusLabel.text = @"Saving image...";
		statusLabel.textAlignment = NSTextAlignmentCenter;
		self.toolbarItems = @[
			[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
			[[UIBarButtonItem alloc] initWithCustomView:statusLabel],
			[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]
		];
		[self.navigationController setToolbarHidden:NO animated:YES];

		// Save photo
		[[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
			[PHAssetChangeRequest creationRequestForAssetFromImage:self.image];
		} completionHandler:^(BOOL success, NSError *error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				statusLabel.text = success ? @"Image saved!" : @"Error";
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
					[self.navigationController setToolbarHidden:YES animated:YES];
				});
				if (!success) {
					UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Peach" message:[NSString stringWithFormat:@"Saving error:\n%@", error] preferredStyle:UIAlertControllerStyleAlert];
					[alert addAction:[UIAlertAction actionWithTitle:@":(" style:UIAlertActionStyleDefault handler:nil]];
					[self presentViewController:alert animated:YES completion:nil];
				}
			});
		}];
	};
	if ([[HBPreferences preferencesForIdentifier:@"dev.redentic.peach"] boolForKey:@"askSaveConfirmation"]) {
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Peach" message:@"Do you really want to save this image?" preferredStyle:UIAlertControllerStyleAlert];
		[alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			saveBlock();
		}]];
		[alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
		[self presentViewController:alert animated:YES completion:nil];
	} else {
		saveBlock();
	}
}

- (void)shareImage:(id)sender {
	UIActivityViewController *shareMenu = [[UIActivityViewController alloc] initWithActivityItems:@[self.image, self] applicationActivities:nil];
	[self presentViewController:shareMenu animated:YES completion:nil];
}

- (void)closeDetails:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Fill view
	if (self.image) {
		// Init scroll view for zoom
		self.scrollView = [[UIScrollView alloc] init];
		self.scrollView.minimumZoomScale = 1.0;
		self.scrollView.maximumZoomScale = 10.0;
		if (@available(iOS 13.0, *)) {
			self.scrollView.backgroundColor = [UIColor systemBackgroundColor];
		} else {
			self.scrollView.backgroundColor = [UIColor whiteColor];
		}
		self.scrollView.delegate = self;

		// Add ImageView to scroll view
		self.imageView = [[UIImageView alloc] init];
		self.imageView.contentMode = UIViewContentModeScaleAspectFit;
		self.imageView.image = self.image;
	
		UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomToInitialScale:)];
		doubleTap.numberOfTapsRequired = 2;
		[self.scrollView addGestureRecognizer:doubleTap];

		[self.scrollView addSubview:self.imageView];
		[self.view addSubview:self.scrollView];
	}
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];

	// Frames definition
	self.scrollView.frame = self.view.frame;
	self.imageView.frame = CGRectMake(
		0, 0,
		self.scrollView.frame.size.width,
		self.scrollView.frame.size.height - self.navigationController.navigationBar.frame.size.height
	);
}

- (void)zoomToInitialScale:(UIGestureRecognizer *)sender {
	if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
		CGPoint center = [self.imageView convertPoint:[sender locationInView:sender.view] fromView:self.scrollView];
		[self.scrollView zoomToRect:CGRectMake(
			center.x - (self.imageView.frame.size.width / 4.0),
			center.y - (self.imageView.frame.size.height / 4.0),
			self.imageView.frame.size.width / 2.0,
			self.imageView.frame.size.height / 2.0
		) animated:YES];
	} else {
		[self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
	}
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return self.imageView;
}

#pragma mark - UIActivityItemSource
- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
	return [UIImage new];
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(UIActivityType)activityType {
	return self.image;
}

- (LPLinkMetadata *)activityViewControllerLinkMetadata:(UIActivityViewController *)activityViewController API_AVAILABLE(ios(13.0)) {
	LPLinkMetadata *metadata = [[LPLinkMetadata alloc] init];
	metadata.title = @"Image obtained from Peach";
	metadata.imageProvider = [[NSItemProvider alloc] initWithObject:self.image];
	return metadata;
}

@end
