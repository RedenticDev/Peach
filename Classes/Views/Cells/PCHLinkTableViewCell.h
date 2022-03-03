#import <UIKit/UIKit.h>

@interface PCHLinkTableViewCell : UITableViewCell
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) NSURL *url;
-(void)linkCellWithText:(NSString *)text URL:(NSURL *)url;
-(void)twitterCellWithName:(NSString *)name profile:(NSString *)profile;
-(void)setAccessoryViewWithImage:(UIImage *)image;
@end
