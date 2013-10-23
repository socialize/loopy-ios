//
//  SZFacebookActivity.m
//  Loopy
//
//  Created by David Jedeikin on 10/17/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "SZFacebookActivity.h"
#import "SZConstants.h"

@implementation SZFacebookActivity

- (id)init {
    self = [super init];
    if(self) {
        //anything special can happen here
    }
    return self;
    
}
- (NSString *)activityTitle {
    return @"Facebook";
}

- (NSString *)activityType {
    return @"com.sharethis.facebookSharing";
}

- (UIImage *)activityImage {
    UIImage *image = nil;
    BOOL isIPhone = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
    BOOL isIOS7 = YES;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        isIOS7 = NO;
    }
    
    if((isIOS7 && isIPhone) || (!isIOS7 && !isIPhone)) {
        image = [UIImage imageNamed:@"FacebookLogoNoBlue60x60.png"];
    }
    else if(!isIOS7 && isIPhone) {
        image = [UIImage imageNamed:@"FacebookLogoNoBlue43x43.png"];
    }
    else if(isIOS7 && !isIPhone) {
        image = [UIImage imageNamed:@"FacebookLogoNoBlue76x76.png"];
    }
    
    return image;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

//Notification of intent to share and such can happen here
- (void)prepareWithActivityItems:(NSArray *)activityItems {
    NSLog(@"PRE-SHARE!!");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BeginShareNotification object:self];
    
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
