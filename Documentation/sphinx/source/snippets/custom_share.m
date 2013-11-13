//
//  custom_share.m
//  Loopy SDK
//
//  Created by David Jedeikin on 11/5/13.
//  Copyright (c) 2013 ShareThis, Inc. All rights reserved.
//

#import "custom_share.h"
#import "custom_activity.h"
#import "SZAPIClient.h"
#import "SZActivity.h"
#import <Social/Social.h>

@implementation CustomShareViewController

// begin-custom-share-snippet

//Returns a shortened URL
- (void)shortenURL:(NSString *)url {
    SZAPIClient *apiClient = [[SZAPIClient alloc] initWithURLPrefix:@"http://loopy-api-url-prefix"];
    NSDictionary *jsonDict = [self jsonForShortlink:url];
    [apiClient shortlink:(NSDictionary *)jsonDict withCallback:^(NSURLResponse *response, NSData *data, NSError *error) {
        id responseData = [data objectFromJSONData];
        BOOL success = (error == nil) && ([responseData isKindOfClass:[NSDictionary class]]);
        if(success) {
            NSDictionary *responseDict = (NSDictionary *)responseData;
            if([responseDict count] == 1 && [responseDict valueForKey:@"shortlink"]) {
                
                //initialization code for UIActivity
                NSString *shortlink = (NSString *)[responseDict valueForKey:@"shortlink"];
                NSArray *activityItems = @[shortlink];
                MyCustomActivity *activity = [MyCustomActivity initWithActivityItems:activityItems];
                
                //Your UI code goes here
                //...
                //Once share is successful for the specified activity, call this notification:
                [[NSNotificationCenter defaultCenter] postNotificationName:EndShareNotification object:activity];
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

// end-custom-share-snippet


@end
