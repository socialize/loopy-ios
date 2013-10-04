//
//  SZAPIEndpointTests.m
//  Loopy
//
//  Created by David Jedeikin on 10/1/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "SZAPIClient.h"
#import "SZTestUtils.h"
#import <SZNetworking/SZNetworking.h>

@interface SZAPIEndpointTests : GHAsyncTestCase {
    BOOL operationSucceeded;
    id responseData;
}
@end

@implementation SZAPIEndpointTests

- (void)setUp {
	operationSucceeded = NO;
}

- (void)tearDown {
}

//this uses the same JSON object used by unit tests
- (void)testOpenEndpoint {
    [self prepare];
    NSDictionary *jsonDict = [SZTestUtils jsonForOpen];
    SZAPIClient *apiClient = [[SZAPIClient alloc] initWithURLPrefix:@"http://ec2-54-227-157-217.compute-1.amazonaws.com:8080/loopymock/v1"];
    [apiClient open:(NSDictionary *)jsonDict withCallback:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error == nil) {
            responseData = [data objectFromJSONData];
            operationSucceeded = YES;
            [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testOpenEndpoint)];
        }
        else {
            operationSucceeded = NO;
            [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testOpenEndpoint)];
        }
    }];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];

    //operation completed
    //TODO verify data (not an issue for open but will be for others)
    GHAssertTrue(operationSucceeded, @"");
}

@end
