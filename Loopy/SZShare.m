//
//  SZShare.m
//  Loopy
//
//  Created by David Jedeikin on 10/23/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "SZShare.h"
#import "SZActivity.h"
#import "SZFacebookActivity.h"
#import "SZTwitterActivity.h"
#import "SZConstants.h"

@implementation SZShare

@synthesize parentController;

- (id)initWithParent:(UIViewController *)parent {
    self = [super init];
    if(self) {
        self.parentController = parent;
        //listen for share events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleShowActivityShare:)
                                                     name:BeginShareNotification
                                                   object:nil];
    }
    
    return self;
}

//Returns the current available set of Activities using the specified activity items
//TODO determine which services are active or not
- (NSArray *)getCurrentActivities:(NSArray *)activityItems {
    SZFacebookActivity *fbActivity = [SZFacebookActivity initWithActivityItems:activityItems];
    SZTwitterActivity *twitterActivity = [SZTwitterActivity initWithActivityItems:activityItems];
    
    return @[fbActivity, twitterActivity];
}

//Returns UIActivityViewController for specified items and activities
//This is the ViewController to SELECT Activity (i.e. social network) to share
- (UIActivityViewController *)newActivityViewController:(NSArray *)shareItems withActivities:(NSArray *)activities {
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:shareItems
                                                                                         applicationActivities:activities];
    activityViewController.excludedActivityTypes = @[UIActivityTypePostToFacebook,
                                                     UIActivityTypePostToTwitter,
                                                     UIActivityTypePostToWeibo,
                                                     UIActivityTypeMail,
                                                     UIActivityTypeCopyToPasteboard];
    return activityViewController;
}

//Returns SLComposeViewController with specified activity items for specified service type
//The is the view controller to share the activity items to a specified social network
//TODO for now simply assumes first activity item is a NSString shortlink
- (SLComposeViewController *)newActivityShareController:(id)activityObj {
    NSString *slServiceType = nil;
    NSArray *activityItems = nil;
    SLComposeViewController *controller = nil;
    
    if([[activityObj class] conformsToProtocol:@protocol(SZActivity)]) {
        id<SZActivity> activity = (id<SZActivity>)activityObj;
        activityItems = [activity shareItems];
        slServiceType = [activity activityType];
    }

    controller = [SLComposeViewController composeViewControllerForServiceType:slServiceType];
    if([activityItems count] > 0) {
        id firstItem = [activityItems objectAtIndex:0];
        if([firstItem isKindOfClass:[NSString class]]) {
            NSString *shareMessage = [NSString stringWithFormat:@"Check out this link: %@", (NSString *)firstItem];
            [controller setInitialText:shareMessage];
        }
    }
    
    return controller;
}

#pragma mark - UI operations

//Shows main share selector dialog
- (void)showActivityViewDialog:(UIActivityViewController *)activityController completion:(void (^)(void))completion {
    [self.parentController presentViewController:activityController animated:YES completion:completion];
}

//Shows activity-specific dialog (share to Facebook, Twitter, etc)
- (void)showActivityShareDialog:(SLComposeViewController *)controller {
    [self.parentController presentViewController:controller animated:YES completion:Nil];
}

//Shows specific share dialog for selected service
//TODO will need to include all social network types
- (BOOL)handleShowActivityShare:(NSNotification *)notification {
    //dismiss controller and bring up share dialog
    [self.parentController dismissViewControllerAnimated:YES completion:^ {
        SLComposeViewController *controller = [self newActivityShareController:[notification object]];
        [self.parentController presentViewController:controller animated:YES completion:Nil];
    }];
    return YES;
}

@end
