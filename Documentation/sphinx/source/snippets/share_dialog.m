//
//  share_dialog.m
//  Loopy SDK
//
//  Created by David Jedeikin on 11/5/13.
//  Copyright (c) 2013 ShareThis, Inc. All rights reserved.
//

#import "share_dialog.h"
#import "custom_activity.h"
#import "SZShare.h"
#import "SZAPIClient.h"
#import <Social/Social.h>

@implementation ShareDialogViewController

// begin-show-share-dialog-snippet

//Returns a shortened URL then launches the Share Dialog
- (IBAction)shareButtonPressed:(id)sender {
    SZShare *share = [[SZShare alloc] initWithParent:self];
    SZAPIClient *apiClient = [[SZAPIClient alloc] initWithURLPrefix:@"http://loopy-api-url-prefix"];
    NSDictionary *jsonDict = [self jsonForShortlink:@"www.very-long-url.com"];
    [apiClient shortlink:(NSDictionary *)jsonDict withCallback:^(NSURLResponse *response, NSData *data, NSError *error) {
        id responseData = [data objectFromJSONData];
        BOOL success = (error == nil) && ([responseData isKindOfClass:[NSDictionary class]]);
        if(success) {
            NSDictionary *responseDict = (NSDictionary *)responseData;
            if([responseDict count] == 1 && [responseDict valueForKey:@"shortlink"]) {
                NSString *shortlink = (NSString *)[responseDict valueForKey:@"shortlink"];
                NSArray *activityItems = @[shortlink];
                NSArray *activities = [share getDefaultActivities:activityItems];
                UIActivityViewController * activityController = [share newActivityViewController:activityItems
                                                                                  withActivities:activities];
                [share showActivityViewDialog:activityController completion:nil];
            }
        }
        else {
            //error
        }
    }];
}

//This is a sample of JSON needed for the "shortlink" API call
- (NSDictionary *)jsonForShortlink:(NSString *)urlStr {
    NSDictionary *itemObj = [NSDictionary dictionaryWithObjectsAndKeys:
                             urlStr,@"url",
                             nil];
    NSDictionary *shortlinkObj = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"69",@"stdid",
                                  [NSNumber numberWithInt:1234567890],@"timestamp",
                                  itemObj,@"item",
                                  [NSArray arrayWithObjects:@"sports", @"entertainment", nil],@"tags",
                                  nil];
    
    return shortlinkObj;
}

// end-show-share-dialog-snippet


// begin-show-custom-activity-snippet

//This is an example of an activity controller with custom UIActivities added in
- (UIActivityViewController *)activityControllerWithCustomActivities:(NSArray *)activityItems {
    SZShare *share = [[SZShare alloc] initWithParent:self];
    NSArray *defaultActivities = [share getDefaultActivities:activityItems];
    
    //add in any custom activities
    NSMutableArray *allActivities = [NSMutableArray arrayWithArray:defaultActivities];
    MyCustomActivity *customActivity = [MyCustomActivity initWithActivityItems:activityItems];
    [allActivities addObject:customActivity];
    
    UIActivityViewController *activityController = [share newActivityViewController:activityItems
                                                                     withActivities:allActivities];
    
    return activityController;
}

// end-show-custom-activity-snippet

@end
