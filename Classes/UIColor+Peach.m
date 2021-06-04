#import "UIColor+Peach.h"

@implementation UIColor (Peach)

+ (UIColor *)peach_OLEDBackgroundColor {
    return [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection * traits) {
        return traits.userInterfaceStyle == UIUserInterfaceStyleLight ? 
                [UIColor colorWithWhite:1.00 alpha:1.00] :
                [UIColor colorWithWhite:0.00 alpha:1.00];
    }];
}

+ (UIColor *)peach_OLEDTextColor {
    return [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection * traits) {
        return traits.userInterfaceStyle == UIUserInterfaceStyleLight ? 
                [UIColor colorWithWhite:0.00 alpha:1.00] :
                [UIColor colorWithWhite:1.00 alpha:1.00];
    }];
}

+ (UIColor *)peach_systemBackgroundColorIfEligible:(UIColor *)input {
    if (@available(iOS 13.0, *)) {
        if (input && input != [[UIColor peach_OLEDBackgroundColor] colorWithAlphaComponent:input.alphaComponent]) {
            CGFloat red, green, blue, alpha;
            [input getRed:&red green:&green blue:&blue alpha:&alpha];
            if (red >= .9 && green >= .9 && blue >= .9) {
                return [[UIColor peach_OLEDBackgroundColor] colorWithAlphaComponent:alpha];
            }
        }
    }
    return input;
}

+ (UIColor *)peach_systemTextColorIfEligible:(UIColor *)input {
    if (@available(iOS 13.0, *)) {
        if (input && input != [[UIColor peach_OLEDTextColor] colorWithAlphaComponent:input.alphaComponent]) {
            CGFloat red, green, blue, alpha;
            [input getRed:&red green:&green blue:&blue alpha:&alpha];
            if (red <= .1 && green <= .1 && blue <= .2) {
                return [[UIColor peach_OLEDTextColor] colorWithAlphaComponent:alpha];
            }
        }
    }
    return input;
}

@end
