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
    apiClient = [[STAPIClient alloc] initWithAPIKey:@"be6a5004-6abb-4382-a131-8d6812a9e74b"
                                           loopyKey:@"3d4pnhzpar8bz8t44w7hb42k"
                                  locationsDisabled:YES
                                     identifierType:STIdentifierTypeHeadless];
    
    //simulate current location, IDFA, and stdid
    //IDFA and corresponding MD5ID will not be generated on headless simulators
    if(!apiClient.deviceSettings.currentLocation) {
        apiClient.deviceSettings.currentLocation = [[CLLocation alloc] initWithLatitude:45.0f longitude:45.0f];
    }
    if(!apiClient.stdid) {
        NSUUID *stdidObj = (NSUUID *)[NSUUID UUID];
        apiClient.stdid = (NSString *)[stdidObj UUIDString];
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
