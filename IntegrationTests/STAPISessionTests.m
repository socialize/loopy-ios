//
//  STAPISessionTests.m
//  Loopy
//
//  Created by David Jedeikin on 12/9/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "GHAsyncTestCase.h"
#import "STAPIClient.h"

@interface STAPISessionTests : GHAsyncTestCase {
    STAPIClient *apiClient;
}
@end

@implementation STAPISessionTests

- (void)setUp {
    apiClient = [[STAPIClient alloc] initWithAPIKey:@"12a05e3e-e522-4c81-b4bb-89d3be94d122"
                                           loopyKey:@"9c313d12-f34c-4172-9909-180384c724fd"];
    //for now, use mock API
    apiClient.urlPrefix = @"http://stage.api.loopy.getsocialize.com:80/v1";
    apiClient.httpsURLPrefix = @"http://stage.api.loopy.getsocialize.com:80/v1";
    
    //simulate current location, IDFA, and stdid
    //IDFA and corresponding MD5ID will not be generated on headless simulators
    if(!apiClient.currentLocation) {
        apiClient.currentLocation = [[CLLocation alloc] initWithLatitude:45.0f longitude:45.0f];
    }
    if(!apiClient.stdid) {
        NSUUID *stdidObj = (NSUUID *)[NSUUID UUID];
        apiClient.stdid = (NSString *)[stdidObj UUIDString];
    }
    if(!apiClient.idfa) {
        apiClient.idfa = (NSUUID *)[NSUUID UUID];
    }
    if(!apiClient.md5id) {
        apiClient.md5id = [apiClient md5FromString:[apiClient.idfa UUIDString]];
    }
}

- (void)testGetSession {
    [self prepare];
    __block BOOL operationSucceeded = NO;
    //first remove whatever saved plist file may already exist -- to test install
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [rootPath stringByAppendingPathComponent:SESSION_DATA_FILENAME];
    BOOL fileRemoved = NO;
    if([fileMgr fileExistsAtPath:filePath]) {
        fileRemoved = [fileMgr removeItemAtPath:filePath error:&error];
    }
    else {
        fileRemoved = YES;
    }
    
    if(fileRemoved) {
        [apiClient getSessionWithReferrer:@"www.facebook.com"
                              postSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
                                  GHAssertTrue([fileMgr fileExistsAtPath:filePath], @"");
                                  operationSucceeded = YES;
                                  [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testGetSession)];
                              }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testGetSession)];
                                  }];
        [self waitForStatus:kGHUnitWaitStatusSuccess timeout:20.0];
    }

    GHAssertTrue(operationSucceeded, @"");
}
@end
