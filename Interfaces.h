#import "Classes/PCHHapticManager.h"
#import "Classes/PCHImageViewController.h"
#import "Classes/UIColor+Peach.h"

#pragma mark - Categories
@interface UIView (Peach)
- (UIViewController *)_viewControllerForAncestor;
@end

@interface UIImageAsset (Peach)
@property (nonatomic, copy) NSString *assetName;
@end

#pragma mark - Interfaces
// FF
@interface FFFastImageSource : NSObject
@property (nonatomic, strong, readwrite) NSURL *url;
@end

@interface FFFastImageView : UIImageView
@property (nonatomic, strong, readwrite) UIImage *image;
@property (nonatomic, strong, readwrite) FFFastImageSource *source;
@property (nonatomic, strong) UIActivityIndicatorView *loadingSpinner;
@end

// RCT
@interface RCTRootView : UIView
@end

@interface RCTView : UIView
@end

@interface RCTUIImageViewAnimated : UIImageView
@property (nonatomic, assign) BOOL revealed;
@end

@interface RCTImageView : RCTView
@property (nonatomic, copy, readwrite) NSArray *imageSources;
@end

@interface RCTImageSource : NSObject
- (NSURLRequest *)request;
@end

@interface RCTUITextView : UITextView
@end

@interface RCTTextView : UIView
@end

@interface BVLinearGradient : RCTView
@end

@interface RNGestureHandlerButton : UIControl
@end

@interface RNCSafeAreaView : RCTView
@end
