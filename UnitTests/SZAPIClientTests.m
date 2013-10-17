//
//  SZAPIClientTests.m
//  Loopy
//
//  Created by David Jedeikin on 9/11/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <OCMock/OCMock.h>
#import "SZAPIClient.h"
#import "SZJSONUtils.h"
#import "SZTestUtils.h"
#import "SZURLRequestOperation+Testing.h"

@interface SZAPIClientTests : GHAsyncTestCase {}
@end

@implementation SZAPIClientTests

- (void)setUpClass {
}

- (void)tearDownClass {
}

- (void)testOpen {
    [self prepare];
    id apiClient = [[SZAPIClient alloc] initWithURLPrefix:@""];
    id mockAPIClient = [OCMockObject partialMockForObject:apiClient];
    __block BOOL operationSucceeded = NO;

    //return dummy request and request operations
    NSMutableURLRequest *dummyRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"file:foo"]];
    [[[mockAPIClient stub] andReturn:dummyRequest] newURLRequest:[OCMArg any]
                                                               length:[OCMArg any]
                                                             endpoint:[OCMArg any]];
    SZURLRequestOperation *requestOperation = [[SZURLRequestOperation alloc] initWithURLRequest:dummyRequest];
    [[[mockAPIClient stub] andReturn:requestOperation] newURLRequestOperation:[OCMArg any]];
    
    //call with test JSON dict
    NSDictionary *jsonDict = [SZTestUtils jsonForOpen];
    [mockAPIClient open:(NSDictionary *)jsonDict withCallback:^(NSURLResponse *response, NSData *data, NSError *error) {
        operationSucceeded = YES;
        [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testOpen)];
    }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
    GHAssertTrue(operationSucceeded, @"");
}

- (void)testShortlink {
    [self prepare];
    id apiClient = [[SZAPIClient alloc] initWithURLPrefix:@""];
    id mockAPIClient = [OCMockObject partialMockForObject:apiClient];
    __block BOOL operationSucceeded = NO;

    //return dummy request and request operations
    NSMutableURLRequest *dummyRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"file:foo"]];
    [[[mockAPIClient stub] andReturn:dummyRequest] newURLRequest:[OCMArg any]
                                                          length:[OCMArg any]
                                                        endpoint:[OCMArg any]];
    SZURLRequestOperation *requestOperation = [[SZURLRequestOperation alloc] initWithURLRequest:dummyRequest];
    [[[mockAPIClient stub] andReturn:requestOperation] newURLRequestOperation:[OCMArg any]];
    
    //call with test JSON dict
    NSDictionary *jsonDict = [SZTestUtils jsonForShortlink];
    [mockAPIClient shortlink:jsonDict withCallback:^(NSURLResponse *response, NSData *data, NSError *error) {
        operationSucceeded = YES;
        [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testShortlink)];
    }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
    GHAssertTrue(operationSucceeded, @"");
}

- (void)testShare {
    [self prepare];
    id apiClient = [[SZAPIClient alloc] initWithURLPrefix:@""];
    id mockAPIClient = [OCMockObject partialMockForObject:apiClient];
    __block BOOL operationSucceeded = NO;
    
    //return dummy request and request operations
    NSMutableURLRequest *dummyRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"file:foo"]];
    [[[mockAPIClient stub] andReturn:dummyRequest] newURLRequest:[OCMArg any]
                                                          length:[OCMArg any]
                                                        endpoint:[OCMArg any]];
    SZURLRequestOperation *requestOperation = [[SZURLRequestOperation alloc] initWithURLRequest:dummyRequest];
    [[[mockAPIClient stub] andReturn:requestOperation] newURLRequestOperation:[OCMArg any]];
    
    //call with test JSON dict
    NSDictionary *jsonDict = [SZTestUtils jsonForShare];
    [mockAPIClient share:jsonDict withCallback:^(NSURLResponse *response, NSData *data, NSError *error) {
        operationSucceeded = YES;
        [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testShare)];
    }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
    GHAssertTrue(operationSucceeded, @"");
}

@end
