//
//  SZFacebookActivity.h
//  Loopy
//
//  Created by David Jedeikin on 10/17/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "SZActivity.h"
#import <UIKit/UIKit.h>

@interface SZFacebookActivity : UIActivity <SZActivity>

@property (nonatomic, strong) NSArray *shareItems;

+ (id)initWithActivityItems:(NSArray *)items;

@end
