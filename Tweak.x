#import <AudioToolbox/AudioServices.h>
#import "PCHImageViewController.h"

@interface FFFastImageView : UIImageView
-(id)_viewControllerForAncestor;
@end

@interface RCTUIImageViewAnimated : UIImageView
@property (nonatomic, assign) BOOL revealed;
-(id)_viewControllerForAncestor;
-(void)peach_vibrateWithType:(int)type;
@end

@interface RCTImageView : UIView
@property (nonatomic, copy, readwrite) NSArray *imageSources;
@end

@interface RCTImageSource : NSObject
-(NSURLRequest *)request;
@end

// Images in profiles
%hook FFFastImageView

-(id)initWithFrame:(CGRect)arg1 {
    id orig = %orig;

    if (orig) {
        UILongPressGestureRecognizer *detailTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(peach_openImageInDetails:)];
        detailTap.minimumPressDuration = .2;
        [self addGestureRecognizer:detailTap];

        self.userInteractionEnabled = YES;
    }
    return orig;
}

%new
-(void)peach_openImageInDetails:(UILongPressGestureRecognizer *)gesture {
    [self._viewControllerForAncestor presentViewController:[[UINavigationController alloc] initWithRootViewController:[[PCHImageViewController alloc] initWithImage:self.image]] animated:YES completion:nil];
}

%end

// Matches that can be revealed by paying
%hook RCTUIImageViewAnimated

%property (nonatomic, assign) BOOL revealed;

-(id)initWithFrame:(CGRect)arg1 {
    id orig = %orig;

    if (orig) {
        UILongPressGestureRecognizer *revealTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(peach_unblurImage:)];
        revealTap.minimumPressDuration = .5;
        [self addGestureRecognizer:revealTap];

        UITapGestureRecognizer *detailTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(peach_openImageInDetails:)];
        [self addGestureRecognizer:detailTap];

        self.userInteractionEnabled = YES;
    }
    return orig;
}

%new
-(void)peach_unblurImage:(UILongPressGestureRecognizer *)gesture {
    if (self.revealed) return;
    if (gesture.state == UIGestureRecognizerStateBegan) [self peach_vibrateWithType:1];
    if (gesture.state == UIGestureRecognizerStateEnded) {
        // Get URL
        NSURL *profileURL = ((RCTImageSource *)((RCTImageView *)self.superview).imageSources[0]).request.URL;
        // Replace image
        self.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:profileURL]];
        // Vibrate stronger
        [self peach_vibrateWithType:2];
        self.revealed = YES;
    }
}

%new
-(void)peach_openImageInDetails:(UITapGestureRecognizer *)gesture {
    if (!self.revealed) return;
    if (gesture.state == UIGestureRecognizerStateEnded) [self._viewControllerForAncestor presentViewController:[[UINavigationController alloc] initWithRootViewController:[[PCHImageViewController alloc] initWithImage:self.image]] animated:YES completion:nil];
}

%new
-(void)peach_vibrateWithType:(int)type {
    if ([[[UIDevice currentDevice] valueForKey:@"_feedbackSupportLevel"] integerValue] > 1) {
        if (type == 1) {
            [[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium] impactOccurred];
        } else if (type == 2) {
            [[[UINotificationFeedbackGenerator alloc] init] notificationOccurred:UINotificationFeedbackTypeSuccess];
        }
    } else {
        AudioServicesPlaySystemSound(1519);
    }
}

%end
