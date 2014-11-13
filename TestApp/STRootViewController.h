//
//  STRootViewController.h
//  Loopy
//
//  Created by David Jedeikin on 10/8/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STRootViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextField *textField;
@property (nonatomic, strong) IBOutlet UIButton *installButton;
@property (nonatomic, strong) IBOutlet UIButton *shortlinkButton;
@property (nonatomic, strong) IBOutlet UIButton *sharelinkButton;

- (IBAction)installButtonPressed:(id)sender;
- (IBAction)shortlinkButtonPressed:(id)sender;
- (IBAction)sharelinkButtonPressed:(id)sender;

@end
