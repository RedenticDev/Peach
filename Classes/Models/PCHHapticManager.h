#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>

FOUNDATION_EXTERN void AudioServicesPlaySystemSoundWithVibration(SystemSoundID inSystemSoundID, id unknown, NSDictionary *options);

@interface PCHHapticManager : NSObject
+ (void)triggerHapticForIntensity:(int)strength;
@end