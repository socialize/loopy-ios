//
//  TestAppNoInitTests.m
//  TestAppNoInitTests
//
//  Created by David Jedeikin on 2/12/14.
//  Copyright (c) 2014 ShareThis. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface TestAppNoInitTests : XCTestCase

@end

@implementation TestAppNoInitTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
