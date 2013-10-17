//
//  SZTestUtils.m
//  Loopy
//
//  Created by David Jedeikin on 9/30/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "SZTestUtils.h"

@implementation SZTestUtils

//test JSON object
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

+ (NSDictionary *)jsonForShortlink {
    NSDictionary *mockObj = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithInt:200],@"http",
                             nil];
    NSDictionary *itemObj = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"ABCD-1234",@"url",
                             nil];
    NSDictionary *shortlinkObj = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"69",@"stdid",
                                  [NSNumber numberWithInt:1234567890],@"timestamp",
                                  mockObj,@"mock",
                                  itemObj,@"item",
                                  [NSArray arrayWithObjects:@"sports", @"entertainment", nil],@"tags",
                                  nil];
    
    return shortlinkObj;
}

//test JSON object
+ (NSDictionary *)jsonForShare {
    NSDictionary *geoObj = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithDouble:12.456],@"lat",
                            [NSNumber numberWithDouble:78.900],@"lon",
                            nil];
    NSDictionary *deviceObj = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"ABCDEFGHIJKLMNOP",@"id",
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
    NSDictionary *shareObj = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"69",@"stdid",
                             [NSNumber numberWithInt:1234567890],@"timestamp",
                             deviceObj,@"device",
                             appObj,@"app",
                             @"facebook",@"channel",
                             @"http://besoci.al/foobar",@"shortlink",
                             clientObj,@"client",
                             mockObj,@"mock",
                             nil];
    return shareObj;
}

@end
