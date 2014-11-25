//
//  custom_share.m
//  Loopy SDK
//
//  Created by David Jedeikin on 11/5/13.
//  Copyright (c) 2013 ShareThis, Inc. All rights reserved.
//

#import "custom_share.h"
#import "custom_activity.h"
#import "STConstants.h"
#import "STAPIClient.h"
#import "STActivity.h"
#import <Social/Social.h>

@implementation CustomShareViewController

// begin-custom-share-snippet

- (void)shortenAndShareWithCustomUI:(NSString *)url {
    
    //init this and begin its session elsewhere
    STAPIClient *apiClient;
    
    NSArray *tags = [NSArray arrayWithObjects:@"tag1", @"tag2", nil];
    STShortlink *shortlinkObj = [apiClient shortlinkWithURL:@"www.UrlToShorten.com" title:nil meta:nil tags:tags];
    [apiClient shortlink:shortlinkObj
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     
                     //use the shortlink in the activity dialog
                     NSDictionary *responseDict = (NSDictionary *)responseObject;
                     NSString *shortlink = (NSString *)[responseDict valueForKey:@"shortlink"];
                     NSArray *activityItems = @[shortlink];
                     
                     //assumes you have a custom activity, though you can use the Loopy STFacebookActivity and STTwitterActivity as well
                     MyCustomActivity *activity = [[MyCustomActivity alloc] init];
                     [activity prepareWithActivityItems:activityItems];

                     //Your custom UI sharing code goes here
                     //...
                     
                     //when your custom UI receives notification of a successful share, call this:
                     [[NSNotificationCenter defaultCenter] postNotificationName:LoopyShareDidComplete object:activity];

                     //if user cancels before sharing in your custom UI, call this:
                     [[NSNotificationCenter defaultCenter] postNotificationName:LoopyShareDidCancel object:activity];

                     //Assuming share is called and is successful, call this to record with Loopy:
                     STShare *shareObj = [apiClient reportShareWithShortlink:shortlink
                                                                     channel:activity.activityType];
                     [apiClient reportShare:shareObj
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        [[NSNotificationCenter defaultCenter] postNotificationName:LoopyRecordShareDidSucceed object:responseObject];
                                    }
                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        [[NSNotificationCenter defaultCenter] postNotificationName:LoopyRecordShareDidFail object:error];
                                    }];
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     //any failure handling
                 }];
}

// end-custom-share-snippet


@end
