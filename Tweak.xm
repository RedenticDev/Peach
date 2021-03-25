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

@interface RCTTextView : UIView
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
        revealTap.minimumPressDuration = .25;
        [self addGestureRecognizer:revealTap];

        UITapGestureRecognizer *detailTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(peach_openImageInDetails:)];
        [self addGestureRecognizer:detailTap];

        self.userInteractionEnabled = YES;
    }
    return orig;
}

%new
-(void)peach_unblurImage:(UILongPressGestureRecognizer *)gesture {
    if (self.revealed || !self.image) return;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self peach_vibrateWithType:1];
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:self.bounds];
        [self addSubview:spinner];
        // Get URL
        NSURL *profileURL = ((RCTImageSource *)((RCTImageView *)self.superview).imageSources[0]).request.URL;
        [spinner startAnimating];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *deblurredProfilePicture = [UIImage imageWithData:[NSData dataWithContentsOfURL:profileURL]];
            dispatch_async(dispatch_get_main_queue(), ^{
                // Replace image
                [spinner stopAnimating];
                [spinner removeFromSuperview];
                [UIView transitionWithView:self duration:.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    self.image = deblurredProfilePicture;
                } completion:^(BOOL finished) {
                    // Vibrate stronger
                    if (finished) [self peach_vibrateWithType:2];
                }];
            });
        });
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

// Parse Instagram accounts
%hook RCTTextView

-(void)setTextStorage:(NSTextStorage *)textStorage contentFrame:(CGRect)contentFrame descendantViews:(NSArray<UIView *> *)descendantViews {
    %orig;
    // searching for bio
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIView *sub in self.superview.superview.subviews) {
            if ([sub isKindOfClass:[%c(RCTTextView) class]] && [MSHookIvar<NSTextStorage *>((RCTTextView *)sub, "_textStorage").string isEqualToString:@"Bio"]) {
                NSLog(@"[Peach] Bio found (%p)", self);
                // Swapping shitty RCTTexView to UITextView
                UITextView *textView = [[UITextView alloc] initWithFrame:self.frame textContainer:MSHookIvar<NSTextStorage *>(self, "_textStorage").layoutManagers.firstObject.textContainers.firstObject];
                textView.editable = NO;
                textView.selectable = YES;
                CGFloat leftRightInset = textView.textContainer.lineFragmentPadding;
                textView.textContainerInset = UIEdgeInsetsMake(0, -leftRightInset, 0, -leftRightInset);
                textView.backgroundColor = [UIColor clearColor];
                [self.superview addSubview:textView];
                [self removeFromSuperview];
                // Finding instagram
                __block NSString *supposedInstagram;
                NSString *text = [[[[[[[[textStorage.string
                    stringByReplacingOccurrencesOfString:@":" withString:@" "]
                    stringByReplacingOccurrencesOfString:@"\n" withString:@" "]
                    stringByReplacingOccurrencesOfString:@"📸" withString:@"📸 "]
                    stringByReplacingOccurrencesOfString:@"," withString:@""]
                    stringByReplacingOccurrencesOfString:@"?" withString:@""]
                    stringByReplacingOccurrencesOfString:@"!" withString:@""]
                    stringByReplacingOccurrencesOfString:@"(" withString:@""]
                    stringByReplacingOccurrencesOfString:@")" withString:@""];
                NSMutableArray<NSString *> *words = [[text componentsSeparatedByString:@" "] mutableCopy];
                [words removeObject:@""];
                [words enumerateObjectsUsingBlock:^(NSString *string, NSUInteger index, BOOL *stop) {
                    if ([string hasPrefix:@"@"]) {
                        NSLog(@"[Peach] Method: \"@\" detected");
                        supposedInstagram = [string lowercaseString];
                        *stop = YES;
                    } else if ([[string lowercaseString] containsString:@"insta"] || [[string lowercaseString] isEqualToString:@"📸"] || [[string lowercaseString] isEqualToString:@"ig"]) {
                        NSLog(@"[Peach] Method: \"insta\", \"IG\" or \"📸\"");
                        if (index + 1 < [words count]) {
                            supposedInstagram = [words objectAtIndex:index + 1];
                            *stop = YES;
                        }
                    }
                }];
                if (supposedInstagram) {
                    NSLog(@"[Peach] Instagram found: %@", supposedInstagram);
                    // Editing text
                    NSMutableAttributedString *newBio = [textView.attributedText mutableCopy];
                    [newBio addAttribute:NSLinkAttributeName value:[NSURL URLWithString:[@"https://instagr.am/" stringByAppendingString:[supposedInstagram stringByReplacingOccurrencesOfString:@"@" withString:@""]]] range:[textView.text rangeOfString:supposedInstagram]];
                    textView.attributedText = newBio;
                } else {
                    NSLog(@"[Peach] No instagram found.");
                }
                break;
            }
        }
    });
}

%end
