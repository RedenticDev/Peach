#import <UIKit/UIKit.h>

@interface UIColor ()
- (double)alphaComponent;
@end

@interface UIColor (Peach)
+ (UIColor *)peach_OLEDBackgroundColor API_AVAILABLE(ios(13.0));
+ (UIColor *)peach_OLEDTextColor API_AVAILABLE(ios(13.0));
+ (UIColor *)peach_systemBackgroundColorIfEligible:(UIColor *)input;
+ (UIColor *)peach_systemTextColorIfEligible:(UIColor *)input;
@end
