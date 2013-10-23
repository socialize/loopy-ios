//
//  SZTwitterActivity.m
//  Loopy
//
//  Created by David Jedeikin on 10/17/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "SZTwitterActivity.h"
#import "SZConstants.h"

@implementation SZTwitterActivity

- (id)init {
    self = [super init];
    if(self) {
        //anything special can happen here
    }
    return self;
    
}
- (NSString *)activityTitle {
    return @"Twitter";
}

- (NSString *)activityType {
    return @"com.sharethis.twitterSharing";
}

//overrides private UI for image to prevent B&W look & feel
//- (UIImage *)_activityImage {
//    UIImage *image = [UIImage imageNamed:@"TwitterIconMedium.png"];
//    return image;
//}

- (UIImage *)activityImage {
    UIImage *image = nil;
    BOOL isIPhone = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
    BOOL isIOS7 = YES;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        isIOS7 = NO;
    }
    
    if((isIOS7 && isIPhone) || (!isIOS7 && !isIPhone)) {
        image = [UIImage imageNamed:@"TwitterLogo60x60.png"];
    }
    else if(!isIOS7 && isIPhone) {
        image = [UIImage imageNamed:@"TwitterLogo43x43.png"];
    }
    else if(isIOS7 && !isIPhone) {
        image = [UIImage imageNamed:@"TwitterLogo76x76.png"];
    }
    
    return image;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

//Notification of intent to share and such can happen here
- (void)prepareWithActivityItems:(NSArray *)activityItems {
    NSLog(@"PRE-SHARE!!");
    for (NSObject *item in activityItems) {
        //        if ([item isKindOfClass:[NSString class]]) {
        //            self.text = (NSString *)item;
        //        } else if ([item isKindOfClass:[NSURL class]]) {
        //            self.url = (NSURL *)item;
        //        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:BeginShareNotification object:self];
}

//Notification of all done can happen here
- (void)activityDidFinish:(BOOL)completed {
    NSLog(@"FINISHED");
}
@end
