//
//  SZAPIClientTests.m
//  Loopy
//
//  Created by David Jedeikin on 9/11/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "SZAPIClient.h"

@interface SZAPIClientTests : GHTestCase {}
@property SZAPIClient *apiClient;
@end

@implementation SZAPIClientTests

@synthesize apiClient;

- (void)setUpClass {
    self.apiClient = [[SZAPIClient alloc] initWithURLPrefix:@"http://ec2-54-227-157-217.compute-1.amazonaws.com:8080/loopymock"];
}

- (void)tearDownClass {
    // Run at end of all tests in the class
}

- (void)testJSONForOpen {
    NSDictionary *openObj = [self jsonForOpen];
    GHAssertTrue([NSJSONSerialization isValidJSONObject:openObj], nil);
    
    NSData *jsonData = [self.apiClient toJSONData:openObj];
    GHAssertNotNil(jsonData, nil);
    
    NSString *jsonString = [self.apiClient toJSONString:jsonData];
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
    //TODO delgate-ify...
    [self.apiClient open:[self jsonForOpen] withDelegate:self];
}


//protocol impl
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int code = [httpResponse statusCode];
    NSLog(@"didReceiveResponse; code: %d", code);
}

//protocol impl
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"didReceiveData");
}

//protocol impl
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    NSLog(@"Connection failed: %@", [error description]);
}

//protocol impl
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
}

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
