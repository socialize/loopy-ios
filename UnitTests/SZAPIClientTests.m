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

@interface SZAPIClientTests : GHAsyncTestCase {
    id mockAPIClient;
    BOOL operationSucceeded;
    id responseData;
}
@end
//@interface SZAPIClientTests : GHAsyncTestCase {}
//@property id mockAPIClient;
//
//@end

@implementation SZAPIClientTests

//@synthesize mockAPIClient;

- (void)setUpClass {
    id apiClient = [[SZAPIClient alloc] initWithURLPrefix:@""];
    mockAPIClient = [OCMockObject partialMockForObject:apiClient];
}

- (void)tearDownClass {
    // Run at end of all tests in the class
}

- (void)testOpen {
    [self prepare];
    //return dummy request and request operations
    NSMutableURLRequest *dummyRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"file:foo"]];
    [[[mockAPIClient stub] andReturn:dummyRequest] newURLRequest:[OCMArg any]
                                                               length:[OCMArg any]
                                                             endpoint:[OCMArg any]];
    SZURLRequestOperation *requestOperation = [[SZURLRequestOperation alloc] initWithURLRequest:dummyRequest];
    [[[mockAPIClient stub] andReturn:requestOperation] newURLRequestOperation:[OCMArg any]];
    
    //TODO this can only work if the downloader can be plugged into the operation;
    //currently, this is not straightforward
    //so for now, simply verify that block was called, regardless of result
    //"real" results will be tested in IntegrationTests
    
//    id partialMockRequestOperation = [OCMockObject partialMockForObject:requestOperation];
//    id mockDownloader = [OCMockObject mockForClass:[SZURLRequestDownloader class]];
//    //Fake a 200 response with data by mimicking the NSURLConnection protocol
//    NSDictionary *responseHeaders = @{@"Content-type": @"text/html;charset=utf-8"};
//    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"file:foo"]
//                                                              statusCode:200
//                                                             HTTPVersion:@"HTTP/1.1"
//                                                            headerFields:responseHeaders];
//    id mockData = [OCMockObject mockForClass:[NSMutableData class]];
//    id mockError = [OCMockObject mockForClass:[NSError class]];
//    [mockDownloader expectStartAndCompleteWithResponse:response data:mockData error:mockError];
    
    //call with test JSON dict
    NSDictionary *jsonDict = [SZTestUtils jsonForOpen];
    [mockAPIClient open:(NSDictionary *)jsonDict withCallback:^(NSURLResponse *response, NSData *data, NSError *error) {
        operationSucceeded = YES;
        [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testOpen)];
    }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
    GHAssertTrue(operationSucceeded, @"");
}

@end
