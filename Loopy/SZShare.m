//
//  SZShare.m
//  Loopy
//
//  Created by David Jedeikin on 10/23/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "SZShare.h"
#import "SZGooglePlusActivity.h"
#import "SZFacebookActivity.h"
#import "SZTwitterActivity.h"
#import "SZPinterestActivity.h"
#import "SZConstants.h"
#import <Social/Social.h>

@implementation SZShare

@synthesize parentController;

- (id)initWithParent:(UIViewController *)parent {
    self = [super init];
    if(self) {
        self.parentController = parent;
        //listen for share events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleBeginShare:)
                                                     name:BeginShareNotification
                                                   object:nil];
    }
    
    return self;
}

//Returns the current enabled set of Activities
- (NSArray *)getCurrentActivities {
    //TODO determine which services are active or not
//    SZGooglePlusActivity *gPlusActivity = [[SZGooglePlusActivity alloc] init];
    SZFacebookActivity *fbActivity = [[SZFacebookActivity alloc] init];
    SZTwitterActivity *twitterActivity = [[SZTwitterActivity alloc] init];
//    SZPinterestActivity *pinterestActivity = [[SZPinterestActivity alloc] init];
    
    return @[fbActivity, twitterActivity];//, gPlusActivity, pinterestActivity]];}
}

//Returns UIActivityViewController for specified items and activities
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

//Shows main share selector dialog
- (void)showShareDialog:(UIActivityViewController *)activityController completion:(void (^)(void))completion {
    [self.parentController presentViewController:activityController animated:YES completion:completion];
}

//Shows specific share dialog for selected service
- (BOOL)handleBeginShare:(NSNotification *)notification {
    //TODO will need to include all types
    __block NSString *slServiceType = nil;
    if([[notification object] isKindOfClass:[SZFacebookActivity class]]) {
        slServiceType = SLServiceTypeFacebook;
    }
    else if([[notification object] isKindOfClass:[SZTwitterActivity class]]) {
        slServiceType = SLServiceTypeTwitter;
    }
    
    //dismiss controller and bring up share dialog
    [self.parentController dismissViewControllerAnimated:YES completion:^ {
        if([SLComposeViewController isAvailableForServiceType:slServiceType]) {
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:slServiceType];
            
            [controller setInitialText:@"First post from my iPhone app"]; //TODO share link
            [self.parentController presentViewController:controller animated:YES completion:Nil];
        }
        //TODO this should probably be in the logic to display share buttons
        else {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Not enabled"
                                                              message:@"The specified social network is not enabled on your device."
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [message show];
        }
    }];
    return YES;
}

@end
