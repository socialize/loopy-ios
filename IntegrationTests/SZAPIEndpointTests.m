//
//  SZAPIEndpointTests.m
//  Loopy
//
//  Created by David Jedeikin on 10/1/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <SZNetworking/SZNetworking.h>
#import "SZAPIClient.h"
#import "SZTestUtils.h"

@interface SZAPIEndpointTests : GHAsyncTestCase {
    SZAPIClient *apiClient;
}
@end

@implementation SZAPIEndpointTests

NSString *const URL_PREFIX = @"http://ec2-54-227-157-217.compute-1.amazonaws.com:8080/loopymock/v1";

- (void)setUp {
    apiClient = [[SZAPIClient alloc] initWithURLPrefix:URL_PREFIX];
}

- (void)tearDown {
}

//this uses the same JSON object used by unit tests
- (void)testOpenEndpoint {
    [self prepare];
    NSDictionary *jsonDict = [SZTestUtils jsonForOpen];
    __block BOOL operationSucceeded = NO;
    __block id responseData;

    [apiClient open:(NSDictionary *)jsonDict withCallback:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error == nil) {
            responseData = [data objectFromJSONData];
            //response data should be an empty dictionary
            if([responseData isKindOfClass:[NSDictionary class]]) {
                NSDictionary *responseDict = (NSDictionary *)responseData;
                if([responseDict count] == 0) {
                    operationSucceeded = YES;
                    [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testOpenEndpoint)];
                }
                else {
                    operationSucceeded = NO;
                    [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testOpenEndpoint)];
                }
            }
        }
        else {
            operationSucceeded = NO;
            [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testOpenEndpoint)];
        }
    }];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];

    GHAssertTrue(operationSucceeded, @"");
}

//this uses the same JSON object used by unit tests
- (void)testShortlinkEndpoint {
    [self prepare];
    NSDictionary *jsonDict = [SZTestUtils jsonForShortlink];
    __block BOOL operationSucceeded = NO;
    __block id responseData;

    [apiClient shortlink:(NSDictionary *)jsonDict withCallback:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error == nil) {
            responseData = [data objectFromJSONData];
            //check data that came back
            if([responseData isKindOfClass:[NSDictionary class]]) {
                NSDictionary *responseDict = (NSDictionary *)responseData;
                if([responseDict count] == 1 && [responseDict valueForKey:@"shortlink"]) {
                    NSString *shortlink = (NSString *)[responseDict valueForKey:@"shortlink"];
                    GHAssertTrue([shortlink length] > 0, @"shortlink length");
                    operationSucceeded = YES;
                    [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testShortlinkEndpoint)];
                }
                else {
                    operationSucceeded = NO;
                    [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testShortlinkEndpoint)];
                }
            }
        }
        else {
            operationSucceeded = NO;
            [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testShortlinkEndpoint)];
        }
    }];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
    
    GHAssertTrue(operationSucceeded, @"");
}
@end
