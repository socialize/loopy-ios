//
//  SZFacebookActivity.m
//  Loopy
//
//  Created by David Jedeikin on 10/17/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "SZFacebookActivity.h"
#import "SZConstants.h"
#import <Social/Social.h>

@implementation SZFacebookActivity

@synthesize shareItems;

//new activity with specified share items
+ (id)initWithActivityItems:(NSArray *)items {
    SZFacebookActivity *newActivity = [[SZFacebookActivity alloc] init];
    if(newActivity) {
        newActivity.shareItems = items;
    }
    
    return newActivity;
}

- (NSString *)activityTitle {
    return @"Facebook";
}

- (NSString *)activityType {
    return SLServiceTypeFacebook;
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
    return [self.shareItems isEqualToArray:activityItems];
}

//Notification of intent to share
- (void)prepareWithActivityItems:(NSArray *)activityItems {
    self.shareItems = activityItems;
    [[NSNotificationCenter defaultCenter] postNotificationName:BeginShareNotification object:self];
}

//Notification of share initiated
- (void)activityDidFinish:(BOOL)completed {
    [[NSNotificationCenter defaultCenter] postNotificationName:EndShareNotification object:self];
}

@end
