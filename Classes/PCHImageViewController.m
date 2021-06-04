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
	[[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:self.image];
    } completionHandler:^(BOOL success, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Peach" message:success ? @"Saving successful" : [NSString stringWithFormat:@"Saving error:\n%@", error] preferredStyle:UIAlertControllerStyleAlert];
			[alert addAction:[UIAlertAction actionWithTitle:success ? @"OK" : @":(" style:UIAlertActionStyleDefault handler:nil]];
			[self presentViewController:alert animated:YES completion:nil];
		});
    }];
}

- (void)shareImage:(id)sender {
	UIActivityViewController *shareMenu = [[UIActivityViewController alloc] initWithActivityItems:@[self.image] applicationActivities:nil];
	shareMenu.popoverPresentationController.sourceView = self.view;
	[self presentViewController:shareMenu animated:YES completion:nil];
}

- (void)closeDetails:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	if (self.image) {
		CGFloat topHeight = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;

		if (@available(iOS 13.0, *)) {
			topHeight -= [UIApplication sharedApplication].statusBarFrame.size.height;
		}

		self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, topHeight, self.view.frame.size.width, self.view.frame.size.height - topHeight)];
		self.scrollView.minimumZoomScale = 1.0;
		self.scrollView.maximumZoomScale = 10.0;
		if (@available(iOS 13.0, *)) {
			self.scrollView.backgroundColor = [UIColor systemBackgroundColor];
		} else {
			self.scrollView.backgroundColor = [UIColor whiteColor];
		}
		self.scrollView.delegate = self;

		self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
		self.imageView.contentMode = UIViewContentModeScaleAspectFit;
		self.imageView.image = self.image;
	
		UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomToInitialScale:)];
		doubleTap.numberOfTapsRequired = 2;
		[self.scrollView addGestureRecognizer:doubleTap];

		[self.scrollView addSubview:self.imageView];
		[self.view addSubview:self.scrollView];
	}
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return self.imageView;
}

- (void)zoomToInitialScale:(UIGestureRecognizer *)sender {
	if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
		CGPoint center = [self.imageView convertPoint:[sender locationInView:sender.view] fromView:self.scrollView];
		CGRect zoomRect;
		zoomRect.size.height = self.imageView.frame.size.height / 2.0;
		zoomRect.size.width = self.imageView.frame.size.width / 2.0;
		zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0);
		zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
		[self.scrollView zoomToRect:zoomRect animated:YES];
	} else {
		[self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
	}
}

@end
