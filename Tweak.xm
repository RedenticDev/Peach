#import <AudioToolbox/AudioServices.h>
#import "PCHImageViewController.h"

#pragma mark - Interfaces
@interface FFFastImageSource : NSObject
@property (nonatomic, strong, readwrite) NSURL *url;
@end

@interface FFFastImageView : UIImageView
-(id)_viewControllerForAncestor;
@property (nonatomic, strong, readwrite) FFFastImageSource *source;
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

@interface BVLinearGradient : UIView
@end

@interface UIImageAsset (Peach)
@property (nonatomic, copy) NSString *assetName;
@end

#pragma mark - Hooks
// Images in profiles / profile pictures
%hook FFFastImageView

- (instancetype)initWithFrame:(CGRect)arg1 {
    if ((self = %orig)) {
        UILongPressGestureRecognizer *detailTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(peach_openImageInDetails:)];
        detailTap.minimumPressDuration = .2;
        [self addGestureRecognizer:detailTap];

        self.userInteractionEnabled = YES;
    }
    return self;
}

// Peach in logo: I had to use layoutSubviews cause frame is nil in usual methods for a reason
- (void)layoutSubviews {
    %orig;
    if ([self.source.url.lastPathComponent isEqualToString:@"fruitz_nav.png"] && self.subviews.count == 0) {
        UIImageView *hookedPeach = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 32, self.frame.size.height - 32, 32, 32)];
        hookedPeach.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"peach_shadow" ofType:@"png" inDirectory:@"assets/app/assets/artworks/"]];
        [self addSubview:hookedPeach];
        NSLog(@"[Peach] Pimped logo");
    }
}

%new
- (void)peach_openImageInDetails:(UILongPressGestureRecognizer *)gesture {
    if (![self.source.url.scheme isEqualToString:@"file"]) {
        [self._viewControllerForAncestor presentViewController:[[UINavigationController alloc] initWithRootViewController:[[PCHImageViewController alloc] initWithImage:self.image]] animated:YES completion:nil];
    }
}

%end

// Matches that can be revealed by paying in the reveal page
%hook RCTUIImageViewAnimated

%property (nonatomic, assign) BOOL revealed;

- (instancetype)initWithFrame:(CGRect)arg1 {
    if ((self = %orig)) {
        UILongPressGestureRecognizer *revealTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(peach_unblurImage:)];
        revealTap.minimumPressDuration = .25;
        [self addGestureRecognizer:revealTap];

        UITapGestureRecognizer *detailTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(peach_openRevealedImageInDetails:)];
        [self addGestureRecognizer:detailTap];

        self.userInteractionEnabled = YES;
        self.revealed = NO;
    }
    return self;
}

%new
- (void)peach_unblurImage:(UILongPressGestureRecognizer *)gesture {
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
- (void)peach_openRevealedImageInDetails:(UITapGestureRecognizer *)gesture {
    if (!self.revealed) return;
    if (gesture.state == UIGestureRecognizerStateEnded) [self._viewControllerForAncestor presentViewController:[[UINavigationController alloc] initWithRootViewController:[[PCHImageViewController alloc] initWithImage:self.image]] animated:YES completion:nil];
}

%new
- (void)peach_vibrateWithType:(int)type {
    if ([[[UIDevice currentDevice] valueForKey:@"_feedbackSupportLevel"] integerValue] > 1) {
        if (type == 1) {
            [[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium] impactOccurred];
        } else if (type == 2) {
            [[[UINotificationFeedbackGenerator alloc] init] notificationOccurred:UINotificationFeedbackTypeSuccess];
        }
    } else {
        if (type == 1) {
            AudioServicesPlaySystemSound(1519);
        } else if (type == 2) {
            AudioServicesPlaySystemSound(1520);
        }
    }
}

%end

// Parse Instagram accounts
%hook RCTTextView

- (void)setTextStorage:(NSTextStorage *)textStorage contentFrame:(CGRect)contentFrame descendantViews:(NSArray<UIView *> *)descendantViews {
    %orig;
    // searching for bio
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIView *sub in self.superview.superview.subviews) {
            if ([sub isKindOfClass:[%c(RCTTextView) class]] && [MSHookIvar<NSTextStorage *>((RCTTextView *)sub, "_textStorage").string isEqualToString:@"Bio"]) {
                NSLog(@"[Peach] Bio found (%p)", self);
                // Swapping shitty RCTTextView to UITextView
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
                    [newBio addAttribute:NSLinkAttributeName value:[NSURL URLWithString:[@"https://instagram.com/" stringByAppendingString:[supposedInstagram stringByReplacingOccurrencesOfString:@"@" withString:@""]]] range:[textView.text rangeOfString:supposedInstagram]];
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

// Removing "Reveal" button
%hook BVLinearGradient

- (void)didMoveToSuperview { // FIXME: causes lag + EXEC_BAD_ACCESS crash sometimes
    %orig;
    // RCTView = 30 589 315 48 -> button to remove
    //   BVLinearGradient = 0 0 315 48 -> white bg
    //   RCTView = 267 4 40 40 -> image area
    //     RCTImageView = 0 0 40 40 -> imageview
    //       RCTUIImageViewAnimated = 0 0 40 40 -> image (assets/app/assets/artworks/premium/heart.png)
    //   RCTView = 24 0 267 48 -> text area
    // ----- RCTTextView = 100.5 10.5 66 27 -> text
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.superview isKindOfClass:%c(RCTView)] && self.superview.subviews.count == 3) {
            for (UIView *first in self.superview.subviews) {
                if (first.subviews.count > 0 && first.subviews[0].subviews.count > 0
                    && [first.subviews[0].subviews[0] isKindOfClass:%c(RCTUIImageViewAnimated)]
                    && [((RCTUIImageViewAnimated *)first.subviews[0].subviews[0]).image.imageAsset.assetName isEqualToString:@"assets/app/assets/artworks/premium/heart.png"]) {
                        // Good start
                        for (UIView *sec in self.superview.subviews) {
                            if (sec.subviews.count > 0 && [sec.subviews[0] isKindOfClass:%c(RCTTextView)]) {
                                // Almost 100% sure it's good
                                NSLog(@"[Peach] Removing button %p after detecting %p", self.superview.superview, self);
                                [UIView transitionWithView:self.superview.superview duration:.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                                    [self.superview removeFromSuperview];
                                } completion:nil];
                                break;
                            }
                        }
                    break;
                }
            }
        }
    });
}

%end
