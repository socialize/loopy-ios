//
//  STAPIEndpointTests.m
//  Loopy
//
//  Created by David Jedeikin on 10/1/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "STAPIClient.h"
#import "STTestUtils.h"
#import "STJSONUtils.h"
#import "STInstall.h"
#import "STOpen.h"
#import "STShare.h"
#import "STShortlink.h"
#import "STSharelink.h"
#import "STItem.h"
#import "STLog.h"

@interface STAPIEndpointTests : GHAsyncTestCase {
    STAPIClient *apiClient;
}
@end

@implementation STAPIEndpointTests

- (void)setUp {
    apiClient = [[STAPIClient alloc] initWithAPIKey:@"be6a5004-6abb-4382-a131-8d6812a9e74b"
                                           loopyKey:@"3d4pnhzpar8bz8t44w7hb42k"
                                  locationsDisabled:YES];
    
    //simulate current location, IDFA, and stdid
    //IDFA and corresponding MD5ID will not be generated on headless simulators
    if(!apiClient.deviceSettings.currentLocation) {
        apiClient.deviceSettings.currentLocation = [[CLLocation alloc] initWithLatitude:45.0f longitude:45.0f];
    }
    if(!apiClient.stdid) {
        NSUUID *stdidObj = (NSUUID *)[NSUUID UUID];
        apiClient.stdid = (NSString *)[stdidObj UUIDString];
    }
    if(!apiClient.deviceSettings.idfa) {
        apiClient.deviceSettings.idfa = (NSUUID *)[NSUUID UUID];
    }
    if(!apiClient.deviceSettings.md5id) {
        apiClient.deviceSettings.md5id = [apiClient.deviceSettings md5FromString:[apiClient.deviceSettings.idfa UUIDString]];
    }
}

- (void)tearDown {
}

//this uses the JSON object in the APIClient
- (void)testInstallEndpoint {
    [self prepare];
    __block BOOL operationSucceeded = NO;
    
    STInstall *installObj = [apiClient installWithReferrer:@"www.facebook.com"];
    [apiClient install:installObj
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   NSDictionary *responseDict = (NSDictionary *)responseObject;
                   if([responseDict count] == 0) {
                       operationSucceeded = YES;
                       [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testInstallEndpoint)];
                   }
                   else {
                       operationSucceeded = NO;
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

//this uses the JSON object in the APIClient
- (void)testOpenEndpoint {
    [self prepare];
    STOpen *openObj = [apiClient openWithReferrer:@"www.facebook.com"];
    __block BOOL operationSucceeded = NO;
    
    [apiClient open:openObj
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
    STOpen *openInvalid = [apiClient openWithReferrer:@"http://www.facebook.com"];
    openInvalid.stdid = nil;
    __block BOOL operationSucceeded = NO;
    
    [apiClient open:openInvalid
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

//this uses the JSON object in the APIClient
- (void)testShareEndpoint {
    [self prepare];
    NSString *dummyShortlink = @"www.shortlink.com";
    NSString *dummyChannel = @"Facebook";
    STShare *jsonObj = [apiClient reportShareWithShortlink:dummyShortlink channel:dummyChannel];
    __block BOOL operationSucceeded = NO;
    
    [apiClient reportShare:jsonObj
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
- (void)testShortlinkEndpoint {
    [self prepare];
    STShortlink *jsonObj = [apiClient shortlinkWithURL:@"http://www.facebook.com"
                                          title:@"Share This"
                                           meta:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 @"A description should go here.", @"og:description",
                                                 @"http://someimageurl.com/foobar.jpg", @"og:image",
                                                 @"http://someimageurl.com/foobar.jpg", @"og:video",
                                                 @"http://someimageurl.com/foobar.jpg", @"og:video:type",
                                                 nil]
                                           tags:[NSArray arrayWithObjects:@"sports", @"movies", @"music", nil]];
    __block BOOL operationSucceeded = NO;
    
    [apiClient shortlink:jsonObj
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
    STShortlink *jsonObj = [apiClient shortlinkWithURL:@"http://www.facebook.com"
                                          title:@"Share This"
                                           meta:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 @"A description should go here.", @"og:description",
                                                 @"http://someimageurl.com/foobar.jpg", @"og:image",
                                                 @"http://someimageurl.com/foobar.jpg", @"og:video",
                                                 @"http://someimageurl.com/foobar.jpg", @"og:video:type",
                                                 nil]
                                           tags:[NSArray arrayWithObjects:@"sports", @"movies", @"music", nil]];
    __block BOOL operationSucceeded = NO;
    
    //add custom URL
    NSString *cacheURL = @"http://www.cacheurl.com";
    STItem *item = jsonObj.item;
    item.url = cacheURL;
    
    [apiClient shortlink:jsonObj
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     //now verify that it's in the cache -- this is sufficient as testing timing of response is fragile
                     operationSucceeded = [apiClient.shortlinks valueForKey:cacheURL] != nil;
                     [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testShortlinkCache)];
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
    NSString *cacheURL = @"http://www.cacheurl.com";
    STShortlink *jsonObj = [apiClient shortlinkWithURL:cacheURL
                                          title:@"Share This"
                                           meta:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 @"A description should go here.", @"og:description",
                                                 @"http://someimageurl.com/foobar.jpg", @"og:image",
                                                 @"http://someimageurl.com/foobar.jpg", @"og:video",
                                                 @"http://someimageurl.com/foobar.jpg", @"og:video:type",
                                                 nil]
                                           tags:[NSArray arrayWithObjects:@"sports", @"movies", @"music", nil]];
    __block BOOL operationSucceeded = NO;
    
    [apiClient shortlink:jsonObj
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     //verify the cache contains the value
                     GHAssertTrue([apiClient.shortlinks valueForKey:cacheURL] != nil, @"");
                     //share the shortlink...
                     NSDictionary *responseDict = (NSDictionary *)responseObject;
                     NSString *shortlink = (NSString *)[responseDict valueForKey:@"shortlink"];
                     STShare *shareObj = [apiClient reportShareWithShortlink:shortlink channel:@"http://www.facebook.com"];

                     [apiClient reportShare:shareObj
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
- (void)testSharelinkEndpoint {
    [self prepare];
    STSharelink *jsonObj = [apiClient sharelinkWithURL:@"http://www.facebook.com"
                                               channel:@"Facebook"
                                                 title:@"Share This"
                                                  meta:[NSDictionary dictionaryWithObjectsAndKeys:
                                                        @"A description should go here.", @"og:description",
                                                        @"http://someimageurl.com/foobar.jpg", @"og:image",
                                                        @"http://someimageurl.com/foobar.jpg", @"og:video",
                                                        @"http://someimageurl.com/foobar.jpg", @"og:video:type",
                                                        nil]
                                                  tags:[NSArray arrayWithObjects:@"sports", @"movies", @"music", nil]];
    __block BOOL operationSucceeded = NO;
    [apiClient sharelink:jsonObj
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     //check data that came back
                     if([responseObject isKindOfClass:[NSDictionary class]]) {
                         NSDictionary *responseDict = (NSDictionary *)responseObject;
                         if([responseDict count] == 1 && [responseDict valueForKey:@"shortlink"]) {
                             NSString *shortlink = (NSString *)[responseDict valueForKey:@"shortlink"];
                             GHAssertTrue([shortlink length] > 0, @"shortlink length");
                             operationSucceeded = YES;
                             [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testSharelinkEndpoint)];
                         }
                         else {
                             operationSucceeded = NO;
                             [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testSharelinkEndpoint)];
                         }
                     }
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     operationSucceeded = NO;
                     [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testSharelinkEndpoint)];
                 }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
    GHAssertTrue(operationSucceeded, @"");
}

//this uses the JSON object in the APIClient
//adds latency far greater than the NSURLRequest TIMEOUT setting in STAPIClient
//- (void)testShortenShareLatencyFail {
//    [self prepare];
//    NSDictionary *shortlinkDict = [apiClient shortlinkDictionary:@"http://www.facebook.com"
//                                                           title:@"Share This"
//                                                            meta:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                                  @"A description should go here.", @"og:description",
//                                                                  @"http://someimageurl.com/foobar.jpg", @"og:image",
//                                                                  @"http://someimageurl.com/foobar.jpg", @"og:video",
//                                                                  @"http://someimageurl.com/foobar.jpg", @"og:video:type",
//                                                                  nil]
//                                                            tags:[NSArray arrayWithObjects:@"sports", @"movies", @"music", nil]];
//    NSDictionary *shortlinkDictWithLatency = [STTestUtils addLatencyToMock:5000 forDictionary:shortlinkDict];
//    __block BOOL operationSucceeded = NO;
//    
//    [apiClient shortlink:shortlinkDictWithLatency
//                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                     operationSucceeded = NO;
//                     [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testShortenShareLatencyFail)];
//                 }
//                 //this scenario EXPECTS an error with code -1001 (request timeout)
//                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                     if([error code] == -1001) {
//                         //now do the share with the original URL (and no latency)
//                         NSDictionary *itemDict = (NSDictionary *)[shortlinkDictWithLatency valueForKey:@"item"];
//                         NSString *url = (NSString *)[itemDict valueForKey:@"url"];
//                         NSMutableDictionary *shareDict = [NSMutableDictionary dictionaryWithDictionary:[apiClient reportShareDictionary:url
//                                                                                                                                 channel:@"http://www.facebook.com"]];
//                         [shareDict setValue:url forKey:@"shortlink"];
//                         [apiClient reportShare:shareDict
//                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                                            NSDictionary *responseDict = (NSDictionary *)responseObject;
//                                            if([responseDict count] == 0) {
//                                                operationSucceeded = YES;
//                                                [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testShortenShareLatencyFail)];
//                                            }
//                                            else {
//                                                operationSucceeded = NO;
//                                                [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testShortenShareLatencyFail)];
//                                            }
//                                        }
//                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                                            operationSucceeded = NO;
//                                            [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testShortenShareLatencyFail)];
//                                        }];
//                     }
//                 }];
//    
//    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:20.0];
//    GHAssertTrue(operationSucceeded, @"");
//}

//this uses the JSON object in the APIClient
- (void)testLogEndpoint {
    [self prepare];
    __block BOOL operationSucceeded = NO;
    
    NSDictionary *meta = [NSDictionary dictionaryWithObjectsAndKeys:@"value0",@"key0",
                                                                    @"value1",@"key1",
                                                                    nil];
    
    STLog *logObj = [apiClient logWithType:@"share" meta:meta];
    [apiClient log:logObj
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
