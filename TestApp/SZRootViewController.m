//
//  SZRootViewController.m
//  Loopy
//
//  Created by David Jedeikin on 10/8/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "SZRootViewController.h"
#import "SZShare.h"
#import "SZAPIClient.h"
#import "SZJSONUtils.h"
#import <Social/Social.h>
#import <AFNetworking/AFNetworking.h>
#import "SZTestUtils.h"

@interface SZRootViewController ()
@end

@implementation SZRootViewController

SZShare *share;
SZAPIClient *apiClient;

@synthesize textField;
@synthesize installButton;
@synthesize shareButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        apiClient = [[SZAPIClient alloc] initWithAPIKey:@"hkg435723o4tho95fh29"
                                               loopyKey: @"4q7cd6ngw3vu7gram5b9b9t6"];
        [apiClient getSessionWithReferrer:@"www.facebook.com"
            postSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                //any operations post-successful /install or /open
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                //any failure operations
            }];
        
        share = [[SZShare alloc] initWithParent:self apiClient:apiClient];
    }
    return self;
}

- (void)viewDidLoad {
    textField.text = @"http://www.sharethis.com";
}

//shorten then share
- (IBAction)shareButtonPressed:(id)sender {
    NSDictionary *jsonDict = [self jsonForShortlink:self.textField.text];
    [apiClient shortlink:(NSDictionary *)jsonDict
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
                         NSLog(@"FAILURE");
                     }
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"FAILURE");
                 }];
}

//install with device ID
- (IBAction)installButtonPressed:(id)sender {
    NSDictionary *jsonDict = [self jsonForInstall];
    [apiClient install:jsonDict
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   NSDictionary *responseDict = (NSDictionary *)responseObject;
                   NSString *responseSTDID = (NSString *)[responseDict valueForKey:@"stdid"];
                   NSLog(@"SUCCESS: %@", responseSTDID);
               }
               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   NSLog(@"FAILURE");
               }];
}

- (NSDictionary *)jsonForInstall {
    NSDictionary *geoObj = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithDouble:12.456],@"lat",
                            [NSNumber numberWithDouble:78.900],@"lon",
                            nil];
    NSDictionary *deviceObj = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"ABCD-1234",@"id",
                               @"iPhone 4S",@"model",
                               @"ios",@"os",
                               @"6.1",@"osv",
                               @"verizon",@"carrier",
                               @"on",@"wifi",
                               geoObj,@"geo",
                               nil];
    NSDictionary *appObj = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"com.socialize.appname",@"id",
                            @"App Name",@"name",
                            @"123.4",@"version",
                            nil];
    NSDictionary *clientObj = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"objc",@"lang",
                               @"1.3",@"version",
                               nil];
    NSDictionary *installObj = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithInt:123456],@"timestamp",
                             @"www.facebook.com",@"referrer",
                             deviceObj,@"device",
                             appObj,@"app",
                             clientObj,@"client",
                             nil];
    return installObj;
}

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

@end
