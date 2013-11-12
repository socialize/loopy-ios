//
//  SZShare.h
//  Loopy
//
//  Created by David Jedeikin on 10/23/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "SZAPIClient.h"
#import <Foundation/Foundation.h>
#import <Social/Social.h>

@interface SZShare : NSObject

@property (nonatomic, strong) UIViewController *parentController;
@property (nonatomic, strong) SZAPIClient *apiClient;

- (id)initWithParent:(UIViewController *)parent apiClient:(SZAPIClient *)client;
- (NSArray *)getCurrentActivities:(NSArray *)activityItems;
- (UIActivityViewController *)newActivityViewController:(NSArray *)shareItems withActivities:(NSArray *)activities;
- (SLComposeViewController *)newActivityShareController:(id)activityObj;
- (void)showActivityViewDialog:(UIActivityViewController *)activityController completion:(void (^)(void))completion;
- (void)showActivityShareDialog:(SLComposeViewController *)controller;
- (void)handleShowActivityShare:(NSNotification *)notification;
- (void)handleShareComplete:(NSNotification *)notification;
@end
