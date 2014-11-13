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
                //any failure operations
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
    STShortlink *shortlinkObj = [self shortlinkObj:self.textField.text];
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
                         NSLog(@"FAILURE");
                     }
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"FAILURE");
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
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                     message:shortlink
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
                     [alert show];
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"FAILURE");
                 }];
}

//install with device ID
- (IBAction)installButtonPressed:(id)sender {
    STInstall *installObj = [self installObj];
    [apiClient install:installObj
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   NSDictionary *responseDict = (NSDictionary *)responseObject;
                   NSString *responseSTDID = (NSString *)[responseDict valueForKey:@"stdid"];
                   NSLog(@"SUCCESS: %@", responseSTDID);
               }
               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   NSLog(@"FAILURE");
               }];
}

- (STInstall *)installObj {
    STGeo *geo = [[STGeo alloc] init];
    geo.lat = [NSNumber numberWithDouble:12.456];
    geo.lon = [NSNumber numberWithDouble:78.900];
    
    STDevice *device = [[STDevice alloc] init];
    device.id = @"ABCD-1234";
    device.model = @"iPhone 6";
    device.os = @"ios";
    device.osv = @"8.1";
    device.carrier = @"verizon";
    device.geo = geo;
    device.wifi = @"on";
    
    STApp *app = [[STApp alloc] init];
    app.id = @"com.socialize.appname";
    app.name = @"App Name";
    app.version = @"123.4";
    
    STClient *client = [[STClient alloc] init];
    client.lang = @"objc";
    client.version = @"1.3";
    
    STInstall *install = [[STInstall alloc] init];
    install.timestamp = [NSNumber numberWithInt:123456];
    install.referrer = @"www.facebook.com";
    install.device = device;
    install.app = app;
    install.client = client;

    return install;
}

- (STShortlink *)shortlinkObj:(NSString *)urlStr {
    STItem *item = [[STItem alloc] init];
    item.url = urlStr;
    
    STShortlink *shortlink = [[STShortlink alloc] init];
    shortlink.stdid = @"69";
    shortlink.timestamp = [NSNumber numberWithInt:1234567890];
    shortlink.item = item;
    shortlink.tags = [NSArray arrayWithObjects:@"sports", @"entertainment", nil];

    return shortlink;
}

@end
