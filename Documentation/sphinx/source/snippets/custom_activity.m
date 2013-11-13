//
//  custom_activity.m
//  Loopy
//
//  Created by David Jedeikin on 11/12/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "custom_activity.h"
#import "SZConstants.h"

// begin-custom-activity-snippet

@implementation MyCustomActivity

@synthesize shareItems;

//Standard UIActivity implementation
- (NSString *)activityTitle {
    return @"MyCustomActivity";
}

//Standard UIActivity implementation
- (NSString *)activityType {
    return @"MyActivityType";
}

//Standard UIActivity implementation
- (UIImage *)activityImage {
    UIImage *image = nil;
    
    //return an image that's appropriately sized for all devices and OSes:
    //iOS 7 iPhone and non-iOS7 iPads: 60x60
    //non-iOS7 iPhone: 43 x 43
    //iOS 7 iPad: 76 x 76
    
    return image;
}

//Any final checking of activities or sharing service passed in can be done here
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

//Notification of intent to share
//Set shareItems and post notification here
- (void)prepareWithActivityItems:(NSArray *)activityItems {
    self.shareItems = activityItems;
    [[NSNotificationCenter defaultCenter] postNotificationName:BeginShareNotification object:self];
}

@end

// end-custom-activity-snippet
