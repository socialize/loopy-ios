//
//  STRootViewController.m
//  Loopy
//
//  Created by David Jedeikin on 10/8/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "STRootViewController.h"
#import "STShareActivityUI.h"
#import "STSharelink.h"
#import "STAPIClient.h"
#import "STJSONUtils.h"
#import "STObject.h"
#import "STIdentifier.h"
#import "STItem.h"
#import "STShortlink.h"
#import <Social/Social.h>
#import <AFNetworking/AFNetworking.h>

@interface STRootViewController ()
@end

@implementation STRootViewController

STShareActivityUI *share;
STAPIClient *apiClient;

@synthesize textField;
@synthesize installButton;
@synthesize shortlinkButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        apiClient = [[STAPIClient alloc] initWithAPIKey:@"73e0eeb1-5a3e-4603-b85a-21025d9847fc"
                                               loopyKey:@"nq225rg5m4ekx87uss9te56e"
                                      locationsDisabled:NO];

        //for testing, use internal API for now
        apiClient.urlPrefix = @"http://internal.loopy.getsocialize.com/v1";
        apiClient.httpsURLPrefix = @"http://internal.loopy.getsocialize.com/v1";

        [apiClient getSessionWithReferrer:@"www.facebook.com"
            postSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Good To Go"
                                                                message:@"Loopy session started!"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"FAILURE"
                                                                message:@"No session."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                [self.installButton setEnabled:NO];
                [self.sharelinkButton setEnabled:NO];
                [self.shortlinkButton setEnabled:NO];
            }];
        
        share = [[STShareActivityUI alloc] initWithParent:self apiClient:apiClient];
    }
    return self;
}

- (void)viewDidLoad {
    textField.text = @"http://www.sharethis.com";
}

//shorten
- (IBAction)shortlinkButtonPressed:(id)sender {
    NSArray *tags = [NSArray arrayWithObjects:@"sports", @"entertainment", nil];
    STShortlink *shortlinkObj = [apiClient shortlinkWithURL:self.textField.text title:nil meta:nil tags:tags];
    [apiClient shortlink:shortlinkObj
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     NSDictionary *responseDict = (NSDictionary *)responseObject;
                     if([responseDict count] == 1 && [responseDict valueForKey:@"shortlink"]) {
                         NSString *shortlink = (NSString *)[responseDict valueForKey:@"shortlink"];
                         NSArray *activityItems = @[shortlink];
                         NSArray *activities = [share getDefaultActivities:activityItems];
                         UIActivityViewController * activityController = [share newActivityViewController:activityItems
                                                                                          withActivities:activities];
                         [share showActivityViewDialog:activityController completion:nil];
                     }
                     else {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"FAILURE"
                                                                         message:@"Shortlink returned empty value."
                                                                        delegate:nil
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil];
                         [alert show];
                     }
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"FAILURE"
                                                                     message:@"Shortlink failed."
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
                     [alert show];
                 }];
}

//shorten then share in one operation
- (IBAction)sharelinkButtonPressed:(id)sender {
    NSArray *tags = [NSArray arrayWithObjects:@"sports", @"entertainment", nil];
    STSharelink *sharelinkObj = [apiClient sharelinkWithURL:self.textField.text
                                                    channel:@"facebook"
                                                      title:nil
                                                       meta:nil
                                                       tags:tags];
    [apiClient sharelink:sharelinkObj
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     NSDictionary *responseDict = (NSDictionary *)responseObject;
                     NSString *shortlink = [responseDict objectForKey:@"shortlink"];
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SUCCESS"
                                                                     message:shortlink
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
                     [alert show];
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"FAILURE"
                                                                     message:@"Sharelink failed."
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
                     [alert show];
                 }];
}

//install with device ID
- (IBAction)installButtonPressed:(id)sender {
    STInstall *installObj = [apiClient installWithReferrer:@"www.facebook.com"];//[self installObj];
    [apiClient install:installObj
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SUCCESS"
                                                                   message:@"Install succeeded."
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
                   [alert show];
               }
               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"FAILURE"
                                                                   message:@"Install failed."
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
                   [alert show];
               }];
}

@end
