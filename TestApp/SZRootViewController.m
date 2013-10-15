//
//  SZRootViewController.m
//  Loopy
//
//  Created by David Jedeikin on 10/8/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "SZRootViewController.h"
#import "SZGooglePlusActivity.h"

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
}

- (IBAction)shareButtonPressed:(id)sender {
    SZGooglePlusActivity *gPlusActivity = [[SZGooglePlusActivity alloc] init];
    self.activityViewController = [[UIActivityViewController alloc]
                                   initWithActivityItems:@[self.textField.text]
                                   applicationActivities:@[gPlusActivity]];
    self.activityViewController.excludedActivityTypes = @[UIActivityTypePostToFacebook,
                                                          UIActivityTypePostToTwitter,
                                                          UIActivityTypeMail,
                                                          UIActivityTypeCopyToPasteboard
                                                          ];
    
    [self presentViewController:self.activityViewController animated:YES completion:nil];
}

@end
