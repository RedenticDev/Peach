#import "Interfaces.h"

static NSString *VERSION = @"1.3.2";

#pragma mark - Hooks

// Images in profiles / profile pictures
%hook FFFastImageView

%property (nonatomic, strong) UIActivityIndicatorView *loadingSpinner;

- (instancetype)initWithFrame:(CGRect)arg1 {
    if ((self = %orig)) {
        UILongPressGestureRecognizer *detailTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(peach_openImageInDetails:)];
        detailTap.minimumPressDuration = .3;
        [self addGestureRecognizer:detailTap];

        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    // BOOL isLikeOrDislike = [self.source.url.lastPathComponent containsString:@"swipe_pass"] || [self.source.url.lastPathComponent containsString:@"swipe_like"];
    %orig;
    if (image) {
        // Resize haptic buttons
        // if (isLikeOrDislike) {
        //     %orig([image imageWithAlignmentRectInsets:UIEdgeInsetsMake(-10, -10, -10, -10)]);
        //     self.superview.frame = CGRectMake(self.superview.superview.frame.origin.x,
        //                                       self.superview.superview.frame.origin.y,
        //                                       self.superview.superview.frame.size.width,
        //                                       self.superview.superview.frame.size.height);
        //     self.frame = CGRectMake(self.frame.origin.x,
        //                             self.frame.origin.y,
        //                             self.superview.superview.frame.size.width,
        //                             self.superview.superview.frame.size.height);
        // } else {
        // }
        // Stop spinny
        if (self.loadingSpinner) {
            [self.loadingSpinner stopAnimating];
            [self.loadingSpinner removeFromSuperview];
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([self.source.url.lastPathComponent containsString:@"swipe_pass"]) {
            [PCHHapticManager triggerHapticForIntensity:1];
        } else if ([self.source.url.lastPathComponent containsString:@"swipe_like"]) {
            [PCHHapticManager triggerHapticForIntensity:2];
        }
    });
}

// Stuff here needed layoutSubviews cause frame/bounds are nil in usual methods for some reason
- (void)layoutSubviews {
    %orig;
    if ([self.source.url.lastPathComponent isEqualToString:@"fruitz_nav.png"] && self.subviews.count == 0) {
        UIImageView *hookedPeach = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 32, self.frame.size.height - 32, 32, 32)];
        hookedPeach.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"peach_shadow" ofType:@"png" inDirectory:@"assets/app/assets/artworks/"]];
        hookedPeach.userInteractionEnabled = YES;
        [self addSubview:hookedPeach];
        NSLog(@"Pimped logo");
        [hookedPeach addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(peach_showCredits:)]];
    } else if (!self.image && !self.loadingSpinner && !CGRectIsEmpty(self.bounds)) {
        // Start spinny
        self.loadingSpinner = [[UIActivityIndicatorView alloc] initWithFrame:self.bounds];
        [self addSubview:self.loadingSpinner];
        [self.loadingSpinner startAnimating];
    }
}

%new
- (void)peach_openImageInDetails:(UILongPressGestureRecognizer *)gesture {
    if (self.image && ![self.source.url.scheme isEqualToString:@"file"]) {
        [self._viewControllerForAncestor presentViewController:[[UINavigationController alloc] initWithRootViewController:[[PCHImageViewController alloc] initWithImage:self.image]] animated:YES completion:nil];
    }
}

%new
- (void)peach_showCredits:(UITapGestureRecognizer *)gesture {
    /*char ver[32];
    FILE *fp = popen("/usr/bin/dpkg -s dev.redentic.peach | grep Version | cut -d' ' -f2- | xargs", "r");
    fgets(ver, 32, fp);
    pclose(fp);
    NSString *version = [NSString stringWithCString:ver encoding:NSUTF8StringEncoding];*/

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🍑 Peach" message:[NSString stringWithFormat:@"\nVersion %@\n\nMade with ❤️ by RedenticDev", VERSION/*version*/] preferredStyle:UIAlertControllerStyleAlert];
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
        revealTap.minimumPressDuration = .3;
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
    if (!self.superview) return;

    // Searching for bio
    BOOL bioFound = NO;
    for (UIView *sub in self.superview.superview.subviews) {
        if ([sub isKindOfClass:%c(RCTTextView)]) {
            NSTextStorage *bioLabel = MSHookIvar<NSTextStorage *>((RCTTextView *)sub, "_textStorage");
            if ([bioLabel.string isEqualToString:@"Bio"] ||
                (!bioLabel.string && sub.frame.origin.x == 0 && sub.frame.origin.y == 17)) { // I know, don't judge me
                NSLog(@"Bio found (%p)", self);
                bioFound = YES;
                break;
            }
        }
    }
    if (bioFound) {
        %orig;

        // Swapping shitty RCTTextView to UITextView
        NSLog(@"Fixing text view");
        [textStorage setAttributes:@{
            NSFontAttributeName : [UIFont systemFontOfSize:[UIFont systemFontSize] + 2.], // fix font
            NSForegroundColorAttributeName : [UIColor peach_systemTextColorIfEligible:[textStorage attributesAtIndex:0 effectiveRange:nil][NSForegroundColorAttributeName]]
        } range:NSMakeRange(0, textStorage.length)];
        CGRect originalFrame = self.frame;
        originalFrame.size.height = ceil(originalFrame.size.height); // other fix for out of view
        UITextView *textView = [[UITextView alloc] initWithFrame:originalFrame textContainer:textStorage.layoutManagers.firstObject.textContainers.firstObject];
        textView.editable = NO;
        textView.selectable = YES;
        CGFloat leftRightInset = textView.textContainer.lineFragmentPadding;
        textView.textContainerInset = UIEdgeInsetsMake(0, -leftRightInset, 0, -leftRightInset);
        textView.backgroundColor = [UIColor clearColor];
        textView.scrollEnabled = NO; // prevent text from getting out of view
        [self.superview addSubview:textView];
        [self removeFromSuperview];
        NSLog(@"UITextView applied.");

        // Finding instagram
        NSLog(@"Finding Instagram if any");
        NSRange __block supposedInstagramCleanRange = NSMakeRange(NSNotFound, 0);

        NSString *text = [[[textStorage.string
            stringByReplacingOccurrencesOfString:@"📸" withString:@"insta"]
            stringByReplacingOccurrencesOfString:@"📷" withString:@"insta"]
            stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        NSString *asciiText = [[NSString alloc] initWithData:[text dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES] encoding:NSASCIIStringEncoding];
        NSString *bio = [[asciiText componentsSeparatedByCharactersInSet:
            [NSCharacterSet characterSetWithCharactersInString:@":,?!&#;()[]{}\"\'"]
        ] componentsJoinedByString:@""];

        NSMutableArray<NSString *> *words = [[bio componentsSeparatedByString:@" "] mutableCopy];
        NSInteger __block location = 0;
        [words enumerateObjectsUsingBlock:^(NSString *string, NSUInteger index, BOOL *stop) {
            if ([string hasPrefix:@"@"]) {
                NSLog(@"Method 1: \"@\"");
                supposedInstagramCleanRange = NSMakeRange(location, string.length);
                *stop = YES;
            }
            location += string.length + 1;
        }];
        if (supposedInstagramCleanRange.location == NSNotFound) {
            location = 0;
            [words enumerateObjectsUsingBlock:^(NSString *string, NSUInteger index, BOOL *stop) {
                if ([[string lowercaseString] isEqualToString:@"instagram"] ||
                        [[string lowercaseString] isEqualToString:@"insta"] ||
                        [[string lowercaseString] isEqualToString:@"ig"]) {
                    NSLog(@"Method 2: Literal");
                    NSInteger skipped = 1;
                    while (index + skipped < [words count] && [words[index + skipped] isEqualToString:@""]) {
                        skipped++; // Skip all empty words, not removed anymore from array
                    }
                    if (index + skipped < [words count])
                        supposedInstagramCleanRange = NSMakeRange(location + string.length + skipped, words[index + skipped].length);
                    *stop = YES;
                }
                location += string.length + 1;
            }];
        }
        if (supposedInstagramCleanRange.location != NSNotFound) {
            // Find right location in original text
            NSString *supposedInstagramClean = [bio substringWithRange:supposedInstagramCleanRange];
            NSString __block *supposedInstagram;
            NSRange __block supposedInstagramRange;
            NSInteger __block closeIndex = 0;
            location = 0;
            [[[textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@" "] componentsSeparatedByString:@" "] enumerateObjectsUsingBlock:^(NSString *string, NSUInteger index, BOOL *stop) {
                if ([string isEqualToString:supposedInstagramClean]) {
                    NSRange range = NSMakeRange(location, string.length);
                    if (!supposedInstagram || (supposedInstagram && abs((int)range.location - (int)supposedInstagramRange.location) < closeIndex)) {
                        supposedInstagram = string;
                        supposedInstagramRange = range;
                        closeIndex = abs((int)range.location - (int)supposedInstagramRange.location);
                        *stop = YES;
                    }
                }
                location += string.length + 1;
            }];
            if (supposedInstagram) {
                NSLog(@"Instagram found: %@", supposedInstagram);

                // Check presence on Instagram
                NSString *instaBase = [NSString stringWithFormat:@"https://www.instagram.com/%@/", supposedInstagram];
                /*[[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:[instaBase stringByAppendingString:@"?__a=1"]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    if (!error) {
                        id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                        if (!error || ![json isKindOfClass:[NSDictionary class]]) {
                            if ([(NSDictionary *)json count] != 0) {
                                NSLog(@"Instagram exists online, applying modifications to text.");*/
                                // Editing bio
                                NSMutableAttributedString *newBio = [textView.attributedText mutableCopy];
                                [newBio addAttribute:NSLinkAttributeName value:[NSURL URLWithString:instaBase] range:supposedInstagramRange];
                                // dispatch_async(dispatch_get_main_queue(), ^{
                                    textView.attributedText = newBio;
                                    NSLog(@"Hyperlink applied.");
                                /*});
                            } else {
                                NSLog(@"Instagram user \"%@\" not found online.", supposedInstagram);
                            }
                        } else {
                            NSLog(@"An error occurred while parsing API result: %@\n(String: %@)", error, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                        }
                    } else {
                        NSLog(@"An error occurred with API: %@", error);
                    }
                }] resume];*/
            } else {
                NSLog(@"A weird error occurred in the last part of Instagram parsing (username not found in original text)");
            }
        } else {
            NSLog(@"No instagram found.");
        }
    } else {
        // Dark mode
        NSLog(@"Enabling dark mode in non-bio RCTTextView");
        NSMutableDictionary *attributes = [[textStorage attributesAtIndex:0 effectiveRange:nil] mutableCopy];
        if (attributes[NSForegroundColorAttributeName]) {
            attributes[NSForegroundColorAttributeName] = [UIColor peach_systemTextColorIfEligible:attributes[NSForegroundColorAttributeName]];
            [textStorage setAttributes:attributes range:NSMakeRange(0, textStorage.length)];
        }

        %orig(textStorage, contentFrame, descendantViews);
    }
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
                                NSLog(@"Removing button %p after detecting %p", self.superview.superview, self);
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
%hook RCTRootView

- (void)willMoveToWindow:(UIWindow *)arg1 {
    %orig;
    self.backgroundColor = [UIColor peach_systemBackgroundColorIfEligible:self.backgroundColor];
}

- (void)willMoveToSuperview:(UIView *)arg1 {
    %orig;
    self.backgroundColor = [UIColor peach_systemBackgroundColorIfEligible:self.backgroundColor];
}

- (UIColor *)backgroundColor {
    return [UIColor peach_systemBackgroundColorIfEligible:%orig];
}

%end

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
