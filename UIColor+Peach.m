#import "UIColor+Peach.h"

@implementation UIColor (Peach)

+ (UIColor *)OLEDBackgroundColor {
    return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traits) {
        return traits.userInterfaceStyle == UIUserInterfaceStyleLight ? 
                [UIColor colorWithWhite:1.00 alpha:1.00] :
                [UIColor colorWithWhite:0.00 alpha:1.00];
    }];
}

+ (UIColor *)OLEDTextColor {
    return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traits) {
        return traits.userInterfaceStyle == UIUserInterfaceStyleLight ? 
                [UIColor colorWithWhite:0.00 alpha:1.00] :
                [UIColor colorWithWhite:1.00 alpha:1.00];
    }];
}

+ (UIColor *)systemBackgroundColorIfEligible:(UIColor *)input {
    if (@available(iOS 13.0, *)) {
        if (input && input != [UIColor systemBackgroundColor]) {
            CGFloat red, green, blue, alpha;
            [input getRed:&red green:&green blue:&blue alpha:&alpha];
            if (red >= .9 && green >= .9 && blue >= .9) {
                return [[UIColor OLEDBackgroundColor] colorWithAlphaComponent:alpha];
            }
        }
    }
    return input;
}

+ (UIColor *)systemTextColorIfEligible:(UIColor *)input {
    if (@available(iOS 13.0, *)) {
        if (input && input != [UIColor labelColor]) {
            CGFloat red, green, blue, alpha;
            [input getRed:&red green:&green blue:&blue alpha:&alpha];
            if (red <= .1 && green <= .1 && blue <= .2) {
                return [[UIColor OLEDTextColor] colorWithAlphaComponent:alpha];
            }
        }
    }
    return input;
}

@end