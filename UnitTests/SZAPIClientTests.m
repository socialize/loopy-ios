//
//  SZAPIClientTests.m
//  Loopy
//
//  Created by David Jedeikin on 9/11/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "SZAPIClient.h"
#import "SZJSONUtils.h"
#import "SZTestUtils.h"
#import <GHUnitIOS/GHUnit.h>
#import <OCMock/OCMock.h>
#import <AFNetworking/AFNetworking.h>

@interface SZAPIClientTests : GHAsyncTestCase {
    SZAPIClient *apiClient;
    NSString *urlPrefix;
    NSString *httpsURLPrefix;
    NSString *endpoint;
    BOOL mockInstallSucceeded;
}
@end

@implementation SZAPIClientTests

- (void)setUpClass {
    urlPrefix = @"http://loopy.com:8080";
    httpsURLPrefix = @"https://loopy.com:8443";
    endpoint = @"/endpoint";
    apiClient = [[SZAPIClient alloc] initWithURLPrefix:urlPrefix httpsPrefix:httpsURLPrefix];
    mockInstallSucceeded = NO;
}

- (void)testNewURLRequest {
    BOOL containsAPIKey = NO;
    BOOL containsLoopyKey = NO;
    NSData *dummyData = [[NSData alloc] init];
    NSURLRequest *request = [apiClient newURLRequest:dummyData length:0 endpoint:endpoint];
    
    //verify header fields
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
    NSString *acceptVal = [request valueForHTTPHeaderField:@"Accept"];
    NSString *contentTypeVal = [request valueForHTTPHeaderField:@"Content-Type"];
    GHAssertEqualStrings(@"application/json", acceptVal, @"");
    GHAssertEqualStrings(@"application/json", contentTypeVal, @"");
    
    //verify URL
    NSString *urlMatchStr = [NSString stringWithFormat:@"%@%@", urlPrefix, endpoint];
    GHAssertEqualStrings(urlPrefix, apiClient.urlPrefix, @"");
    NSURL *url = request.URL;
    GHAssertEqualStrings(urlMatchStr, [url absoluteString], @"");
}

- (void)testNewHTTPSURLRequest {
    NSData *dummyData = [[NSData alloc] init];
    NSURLRequest *request = [apiClient newHTTPSURLRequest:dummyData length:0 endpoint:endpoint];
    
    //verify URL
    NSString *urlMatchStr = [NSString stringWithFormat:@"%@%@", httpsURLPrefix, endpoint];
    GHAssertEqualStrings(httpsURLPrefix, apiClient.httpsURLPrefix, @"");
    NSURL *url = request.URL;
    GHAssertEqualStrings(urlMatchStr, [url absoluteString], @"");
}

- (void)testNewURLRequestOperation {
    NSData *dummyData = [[NSData alloc] init];
    
    //https -- verify serialization & challenge block created
    NSURLRequest *httpsRequest = [apiClient newHTTPSURLRequest:dummyData length:0 endpoint:endpoint];
    AFHTTPRequestOperation *httpsOperation = [apiClient newURLRequestOperation:httpsRequest isHTTPS:YES success:nil failure:nil];
    GHAssertTrue([httpsOperation.responseSerializer isKindOfClass:[AFJSONResponseSerializer class]], @"");
    NSString *authChallengeName = @"authenticationChallenge";
    id authChallengeBlock = [httpsOperation valueForKey:authChallengeName];
    GHAssertNotNil(authChallengeBlock, @"");
    
    //https -- no challenge block but same serialization
    NSURLRequest *request = [apiClient newURLRequest:dummyData length:0 endpoint:endpoint];
    AFHTTPRequestOperation *operation = [apiClient newURLRequestOperation:request isHTTPS:NO success:nil failure:nil];
    GHAssertTrue([httpsOperation.responseSerializer isKindOfClass:[AFJSONResponseSerializer class]], @"");
    authChallengeBlock = [operation valueForKey:authChallengeName];
    GHAssertNil(authChallengeBlock, @"");
}

- (void)testReportShareDictionary {
    NSString *dummyShortlink = @"www.shortlink.com";
    NSString *dummyChannel = @"Facebook";
    
    NSDictionary *shareDict = [apiClient reportShareDictionary:dummyShortlink channel:dummyChannel];
    GHAssertNotNil(shareDict, @"");
    GHAssertNotNil([shareDict valueForKey:@"stdid"], @"");
    GHAssertNotNil([shareDict valueForKey:@"timestamp"], @"");
    GHAssertNotNil([shareDict valueForKey:@"device"], @"");
    GHAssertNotNil([shareDict valueForKey:@"app"], @"");
    NSString *channel = [shareDict valueForKey:@"channel"];
    GHAssertEqualStrings(channel, dummyChannel, @"");
    NSString *shortlink = [shareDict valueForKey:@"shortlink"];
    GHAssertEqualStrings(shortlink, dummyShortlink, @"");
    GHAssertNotNil([shareDict valueForKey:@"client"], @"");
}

@end
