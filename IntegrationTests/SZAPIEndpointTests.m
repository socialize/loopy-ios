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
    apiClient = [[SZAPIClient alloc] initWithAPIKey:@"hkg435723o4tho95fh29"
                                           loopyKey: @"4q7cd6ngw3vu7gram5b9b9t6"];
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
    //insert mock stdid -- it'll be replaced by the new one if needed
    if(!apiClient.stdid) {
        apiClient.stdid = [apiClient.idfa UUIDString];
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
    __block BOOL operationSucceeded = NO;
    
    //insert mock IDFA if needed
    if(!apiClient.idfa) {
        apiClient.idfa = [NSUUID UUID];
    }
    NSDictionary *jsonDict = [SZTestUtils jsonForInstall];
    
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

- (void)testSTDIDEndpoint {
    [self prepare];
    NSDictionary *jsonDict = [SZTestUtils jsonForSTDID];
    __block BOOL operationSucceeded = NO;
    
    //insert mock IDFA if needed
    if(!apiClient.idfa) {
        apiClient.idfa = [NSUUID UUID];
    }
    //insert mock stdid -- it'll be replaced by the new one
    if(!apiClient.stdid) {
        apiClient.stdid = [apiClient.idfa UUIDString];
    }
    [apiClient stdid:jsonDict
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSDictionary *responseDict = (NSDictionary *)responseObject;
                 operationSucceeded = [[responseDict allKeys] containsObject:@"stdid"] && [responseDict objectForKey:@"stdid"];
                 if(operationSucceeded) {
                     [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testSTDIDEndpoint)];
                 }
                 else {
                     [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testSTDIDEndpoint)];
                 }
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 operationSucceeded = NO;
                 [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testSTDIDEndpoint)];
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

//this uses the same JSON object used by unit tests (slightly modified for custom URL)
- (void)testShortlinkCache {
    [self prepare];
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionaryWithDictionary:[SZTestUtils jsonForShortlink]];
    __block BOOL operationSucceeded = NO;

    //add custom URL
    NSString *cacheURL = @"http://www.cacheurl.com";
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)[jsonDict valueForKey:@"item"]];
    [item setValue:cacheURL forKey:@"url"];
    [jsonDict setValue:item forKey:@"item"];

    [apiClient shortlink:jsonDict
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     //now verify that it's in the cache -- this is sufficient as testing timing of response is fragile
                     operationSucceeded = [apiClient.shortlinks valueForKey:cacheURL] != nil;
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     operationSucceeded = NO;
                     [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testShortlinkCache)];
                 }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
    GHAssertTrue(operationSucceeded, @"");
}

//this uses the same JSON object used by unit tests (slightly modified for custom URL)
- (void)testShortlinkClearCache {
    [self prepare];
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionaryWithDictionary:[SZTestUtils jsonForShortlink]];
    __block BOOL operationSucceeded = NO;
    
    //add custom URL
    NSString *cacheURL = @"http://www.cacheurl.com";
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)[jsonDict valueForKey:@"item"]];
    [item setValue:cacheURL forKey:@"url"];
    [jsonDict setValue:item forKey:@"item"];
    
    [apiClient shortlink:jsonDict
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     //verify the cache contains the value
                     GHAssertTrue([apiClient.shortlinks valueForKey:cacheURL] != nil, @"");
                     //share the shortlink...
                     NSDictionary *responseDict = (NSDictionary *)responseObject;
                     NSString *shortlink = (NSString *)[responseDict valueForKey:@"shortlink"];
                     NSMutableDictionary *shareDict = [NSMutableDictionary dictionaryWithDictionary:[SZTestUtils jsonForShare]];
                     [shareDict setValue:shortlink forKey:@"shortlink"];
                     [apiClient reportShare:jsonDict
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        //...and verify the cache has been cleared as a result
                                        GHAssertTrue([apiClient.shortlinks valueForKey:cacheURL] == nil, @"");
                                        operationSucceeded = YES;
                                        [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testShortlinkClearCache)];
                                    }
                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        operationSucceeded = NO;
                                        [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testShortlinkClearCache)];
                                    }];
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     operationSucceeded = NO;
                     [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testShortlinkClearCache)];
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
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:20.0];
    GHAssertTrue(operationSucceeded, @"");
}

//tests the following scenarios:
//- no saved plist: calls install
//- plist with unmatched IDFA: calls stdid
//- plist with matching IDFA: calls open
- (void)testSTDIDADFAIntegration {
    [self prepare];
    __block BOOL operationSucceeded = NO;
    
    //first remove whatever saved plist file may already exist -- to test install
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [rootPath stringByAppendingPathComponent:IDENTITIES_FILENAME];
    BOOL fileRemoved = NO;
    if([fileMgr fileExistsAtPath:filePath]) {
        fileRemoved = [fileMgr removeItemAtPath:filePath error:&error];
    }
    else {
        fileRemoved = YES;
    }
    
    if (fileRemoved) {
        //then create new plist with IDFA
        apiClient.stdid = nil;
        //insert mock IDFA if needed
        if(!apiClient.idfa) {
            apiClient.idfa = [NSUUID UUID];
        }
        //try an install...
        NSDictionary *installDict = [apiClient installDictionaryWithReferrer:@"www.facebook.com"];
        [apiClient install:installDict
                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                       [apiClient loadIdentitiesWithReferrer:@"www.facebook.com"
                             postSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
                                 GHAssertTrue([fileMgr fileExistsAtPath:filePath], @"");
                                 //...then change the IDFA and try again
                                 apiClient.idfa = [NSUUID UUID];
                                 [apiClient loadIdentitiesWithReferrer:@"www.facebook.com"
                                       postSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
                                           //...one last time to test the open endpoint
                                           [apiClient loadIdentitiesWithReferrer:@"www.facebook.com"
                                                 postSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
                                                     operationSucceeded = YES;
                                                     [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testSTDIDADFAIntegration)];
                                                 }
                                                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                     [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testSTDIDADFAIntegration)];
                                                 }];
                                       }
                                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testSTDIDADFAIntegration)];
                                           }];
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testSTDIDADFAIntegration)];
                             }];
                   }
                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testSTDIDADFAIntegration)];
                   }];
        [self waitForStatus:kGHUnitWaitStatusSuccess timeout:20.0];
    }
    else {
        GHAssertTrue(operationSucceeded, @"");
    }
    
    GHAssertTrue(operationSucceeded, @"");
}

- (void)testLogEndpoint {
    [self prepare];
    __block BOOL operationSucceeded = NO;
    
    NSDictionary *logDict = [SZTestUtils jsonForLog];
    [apiClient log:logDict
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               NSDictionary *responseDict = (NSDictionary *)responseObject;
               operationSucceeded = responseDict != nil;
               if(operationSucceeded) {
                   [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testLogEndpoint)];
               }
               else {
                   [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testLogEndpoint)];
               }
             }
           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               operationSucceeded = NO;
               [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testLogEndpoint)];
           }];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
    GHAssertTrue(operationSucceeded, @"");
}
@end
