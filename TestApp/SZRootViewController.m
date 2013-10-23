//
//  SZRootViewController.m
//  Loopy
//
//  Created by David Jedeikin on 10/8/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "SZRootViewController.h"
#import "SZGooglePlusActivity.h"
#import "SZFacebookActivity.h"
#import "SZTwitterActivity.h"
#import "SZPinterestActivity.h"
#import "SZConstants.h"
#import <Social/Social.h>

@interface SZRootViewController ()

@end

@implementation SZRootViewController

@synthesize textField;
@synthesize shareButton;
@synthesize activityViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void) viewDidLoad {
    textField.text = @"sample text";

    //listen for share events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleBeginShare:)
                                                 name:BeginShareNotification
                                               object:nil];
}

- (IBAction)shareButtonPressed:(id)sender {
    SZGooglePlusActivity *gPlusActivity = [[SZGooglePlusActivity alloc] init];
    SZFacebookActivity *fbActivity = [[SZFacebookActivity alloc] init];
    SZTwitterActivity *twitterActivity = [[SZTwitterActivity alloc] init];
    SZPinterestActivity *pinterestActivity = [[SZPinterestActivity alloc] init];

    self.activityViewController = [[UIActivityViewController alloc]
                                   initWithActivityItems:@[self.textField.text]
                                   applicationActivities:@[fbActivity, twitterActivity, gPlusActivity, pinterestActivity]];
    self.activityViewController.excludedActivityTypes = @[UIActivityTypePostToFacebook,
                                                          UIActivityTypePostToTwitter,
                                                          UIActivityTypePostToWeibo,
                                                          UIActivityTypeMail,
                                                          UIActivityTypeCopyToPasteboard];
    
    [self presentViewController:self.activityViewController animated:YES completion:nil];
}

-(void)handleBeginShare:(NSNotification *)notification {
    NSLog(@"#1 received message = %@",(NSString*)[notification object]);
    //TODO will need to include all types
    __block NSString *slServiceType = nil;
    if([[notification object] isKindOfClass:[SZFacebookActivity class]]) {
        slServiceType = SLServiceTypeFacebook;
    }
    else if([[notification object] isKindOfClass:[SZTwitterActivity class]]) {
        slServiceType = SLServiceTypeTwitter;
    }
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:^ {
        if([SLComposeViewController isAvailableForServiceType:slServiceType]) {
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:slServiceType];
            
            [controller setInitialText:@"First post from my iPhone app"];
            [self presentViewController:controller animated:YES completion:Nil];
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
}

@end
