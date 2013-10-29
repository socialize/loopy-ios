//
//  SZShare.h
//  Loopy
//
//  Created by David Jedeikin on 10/23/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>

@interface SZShare : NSObject

@property (nonatomic, strong) UIViewController *parentController;

- (id)initWithParent:(UIViewController *)parent;
- (NSArray *)getCurrentActivities:(NSArray *)activityItems;
- (UIActivityViewController *)newActivityViewController:(NSArray *)shareItems withActivities:(NSArray *)activities;
- (SLComposeViewController *)newActivityShareController:(id)activityObj;
- (void)showActivityViewDialog:(UIActivityViewController *)activityController completion:(void (^)(void))completion;
- (BOOL)handleShowActivityShare:(NSNotification *)notification;
- (void)showActivityShareDialog:(SLComposeViewController *)controller;

@end
