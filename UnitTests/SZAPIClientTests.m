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

@interface SZAPIClientTests : GHTestCase {}
@property id mockAPIClient;
@end

@implementation SZAPIClientTests

@synthesize mockAPIClient;

- (void)setUpClass {
    id apiClient = [[SZAPIClient alloc] initWithURLPrefix:@""];
    self.mockAPIClient = [OCMockObject partialMockForObject:apiClient];
}

- (void)tearDownClass {
    // Run at end of all tests in the class
}

//taken from http://stackoverflow.com/questions/9908547/how-to-unit-test-a-nsurlconnection-delegate
- (void)testOpen {
    NSURLRequest *dummyRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"file:foo"]];
    NSURLConnection *dummyUrlConnection = [[NSURLConnection alloc] initWithRequest:dummyRequest
                                                                          delegate:nil
                                                                  startImmediately:NO];
    [[[self.mockAPIClient stub] andReturn:dummyUrlConnection] newURLConnection:[OCMArg any]];
    
    //do open with test JSON data
    [self.mockAPIClient open:[SZTestUtils jsonForOpen]
              withConnection:dummyUrlConnection];
    
    //response tests
    int statusCode = 200;
    id responseMock = [OCMockObject mockForClass:[NSHTTPURLResponse class]];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(statusCode)] statusCode];
    [self.mockAPIClient connection:dummyUrlConnection didReceiveResponse:responseMock];
    
    //in actuality open doesn't return anything, but this is just to test that a value is returned
    NSString *responseStr = @"{\"open\": \"ABCD-1234\"}";
    NSData *responseData = [responseStr dataUsingEncoding:NSUTF8StringEncoding];
    [self.mockAPIClient connection:dummyUrlConnection didReceiveData:responseData];
    [self.mockAPIClient connectionDidFinishLoading:dummyUrlConnection];
    
    NSString *actualResponseStr = [self.mockAPIClient responseDataToString];
    GHAssertNotNil(actualResponseStr, nil);
    GHAssertEqualStrings(responseStr, actualResponseStr, nil);
}

@end
