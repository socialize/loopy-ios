//
//  STJSONUtilsTests.m
//  Loopy
//
//  Created by David Jedeikin on 9/30/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <OCMock/OCMock.h>
#import "STJSONUtils.h"
#import "STTestUtils.h"

@interface STJSONUtilsTests : GHTestCase {}
@end

@implementation STJSONUtilsTests

//test toJSONData from both file and hardcoded dictionary
- (void)testToJSONData {
    //read from hardcoded dictionary and convert to JSON NSData
    NSDictionary *openObj = [STTestUtils jsonForOpen];
    GHAssertTrue([NSJSONSerialization isValidJSONObject:openObj], nil);
    NSData *jsonDictData = [STJSONUtils toJSONData:openObj];
    GHAssertNotNil(jsonDictData, nil);
    
    //read from file and convert to JSON NSData
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"OpenJSONTest" ofType:@"txt"];
    GHAssertNotNil(filePath, nil);
    NSStringEncoding encoding;
    NSError *readError = nil;
    NSString *fileString = [NSString stringWithContentsOfFile:filePath usedEncoding:&encoding error:&readError];
    GHAssertNotNil(fileString, nil);
    NSError *fileAsDictError = nil;
    NSDictionary *fileDict = [NSJSONSerialization JSONObjectWithData:[fileString dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:NSJSONReadingMutableContainers
                                                               error:&fileAsDictError];
    NSData *jsonFileData = [STJSONUtils toJSONData:fileDict];
    GHAssertNotNil(jsonFileData, nil);
}

- (void)testToJSONDictionary {
    //read from hardcoded dictionary and convert to JSON NSData
    NSDictionary *openObj = [STTestUtils jsonForOpen];
    NSData *jsonDictData = [STJSONUtils toJSONData:openObj];
    NSDictionary *matchObj = [STJSONUtils toJSONDictionary:jsonDictData];
    NSArray *matchObjKeys = [matchObj allKeys];
    NSArray *openObjKeys = [openObj allKeys];
    GHAssertNotNil(matchObj, @"");
    
    BOOL equal = YES;
    for(id item in matchObjKeys) {
        if(![openObjKeys containsObject:item]) {
            equal = NO;
            break;
        }
    }
    GHAssertTrue(equal, @"");
}

//deliberately create bad JSON to see what happens
- (void)testToInvalidJSONData {
    NSMutableDictionary *openObj = [NSMutableDictionary dictionaryWithDictionary:[STTestUtils jsonForOpen]];
    NSDate *bogusDate = [NSDate date];
    [openObj setValue:bogusDate forKey:@"stdid"];
    NSData *jsonDictData = [STJSONUtils toJSONData:openObj];
    GHAssertNil(jsonDictData, @"");
}

//test toJSONString from both file and hardcoded dictionary
- (void)testToJSONString {
    NSDictionary *openObj = [STTestUtils jsonForOpen];
    NSData *jsonData = [STJSONUtils toJSONData:openObj];
    NSString *jsonString = [STJSONUtils toJSONString:jsonData];
    GHAssertNotNil(jsonString, nil);
    
    //read from file and compare
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"OpenJSONTest" ofType:@"txt"];
    GHAssertNotNil(filePath, nil);
    NSStringEncoding encoding;
    NSError *readError = nil;
    NSString *fileString = [NSString stringWithContentsOfFile:filePath usedEncoding:&encoding error:&readError];
    GHAssertNotNil(fileString, nil);
}

@end
