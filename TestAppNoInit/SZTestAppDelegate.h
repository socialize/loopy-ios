//
//  SZAppDelegate.h
//  TestAppNoInit
//
//  Created by David Jedeikin on 2/12/14.
//  Copyright (c) 2014 ShareThis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SZTestAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (NSDictionary *)jsonForOpen;

@end
