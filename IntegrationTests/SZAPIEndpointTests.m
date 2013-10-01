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
#import "SZJSONUtils.h"

@interface SZAPIEndpointTests : GHAsyncTestCase {
    BOOL operationSucceeded;
    NSMutableData *responseData;
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

    responseData = [NSMutableData data];
    NSDictionary *jsonDict = [SZTestUtils jsonForOpen];
    NSData *jsonData = [SZJSONUtils toJSONData:jsonDict];
    NSString *jsonStr = [SZJSONUtils toJSONString:jsonData];
    SZAPIClient *apiClient = [[SZAPIClient alloc] initWithURLPrefix:@"http://ec2-54-227-157-217.compute-1.amazonaws.com:8080/loopymock/v1"];
    NSURLRequest *request = [apiClient newURLRequest:jsonData
                                              length:[NSNumber numberWithInt:[jsonStr length]]
                                            endpoint:OPEN];
    NSURLConnection *connection = [apiClient newURLConnection:request delegate:self];
    [apiClient open:jsonDict withConnection:connection];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];

    //operation completed
    //TODO verify data (not an issue for open but will be for others)
    GHAssertTrue(operationSucceeded, @"");
}

//protocol impl
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int code = [httpResponse statusCode];
    NSLog(@"didReceiveResponse; code: %d", code);
    [responseData setLength:0];
}

//protocol impl
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

//protocol impl
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    NSLog(@"Connection failed: %@", [error description]);

	operationSucceeded = NO;
    
    [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testOpenEndpoint)];
}

//protocol impl
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[responseData length]);
    operationSucceeded = YES;
    
    [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testOpenEndpoint)];
}


@end
