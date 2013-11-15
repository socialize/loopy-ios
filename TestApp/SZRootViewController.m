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
#import <Social/Social.h>

@interface SZRootViewController ()
@end

@implementation SZRootViewController

SZShare *share;
SZAPIClient *apiClient;

@synthesize textField;
@synthesize shareButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSBundle *bundle =  [NSBundle bundleForClass:[self class]];
        NSString *configPath = [bundle pathForResource:@"LoopyApiInfo" ofType:@"plist"];
        NSDictionary *configurationDict = [[NSDictionary alloc]initWithContentsOfFile:configPath];
        NSDictionary *apiInfoDict = [configurationDict objectForKey:@"Loopy API info"];
        NSString *urlPrefix = [apiInfoDict objectForKey:@"urlPrefix"];

        apiClient = [[SZAPIClient alloc] initWithURLPrefix:urlPrefix];
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
