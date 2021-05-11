#import <UIKit/UIKit.h>

@interface UIColor (Peach)
+ (UIColor *)OLEDBackgroundColor API_AVAILABLE(ios(13.0));
+ (UIColor *)OLEDTextColor API_AVAILABLE(ios(13.0));
+ (UIColor *)systemBackgroundColorIfEligible:(UIColor *)input;
+ (UIColor *)systemTextColorIfEligible:(UIColor *)input;
@end