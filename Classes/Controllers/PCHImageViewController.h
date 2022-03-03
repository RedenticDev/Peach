#import <UIKit/UIKit.h>
#import <Cephei/HBPreferences.h>
#import <LinkPresentation/LPLinkMetadata.h>
#import <Photos/Photos.h>

@interface PCHImageViewController : UIViewController <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;

- (instancetype)initWithImage:(UIImage *)image;
@end
