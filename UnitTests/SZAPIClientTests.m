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

@interface SZAPIClientTests : GHTestCase {
}
@property id mockAPIClient;
@end

@implementation SZAPIClientTests

@synthesize mockAPIClient;

- (void)setUpClass {
    self.mockAPIClient = [OCMockObject mockForClass:[SZAPIClient class]];
    [[self.mockAPIClient expect] connection:[OCMArg any] didReceiveData:[OCMArg any]];
    [[self.mockAPIClient expect] connection:[OCMArg any] didReceiveResponse:[OCMArg any]];
    [[self.mockAPIClient expect] connectionDidFinishLoading:[OCMArg any]];
    NSLog(@"Mock created");
}

- (void)tearDownClass {
    // Run at end of all tests in the class
}

- (void)testJSONForOpen {
    NSDictionary *openObj = [self jsonForOpen];
    GHAssertTrue([NSJSONSerialization isValidJSONObject:openObj], nil);
    
    NSData *jsonData = [SZJSONUtils toJSONData:openObj];
    GHAssertNotNil(jsonData, nil);
    
    NSString *jsonString = [SZJSONUtils toJSONString:jsonData];
    GHAssertNotNil(jsonString, nil);

    //read from file and compare
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"OpenJSONTest" ofType:@"txt"];
    GHAssertNotNil(filePath, nil);
    NSStringEncoding encoding;
    NSError *readError = nil;
    NSString *fileString = [NSString stringWithContentsOfFile:filePath usedEncoding:&encoding error:&readError];
    GHAssertNotNil(fileString, nil);
    NSError *fileAsDictError = nil;
    NSDictionary *fileDict = [NSJSONSerialization JSONObjectWithData: [fileString dataUsingEncoding:NSUTF8StringEncoding]
                                                             options: NSJSONReadingMutableContainers
                                                               error: &fileAsDictError];
    GHAssertNotNil(fileDict, nil);
    
    //key equality (only check for now)
    NSArray *allFileKeys = [fileDict allKeys];
    NSArray *allOpenObjKeys = [openObj allKeys];
    GHAssertTrue([allFileKeys isEqualToArray:allOpenObjKeys], nil);
    
    //TODO not implemented; better equality check might be needed...
//    BOOL isEqual = [fileDict isEqualToDictionary:openObj];
}

- (void)testOpen {
    //TODO this should be moved to INTEGRATION test and unit test should stub out connection
    NSURL *url = [NSURL URLWithString:@"http://ec2-54-227-157-217.compute-1.amazonaws.com:8080/loopymock/v1/open"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:mockAPIClient startImmediately:NO];
    
    [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [connection start];
    
    //Wait for five seconds
    [self waitForVerifiedMock:mockAPIClient delay:5.0];
    
    [mockAPIClient verify];
}

//taken from a code example for async/delegate callback implementation
- (void)waitForVerifiedMock:(OCMockObject *)inMock delay:(NSTimeInterval)inDelay {
    NSTimeInterval i = 0;
    while (i < inDelay) {
        @try {
            [inMock verify];
            break;
        }
        @catch (NSException *e) {}
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
        i+=0.5;
    }
}

//test JSON object
- (NSDictionary *)jsonForOpen {
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
                             @"200",@"http",
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
