//
//  SZPinterestActivity.m
//  Loopy
//
//  Created by David Jedeikin on 10/22/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "SZPinterestActivity.h"

@implementation SZPinterestActivity

@synthesize shareItems;

//new activity with specified share items
+ (id)initWithActivityItems:(NSArray *)items {
    SZPinterestActivity *newActivity = [[SZPinterestActivity alloc] init];
    if(newActivity) {
        newActivity.shareItems = items;
    }
    
    return newActivity;
}

- (NSString *)activityTitle {
    return @"Pinterest";
}

- (NSString *)activityType {
    return @"com.sharethis.pinterestSharing";
}

- (UIImage *)activityImage {
    UIImage *image = nil;
    BOOL isIPhone = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
    BOOL isIOS7 = YES;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        isIOS7 = NO;
    }
    
    if((isIOS7 && isIPhone) || (!isIOS7 && !isIPhone)) {
        image = [UIImage imageNamed:@"PinterestLogo60x60.png"];
    }
    else if(!isIOS7 && isIPhone) {
        image = [UIImage imageNamed:@"PinterestLogo43x43.png"];
    }
    else if(isIOS7 && !isIPhone) {
        image = [UIImage imageNamed:@"PinterestLogo76x76.png"];
    }
    
    return image;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

//Notification of intent to share and such can happen here
- (void)prepareWithActivityItems:(NSArray *)activityItems {
    NSLog(@"PRE-SHARE!!");
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Coming Soon"
                                                      message:@"Pinterest Sharing in Loopy."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
}

//Notification of all done can happen here
- (void)activityDidFinish:(BOOL)completed {
    NSLog(@"FINISHED");
}@end
