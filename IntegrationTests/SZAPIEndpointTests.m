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
#import "SZJSONUtils.h"

@interface SZAPIEndpointTests : GHAsyncTestCase {
    SZAPIClient *apiClient;
}
@end

@implementation SZAPIEndpointTests

- (void)setUp {
    NSBundle *bundle =  [NSBundle bundleForClass:[self class]];
    NSString *configPath = [bundle pathForResource:@"LoopyApiInfo" ofType:@"plist"];
    NSDictionary *configurationDict = [[NSDictionary alloc]initWithContentsOfFile:configPath];
    NSDictionary *apiInfoDict = [configurationDict objectForKey:@"Loopy API info"];
    NSString *urlPrefix = [apiInfoDict objectForKey:@"urlPrefix"];
    NSString *httpsPrefix = [apiInfoDict objectForKey:@"urlHttpsPrefix"];

    apiClient = [[SZAPIClient alloc] initWithURLPrefix:urlPrefix
                                           httpsPrefix:httpsPrefix];
}

- (void)tearDown {
}

- (void)testLoadIdentities {
    [self prepare];
    __block BOOL operationSucceeded = NO;

    //insert mock IDFA if needed
    if(!apiClient.idfa) {
        apiClient.idfa = [NSUUID UUID];
    }
    [apiClient loadIdentitiesWithReferrer:@"www.facebook.com"
        postSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            operationSucceeded = YES;
            [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testLoadIdentities)];
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            operationSucceeded = NO;
            [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testLoadIdentities)];
        }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
    GHAssertTrue(operationSucceeded, @"");
}

//this uses the same JSON object used by unit tests
- (void)testInstallEndpoint {
    [self prepare];
    NSDictionary *jsonDict = [SZTestUtils jsonForInstall];
    __block BOOL operationSucceeded = NO;
    
    [apiClient install:jsonDict
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   NSDictionary *responseDict = (NSDictionary *)responseObject;
                   operationSucceeded = [[responseDict allKeys] containsObject:@"stdid"] && [responseDict objectForKey:@"stdid"];
                    if(operationSucceeded) {
                        [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testInstallEndpoint)];
                    }
                    else {
                        [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testInstallEndpoint)];
                    }
                }
               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    operationSucceeded = NO;
                    [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testInstallEndpoint)];
            }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
    GHAssertTrue(operationSucceeded, @"");
}

//this uses the same JSON object used by unit tests
- (void)testOpenEndpoint {
    [self prepare];
    NSDictionary *jsonDict = [SZTestUtils jsonForOpen];
    __block BOOL operationSucceeded = NO;

    [apiClient open:jsonDict
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   NSDictionary *responseDict = (NSDictionary *)responseObject;
                   if([responseDict count] == 0) {
                       operationSucceeded = YES;
                       [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testOpenEndpoint)];
                   }
                   else {
                       operationSucceeded = NO;
                       [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testOpenEndpoint)];
                   }
               }
               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   operationSucceeded = NO;
                   [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testOpenEndpoint)];
               }];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
    GHAssertTrue(operationSucceeded, @"");
}

//deliberately-mangled JSON to test error format
- (void)testOpenEndpointInvalidJSON {
    [self prepare];
    NSDictionary *jsonDict = [SZTestUtils jsonForOpen];
    NSMutableDictionary *jsonDictInvalid = [NSMutableDictionary dictionaryWithDictionary:jsonDict];
    [jsonDictInvalid removeObjectForKey:@"stdid"];
    __block BOOL operationSucceeded = NO;

    [apiClient open:jsonDictInvalid
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                operationSucceeded = NO;
                [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testOpenEndpointInvalidJSON)];
            }
            //this scenario EXPECTS an error with code nbr and error array
            //Loopy errors reside in the response object, not the AFNetworking's NSError
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSDictionary *responseObj = (NSDictionary *)operation.responseObject;
                NSNumber *errorCode = [apiClient loopyErrorCode:responseObj];
                NSArray *errorArray = [apiClient loopyErrorArray:responseObj];
                operationSucceeded = (errorCode && errorArray);
                [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testOpenEndpointInvalidJSON)];
            }];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
    GHAssertTrue(operationSucceeded, @"");
}

//this uses the same JSON object used by unit tests
//adds latency far greater than the NSURLRequest TIMEOUT setting in SZAPIClient
- (void)testOpenEndpointLatencyFail {
    [self prepare];
    NSDictionary *jsonDict = [SZTestUtils jsonForOpen];
    NSDictionary *jsonDictWithLatency = [SZTestUtils addLatencyToMock:5000 forDictionary:jsonDict];
    __block BOOL operationSucceeded = NO;
    
    [apiClient open:jsonDictWithLatency
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                operationSucceeded = NO;
                [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testOpenEndpointLatencyFail)];
            }
            //this scenario EXPECTS an error with code -1001 (request timeout)
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if([error code] == -1001) {
                    operationSucceeded = YES;
                    [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testOpenEndpointLatencyFail)];
                }
                else {
                    operationSucceeded = NO;
                    [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testOpenEndpointLatencyFail)];
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

    [apiClient shortlink:jsonDict
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     //check data that came back
                     if([responseObject isKindOfClass:[NSDictionary class]]) {
                         NSDictionary *responseDict = (NSDictionary *)responseObject;
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
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     operationSucceeded = NO;
                     [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testShortlinkEndpoint)];
            }];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
    GHAssertTrue(operationSucceeded, @"");
}

//this uses the same JSON object used by unit tests
- (void)testShareEndpoint {
    [self prepare];
    NSDictionary *jsonDict = [SZTestUtils jsonForShare];
    __block BOOL operationSucceeded = NO;
    
    [apiClient reportShare:jsonDict
                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                       NSDictionary *responseDict = (NSDictionary *)responseObject;
                       if([responseDict count] == 0) {
                           operationSucceeded = YES;
                           [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testShareEndpoint)];
                       }
                       else {
                           operationSucceeded = NO;
                           [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testShareEndpoint)];
                       }
                   }
                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       operationSucceeded = NO;
                       [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testShareEndpoint)];
                   }];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
    GHAssertTrue(operationSucceeded, @"");
}

//this uses the same JSON object used by unit tests
//adds latency far greater than the NSURLRequest TIMEOUT setting in SZAPIClient
- (void)testShortenShareLatencyFail {
    [self prepare];
    NSDictionary *shortlinkDict = [SZTestUtils jsonForShortlink];
    NSDictionary *shortlinkDictWithLatency = [SZTestUtils addLatencyToMock:5000 forDictionary:shortlinkDict];
    __block BOOL operationSucceeded = NO;

    [apiClient shortlink:shortlinkDictWithLatency
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     operationSucceeded = NO;
                     [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testShortenShareLatencyFail)];
                 }
                 //this scenario EXPECTS an error with code -1001 (request timeout)
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     if([error code] == -1001) {
                         //now do the share with the original URL (and no latency)
                         NSDictionary *itemDict = (NSDictionary *)[shortlinkDictWithLatency valueForKey:@"item"];
                         NSString *url = (NSString *)[itemDict valueForKey:@"url"];
                         NSMutableDictionary *shortlinkDict = [NSMutableDictionary dictionaryWithDictionary:[SZTestUtils jsonForShare]];
                         [shortlinkDict setValue:url forKey:@"shortlink"];
                         [apiClient reportShare:shortlinkDict
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                            NSDictionary *responseDict = (NSDictionary *)responseObject;
                                            if([responseDict count] == 0) {
                                                operationSucceeded = YES;
                                                [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testShortenShareLatencyFail)];
                                            }
                                            else {
                                                operationSucceeded = NO;
                                                [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testShortenShareLatencyFail)];
                                            }
                                        }
                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            operationSucceeded = NO;
                                            [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testShortenShareLatencyFail)];
                                        }];
                     }
                 }];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
    GHAssertTrue(operationSucceeded, @"");
}
@end
