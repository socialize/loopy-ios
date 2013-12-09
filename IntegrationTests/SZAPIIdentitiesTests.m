//
//  SZAPIIdentitiesTests.m
//  Loopy
//
//  Created by David Jedeikin on 12/9/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "GHAsyncTestCase.h"
#import "SZAPIClient.h"

@interface SZAPIIdentitiesTests : GHAsyncTestCase {
    SZAPIClient *apiClient;
}
@end

@implementation SZAPIIdentitiesTests

- (void)setUp {
    apiClient = [[SZAPIClient alloc] initWithAPIKey:@"hkg435723o4tho95fh29"
                                           loopyKey:@"4q7cd6ngw3vu7gram5b9b9t6"];
    //insert mock IDFA, MD5ID and STDID
    if(!apiClient.idfa) {
        apiClient.idfa = [NSUUID UUID];
    }
    if(!apiClient.md5id) {
        apiClient.md5id = [apiClient md5FromString:[apiClient.idfa UUIDString]];
    }
    if(!apiClient.stdid) {
        apiClient.stdid = [apiClient.idfa UUIDString];
    }
}

//Verifies existence of stdid and md5id after load or create
- (void)testLoadIdentities {
    [self prepare];
    __block BOOL operationSucceeded = NO;
    
    [apiClient loadIdentitiesWithReferrer:@"www.facebook.com"
                              postSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testLoadIdentities)];
                              }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      operationSucceeded = NO;
                                      [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testLoadIdentities)];
                                  }];
    //verify that stdid and md5id are not nil
    //currently these do not wait for operations to return
    operationSucceeded = apiClient.stdid != nil && apiClient.md5id != nil;
    if(operationSucceeded) {
        [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
    }
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
        //then create new plist
        if(!apiClient.idfa) {
            apiClient.idfa = [NSUUID UUID];
        }
        apiClient.stdid = [apiClient.idfa UUIDString];
        apiClient.md5id = [apiClient md5FromString:[apiClient.idfa UUIDString]];
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
@end
