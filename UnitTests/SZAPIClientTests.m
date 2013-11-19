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

- (void)testRequestHeaderForLoopyKeys {
    BOOL containsAPIKey = NO;
    BOOL containsLoopyKey = NO;
    NSData *dummyData = [[NSData alloc] init];
    SZAPIClient *apiClient = [[SZAPIClient alloc] initWithURLPrefix:@"" httpsPrefix:@""];
    NSMutableURLRequest *request = [apiClient newURLRequest:dummyData length:0 endpoint:@""];
    NSDictionary *headerFields = [request allHTTPHeaderFields];
    for(NSString *key in headerFields) {
        id value = [headerFields valueForKey:key];
        GHAssertNotNil(value, @"");
        
        if([key isEqualToString:API_KEY]) {
            containsAPIKey = YES;
        }
        else if([key isEqualToString:LOOPY_KEY]) {
            containsLoopyKey = YES;
        }
    }
    
    GHAssertTrue(containsAPIKey && containsLoopyKey, @"");
}

- (void)testOpen {
    [self prepare];
    id apiClient = [[SZAPIClient alloc] initWithURLPrefix:@"" httpsPrefix:@""];
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

- (void)testReportShareDictionary {
    id apiClient = [[SZAPIClient alloc] initWithURLPrefix:@""];
    NSString *dummyShortlink = @"www.shortlink.com";
    NSString *dummyChannel = @"Facebook";
    
    NSDictionary *shareDict = [apiClient reportShareDictionary:dummyShortlink channel:dummyChannel];
    GHAssertNotNil(shareDict, @"");
}

- (void)testReportShare {
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
    [mockAPIClient reportShare:jsonDict withCallback:^(NSURLResponse *response, NSData *data, NSError *error) {
        operationSucceeded = YES;
        [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testReportShare)];
    }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
    GHAssertTrue(operationSucceeded, @"");
}

@end
