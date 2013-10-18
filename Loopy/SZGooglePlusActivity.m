//
//  SZGooglePlusActivity.m
//  Loopy
//
//  Created by David Jedeikin on 10/15/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "SZGooglePlusActivity.h"

@implementation SZGooglePlusActivity

- (id)init {
    self = [super init];
    if(self) {
        //anything special can happen here
    }
    return self;
    
}
- (NSString *)activityTitle {
    return @"Google+";
}

- (NSString *)activityType {
    return @"com.sharethis.googlePlusSharing";
}

//overrides private UI for image to prevent B&W look & feel
//- (UIImage *)_activityImage {
//    UIImage *image = [UIImage imageNamed:@"GooglePlusIconMedium.png"];
//    return image;
//}

- (UIImage *)activityImage {
    UIImage *image = nil;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    BOOL isRetina = NO;
    BOOL isIPhone = screenWidth == 320; //TODO this might change...
    BOOL isIOS7 = YES;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0)) {
        isRetina = YES;
    }
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        isIOS7 = NO;
    }
    
    //TODO not very elegant
    if(isIOS7 && isIPhone && isRetina) {
        image = [UIImage imageNamed:@"GooglePlusLogo60x60.png"];
    }
    else if(!isIOS7 && isIPhone && isRetina) {
        image = [UIImage imageNamed:@"GooglePlusLogo43x43.png"];
    }
    else if(isIOS7 && !isIPhone && isRetina) {
        image = [UIImage imageNamed:@"GooglePlusLogo76x76.png"];
    }
    else if(!isIOS7 && !isIPhone && isRetina) {
        image = [UIImage imageNamed:@"GooglePlusLogo60x60.png"];
    }
    else if(isIOS7 && !isIPhone && !isRetina) {
        image = [UIImage imageNamed:@"GooglePlusLogo76x76.png"];
    }
    else if(!isIOS7 && !isIPhone && !isRetina) {
        image = [UIImage imageNamed:@"GooglePlusLogo60x60.png"];
    }
    else if(!isIOS7 && isIPhone && !isRetina) {
        image = [UIImage imageNamed:@"GooglePlusLogo43x43.png"];
    }
    else if(isIOS7 && isIPhone && !isRetina) {
        image = [UIImage imageNamed:@"GooglePlusLogo60x60.png"];
    }

    return image;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

//Notification of intent to share and such can happen here
- (void)prepareWithActivityItems:(NSArray *)activityItems {
    for (NSObject *item in activityItems) {
//        if ([item isKindOfClass:[NSString class]]) {
//            self.text = (NSString *)item;
//        } else if ([item isKindOfClass:[NSURL class]]) {
//            self.url = (NSURL *)item;
//        }
    }
}

//Notification of all done can happen here
- (void)activityDidFinish:(BOOL)completed {
    NSLog(@"FINISHED");
}
@end
