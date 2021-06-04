#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface PCHImageViewController : UIViewController <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;

-(instancetype)initWithImage:(UIImage *)image;
-(void)saveImage:(id)sender;
-(void)shareImage:(id)sender;
-(void)closeDetails:(id)sender;
-(void)zoomToInitialScale:(UIGestureRecognizer *)sender;
@end
