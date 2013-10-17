//
//  SZJSONUtilsTests.m
//  Loopy
//
//  Created by David Jedeikin on 9/30/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <OCMock/OCMock.h>
#import "SZJSONUtils.h"
#import "SZTestUtils.h"

@interface SZJSONUtilsTests : GHTestCase {}
@end

@implementation SZJSONUtilsTests

//test toJSONData from both file and hardcoded dictionary
- (void)testToJSONData {
    //read from hardcoded dictionary and convert to JSON NSData
    NSDictionary *openObj = [SZTestUtils jsonForOpen];
    GHAssertTrue([NSJSONSerialization isValidJSONObject:openObj], nil);
    NSData *jsonDictData = [SZJSONUtils toJSONData:openObj];
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
    NSData *jsonFileData = [SZJSONUtils toJSONData:fileDict];
    GHAssertNotNil(jsonFileData, nil);
}

//deliberately create bad JSON to see what happens
- (void)testToInvalidJSONData {
    NSMutableDictionary *openObj = [NSMutableDictionary dictionaryWithDictionary:[SZTestUtils jsonForOpen]];
    NSDate *bogusDate = [NSDate date];
    [openObj setValue:bogusDate forKey:@"stdid"];
    NSData *jsonDictData = [SZJSONUtils toJSONData:openObj];
    GHAssertNil(jsonDictData, @"");
}

//test toJSONString from both file and hardcoded dictionary
- (void)testToJSONString {
    NSDictionary *openObj = [SZTestUtils jsonForOpen];
    NSData *jsonData = [SZJSONUtils toJSONData:openObj];
    NSString *jsonString = [SZJSONUtils toJSONString:jsonData];
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
