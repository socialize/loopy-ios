//
//  share_dialog.m
//  Loopy SDK
//
//  Created by David Jedeikin on 11/5/13.
//  Copyright (c) 2013 ShareThis, Inc. All rights reserved.
//

#import "share_dialog.h"
#import "custom_activity.h"
#import "STConstants.h"
#import "STShareActivityUI.h"
#import "STAPIClient.h"
#import <Social/Social.h>

@implementation ShareDialogViewController

// begin-show-share-dialog-snippet

//Returns a shortened URL then launches the Share Dialog
- (IBAction)shortlinkButtonPressed:(id)sender {
    
    //init this and begin its session elsewhere
    STAPIClient *apiClient;

    //replace with your own view controller
    UIViewController *myViewController = [[UIViewController alloc] init];
    
    //EVENT HANDLING FOR SHARE ACTIVITIES (optional):
    
    //called when user taps on one of the social network or other share-type buttons
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleShareDidBegin:)
                                                 name:LoopyShareDidBegin
                                               object:nil];
    
    //called when user taps "Cancel" in the dialog to share to a particular social network
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleShareDidCancel:)
                                                 name:LoopyShareDidCancel
                                               object:nil];

    //called when item was shared successfully to a particular social network
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleShareDidComplete:)
                                                 name:LoopyShareDidComplete
                                               object:nil];

    //called when item was shared successfully to another medium (e.g. e-mail, SMS)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleActivityDidBegin:)
                                                 name:LoopyActivityDidComplete
                                               object:nil];

    //called when user taps "Cancel" from the activity dialog WITHOUT choosing a social network or other share type
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleActivityDidCancel:)
                                                 name:LoopyActivityDidCancel
                                               object:nil];

    //called when share was successfully recorded by Loopy
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRecordShareDidSucceed:)
                                                 name:LoopyRecordShareDidSucceed
                                               object:nil];

    //called when share FAILED to be recorded by Loopy
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRecordShareDidFail:)
                                                 name:LoopyRecordShareDidFail
                                               object:nil];
    
    //init share activity UI to build share dialog
    STShareActivityUI *share = [[STShareActivityUI alloc] initWithParent:myViewController apiClient:apiClient];
    NSArray *tags = [NSArray arrayWithObjects:@"tag1", @"tag2", nil];
    STShortlink *shortlinkObj = [apiClient shortlinkWithURL:@"www.UrlToShorten.com" title:nil meta:nil tags:tags];
    [apiClient shortlink:shortlinkObj
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                       
                       //use the shortlink in the activity dialog
                       NSDictionary *responseDict = (NSDictionary *)responseObject;
                       NSString *shortlink = (NSString *)[responseDict valueForKey:@"shortlink"];
                       NSArray *activityItems = @[shortlink];
                       NSArray *activities = [share getDefaultActivities:activityItems];
                       UIActivityViewController * activityController = [share newActivityViewController:activityItems
                                                                                         withActivities:activities];
                       [share showActivityViewDialog:activityController completion:nil];
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       //any failure handling
                 }];
}

// end-show-share-dialog-snippet


// begin-show-custom-activity-snippet

//This is an example of an activity controller with custom UIActivities added in
- (UIActivityViewController *)activityControllerWithCustomActivities:(NSArray *)activityItems {
//    STShare *share = [[STShare alloc] initWithParent:self];
//    NSArray *defaultActivities = [share getDefaultActivities:activityItems];
//    
//    //add in any custom activities
//    NSMutableArray *allActivities = [NSMutableArray arrayWithArray:defaultActivities];
//    MyCustomActivity *customActivity = [MyCustomActivity initWithActivityItems:activityItems];
//    [allActivities addObject:customActivity];
//    
//    UIActivityViewController *activityController = [share newActivityViewController:activityItems
//                                                                     withActivities:allActivities];
//    
//    return activityController;
    return nil;
}

// end-show-custom-activity-snippet

@end
