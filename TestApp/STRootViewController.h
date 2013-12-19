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
@property (nonatomic, strong) IBOutlet UIButton *shareButton;

- (IBAction)installButtonPressed:(id)sender;
- (IBAction)shareButtonPressed:(id)sender;

@end
