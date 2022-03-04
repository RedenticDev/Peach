#import "PCHHapticManager.h"

@implementation PCHHapticManager

+ (void)triggerHapticForIntensity:(int)strength {
    if (strength < 1 || strength > 3) return;
    switch ([[[UIDevice currentDevice] valueForKey:@"_feedbackSupportLevel"] integerValue]) {
        case 0: { // 6 and older
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            NSMutableArray *arr = [NSMutableArray array];
            [arr addObject:@YES];
            [arr addObject:[NSNumber numberWithInt:250]];
            [dict setObject:arr forKey:@"VibePattern"];
            [dict setObject:[NSNumber numberWithFloat:strength] forKey:@"Intensity"];
            AudioServicesPlaySystemSoundWithVibration(4095, nil, dict);
        } break;
        
        case 1: // 6s
            if (strength == 1) {
                AudioServicesPlaySystemSound(1519);
            } else {
                AudioServicesPlaySystemSound(1520);
            }
            break;
        
        case 2: // 7 and newer
            if (strength != 3) {
                [[[UIImpactFeedbackGenerator alloc] initWithStyle:strength] impactOccurred];
            } else {
                [[[UINotificationFeedbackGenerator alloc] init] notificationOccurred:UINotificationFeedbackTypeSuccess];
            }
            break;
        
        default:
            break;
    }
}

@end