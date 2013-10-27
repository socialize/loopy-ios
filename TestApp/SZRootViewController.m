//
//  SZRootViewController.m
//  Loopy
//
//  Created by David Jedeikin on 10/8/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "SZRootViewController.h"
#import "SZShare.h"
#import <Social/Social.h>

@interface SZRootViewController ()
@end

@implementation SZRootViewController

SZShare *share;

@synthesize textField;
@synthesize shareButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        share = [[SZShare alloc] initWithParent:self];
    }
    return self;
}

- (void) viewDidLoad {
    textField.text = @"sample text";
}

- (IBAction)shareButtonPressed:(id)sender {
    NSArray *activities = [share getCurrentActivities];
    UIActivityViewController * activityController = [share newActivityViewController:@[self.textField.text]  //TODO more meaningful activity
                                                                      withActivities:activities];
    [share showShareDialog:activityController];
}

@end
