//
//  SZShareTests.m
//  Loopy
//
//  Created by David Jedeikin on 10/23/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "SZShare.h"
#import "SZFacebookActivity.h"
#import "SZTwitterActivity.h"
#import "SZConstants.h"
#import <GHUnitIOS/GHUnit.h>
#import <OCMock/OCMock.h>

@interface SZShareTests : GHTestCase {
    SZShare *share;
    NSArray *dummyActivities;
    NSArray *dummyShareItems;
}
@end

@implementation SZShareTests

- (void)setUpClass {
    UIViewController *dummyController = (UIViewController *)[OCMockObject mockForClass:[UIViewController class]];
    share = [[SZShare alloc] initWithParent:dummyController];
    dummyActivities = @[[[SZFacebookActivity alloc] init], [[SZTwitterActivity alloc] init]];
    dummyShareItems = @[@"MyShareItem1", @"MyShareItem2"];
}

- (void)testGetCurrentActivities {
    NSArray *activities = [share getCurrentActivities];
    GHAssertNotNil(activities, @"");
}

- (void)testNewActivityViewController {
    UIActivityViewController *controller = [share newActivityViewController:dummyShareItems withActivities:dummyActivities];
    GHAssertNotNil(controller, @"");
}

@end
