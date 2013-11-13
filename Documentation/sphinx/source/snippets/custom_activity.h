//
//  custom_activity.h
//  Loopy
//
//  Created by David Jedeikin on 11/12/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

// begin-custom-activity-snippet-header

#import <UIKit/UIKit.h>
#import "SZActivity.h"

@interface MyCustomActivity : UIActivity<SZActivity>

@property (nonatomic, strong) NSArray *shareItems;

@end

// end-custom-activity-snippet-header

