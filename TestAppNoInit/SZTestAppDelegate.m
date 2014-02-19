//
//  SZAppDelegate.m
//  TestAppNoInit
//
//  Created by David Jedeikin on 2/12/14.
//  Copyright (c) 2014 ShareThis. All rights reserved.
//

#import "SZTestAppDelegate.h"
#import "STAPIClient.h"
#import <AFNetworking/AFNetworking.h>

@implementation SZTestAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    STAPIClient *apiClient = [[STAPIClient alloc] initWithAPIKey:@"c64fc5c7-2379-4249-8ccd-ef33d5bfac52"
                                                        loopyKey: @"_sandbox_key_sandbox"];
    apiClient.urlPrefix = @"http://http://stage.api.loopy.getsocialize.com:8080/loopy-mock/v1";
    apiClient.httpsURLPrefix = @"https://http://stage.api.loopy.getsocialize.com:8443/loopy-mock/v1";

    [apiClient open:[SZTestAppDelegate jsonForOpen]
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"SUCCESS");
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"FAIL");
            }];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+ (NSDictionary *)jsonForOpen {
    NSDictionary *geoObj = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithDouble:12.456],@"lat",
                            [NSNumber numberWithDouble:78.900],@"lon",
                            nil];
    NSDictionary *deviceObj = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"iPhone 4S",@"model",
                               @"ios",@"os",
                               @"6.1",@"osv",
                               @"verizon",@"carrier",
                               @"on",@"wifi",
                               geoObj,@"geo",
                               nil];
    NSDictionary *appObj = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"com.socialize.appname",@"id",
                            @"App Name",@"name",
                            @"123.4",@"version",
                            nil];
    NSDictionary *clientObj = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"objc",@"lang",
                               @"1.3",@"version",
                               nil];
    NSDictionary *mockObj = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithInt:200],@"http",
                             nil];
    NSDictionary *openObj = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"69",@"stdid",
                             [NSNumber numberWithInt:1234567890],@"timestamp",
                             @"ABCDEF",@"referrer",
                             deviceObj,@"device",
                             appObj,@"app",
                             clientObj,@"client",
                             mockObj,@"mock",
                             nil];
    return openObj;
}

@end
