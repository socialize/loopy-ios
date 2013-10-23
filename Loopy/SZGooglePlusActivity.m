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
    BOOL isIPhone = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
    BOOL isIOS7 = YES;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        isIOS7 = NO;
    }
    
    if((isIOS7 && isIPhone) || (!isIOS7 && !isIPhone)) {
        image = [UIImage imageNamed:@"GooglePlusLogo60x60.png"];
    }
    else if(!isIOS7 && isIPhone) {
        image = [UIImage imageNamed:@"GooglePlusLogo43x43.png"];
    }
    else if(isIOS7 && !isIPhone) {
        image = [UIImage imageNamed:@"GooglePlusLogo76x76.png"];
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
                                                      message:@"Google+ Sharing in Loopy."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
}

//Notification of all done can happen here
- (void)activityDidFinish:(BOOL)completed {
    NSLog(@"FINISHED");
}
@end
