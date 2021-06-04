#import "Interfaces.h"

#pragma mark - Hooks

// Haptic - not implemented
/* %hook RCTView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"[Peach] Testing eligibility for view %p", self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.subviews.count == 1 && self.subviews[0].subviews.count == 1
            && [self.subviews[0].subviews[0] isKindOfClass:%c(FFFastImageView)]) {
            NSLog(@"[Peach] View eligible for haptics (%p)", self);
            FFFastImageView *button = (FFFastImageView *)self.subviews[0].subviews[0];
            if ([button.source.url.lastPathComponent containsString:@"swipe_pass"]) {
                [PCHHapticManager triggerHapticForIntensity:1];
            } else if ([button.source.url.lastPathComponent containsString:@"swipe_like"]) {
                [PCHHapticManager triggerHapticForIntensity:2];
            }
        }
    });
}

%end */

// Images in profiles / profile pictures
%hook FFFastImageView

// %property (nonatomic, strong) UIActivityIndicatorView *loadingSpinner;

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
        hookedPeach.userInteractionEnabled = YES;
        [self addSubview:hookedPeach];
        NSLog(@"[Peach] Pimped logo");
        [hookedPeach addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(peach_showCredits:)]];
    }
}

/*- (void)setHasCompleted:(BOOL)completed {
    NSLog(@"[Peach] (%p) self.hasCompleted: %d, completed: %d -> interesting? %d", self, self.hasCompleted, completed, (!completed && self.hasCompleted) || (completed && !self.hasCompleted && self.loadingSpinner));
    if (!completed && self.hasCompleted) {
        NSLog(@"[Peach] Spinny needed (%p)", self);
        // Start spinny
        if (!self.loadingSpinner) {
            NSLog(@"[Peach] Spinny created");
            self.loadingSpinner = [[UIActivityIndicatorView alloc] initWithFrame:self.bounds];
            self.loadingSpinner.color = [UIColor blackColor];
            [self addSubview:self.loadingSpinner];
        }
        [self.loadingSpinner startAnimating];
        NSLog(@"[Peach] Spinny started");
    } else if (completed && !self.hasCompleted && self.loadingSpinner) {
        // Stop spinny
        [self.loadingSpinner stopAnimating];
        [self.loadingSpinner removeFromSuperview];
        NSLog(@"[Peach] Spinny stopped (%p)", self);
    }
    %orig;
}*/

%new
- (void)peach_openImageInDetails:(UILongPressGestureRecognizer *)gesture {
    if (self.image && ![self.source.url.scheme isEqualToString:@"file"]) {
        [self._viewControllerForAncestor presentViewController:[[UINavigationController alloc] initWithRootViewController:[[PCHImageViewController alloc] initWithImage:self.image]] animated:YES completion:nil];
    }
}

%new
- (void)peach_showCredits:(UITapGestureRecognizer *)gesture {
    /*char ver[32];
    FILE *fp = popen("/usr/bin/dpkg -s com.redenticdev.peach | grep Version | cut -d' ' -f2- | xargs", "r");
    fgets(ver, 32, fp);
    pclose(fp);
    NSString *version = [NSString stringWithCString:ver encoding:NSUTF8StringEncoding];*/

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🍑 Peach" message:/*[NSString stringWithFormat:@"\nVersion %@\n*/@"\nMade with ❤️ by RedenticDev"/*, version]*/ preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self._viewControllerForAncestor presentViewController:alert animated:YES completion:nil];
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

/*- (void)setHasCompleted:(BOOL)arg1 {
    %orig;
    if (self.frame.size.width > 40 && self.frame.size.height > 40) return;
    NSLog(@"willWindow candidate %@", self);
}*/

%new
- (void)peach_unblurImage:(UILongPressGestureRecognizer *)gesture {
    if (self.revealed || !self.image) return;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [PCHHapticManager triggerHapticForIntensity:1];
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
                    if (self.image) self.image = deblurredProfilePicture;
                } completion:^(BOOL finished) {
                    // Vibrate stronger
                    if (finished) [PCHHapticManager triggerHapticForIntensity:3];
                }];
            });
        });
        self.revealed = YES;
    }
}

%new
- (void)peach_openRevealedImageInDetails:(UITapGestureRecognizer *)gesture {
    if (!self.revealed || !self.image) return;
    if (gesture.state == UIGestureRecognizerStateEnded) [self._viewControllerForAncestor presentViewController:[[UINavigationController alloc] initWithRootViewController:[[PCHImageViewController alloc] initWithImage:self.image]] animated:YES completion:nil];
}

%end

// Parse Instagram accounts
%hook RCTTextView

- (void)setTextStorage:(NSTextStorage *)textStorage contentFrame:(CGRect)contentFrame descendantViews:(NSArray<UIView *> *)descendantViews {
    // dark mode
    NSMutableDictionary *attributes = [[textStorage attributesAtIndex:0 effectiveRange:nil] mutableCopy];
    if (attributes[NSForegroundColorAttributeName]) {
        attributes[NSForegroundColorAttributeName] = [UIColor peach_systemTextColorIfEligible:attributes[NSForegroundColorAttributeName]];
        [textStorage setAttributes:attributes range:NSMakeRange(0, textStorage.length)];
    }

    %orig(textStorage, contentFrame, descendantViews);

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
                NSString __block *supposedInstagram;
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
                    } else if ([[string lowercaseString] isEqualToString:@"instagram"] || 
                                [[string lowercaseString] isEqualToString:@"insta"] || 
                                [[string lowercaseString] isEqualToString:@"📸"] || 
                                [[string lowercaseString] isEqualToString:@"ig"]) {
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
                    if (textView) textView.attributedText = newBio;
                } else {
                    NSLog(@"[Peach] No instagram found.");
                }
                break;
            }
        }
    });
}

%end

// Removing "Reveal" button - not implemented
/* %hook BVLinearGradient

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

// Premiums - not working
%hook RNGestureHandlerButton

- (BOOL)hidden {
    UIView *supposedImage = self.subviews[0].subviews[0].subviews[0];
    if ([supposedImage isKindOfClass:%c(FFFastImageView)] && [((FFFastImageView *)supposedImage).source.url.lastPathComponent isEqualToString:@"mixer.png"]) {
        return YES;
    }
    return %orig;
}

%end*/

// Dark mode
%hook RCTView

- (void)didMoveToWindow {
    %orig;
    self.backgroundColor = [UIColor peach_systemBackgroundColorIfEligible:self.backgroundColor];
}

- (void)didMoveToSuperview {
    %orig;
    self.backgroundColor = [UIColor peach_systemBackgroundColorIfEligible:self.backgroundColor];
}

- (UIColor *)backgroundColor {
    return [UIColor peach_systemBackgroundColorIfEligible:%orig];
}

%end

%hook RNCSafeAreaView

- (void)didMoveToWindow {
    %orig;
    self.backgroundColor = [UIColor peach_systemBackgroundColorIfEligible:self.backgroundColor];
}

- (void)didMoveToSuperview {
    %orig;
    self.backgroundColor = [UIColor peach_systemBackgroundColorIfEligible:self.backgroundColor];
}

- (UIColor *)backgroundColor {
    return [UIColor peach_systemBackgroundColorIfEligible:%orig];
}

%end

%hook RCTUITextView

- (void)textDidChange {
    %orig;
    if (@available(iOS 13.0, *)) {
        self.textColor = [UIColor peach_OLEDTextColor];
    }
}

- (NSDictionary *)defaultTextAttributes {
    if (@available(iOS 13.0, *)) {
        NSMutableDictionary *attributes = [%orig mutableCopy];
        if (attributes[NSForegroundColorAttributeName]) {
            attributes[NSForegroundColorAttributeName] = [UIColor peach_systemTextColorIfEligible:attributes[NSForegroundColorAttributeName]];
            return attributes;
        }
    }
    return %orig;
}

- (UIColor *)textColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor peach_OLEDTextColor];
    }
    return %orig;
}

%end

%hook UIApplication

- (NSInteger)statusBarStyle {
    if (@available(iOS 13.0, *)) {
        return UIStatusBarStyleDefault;
    }
    return %orig;
}

%end
