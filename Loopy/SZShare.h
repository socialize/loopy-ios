//
//  SZShare.h
//  Loopy
//
//  Created by David Jedeikin on 10/23/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SZShare : NSObject

@property (nonatomic, strong) UIViewController *parentController;

- (id)initWithParent:(UIViewController *)parent;
- (NSArray *)getCurrentActivities;
- (UIActivityViewController *)newActivityViewController:(NSArray *)shareItems withActivities:(NSArray *)activities;
- (void)showShareDialog:(UIActivityViewController *)activityController completion:(void (^)(void))completion;
- (BOOL)handleBeginShare:(NSNotification *)notification;

@end
