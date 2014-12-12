//
//  MyTest.m
//
#import <GHUnit/GHUnit.h>
#import <OCMock/OCMock.h>
#import "Loopy.h"
#import "STJSONUtils.h"
#import "STTestUtils.h"

@interface MyTest : GHTestCase
@end

@implementation MyTest

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

@end
