//
//  SZShareTests.m
//  Loopy
//
//  Created by David Jedeikin on 10/23/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "SZShare.h"
#import "SZActivity.h"
#import "SZFacebookActivity.h"
#import "SZTwitterActivity.h"
#import "SZConstants.h"
#import <Social/Social.h>
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
    dummyShareItems = @[@"www.shortlink.com", @"More information about this site"];
    dummyActivities = @[[SZFacebookActivity initWithActivityItems:dummyShareItems], [SZTwitterActivity initWithActivityItems:dummyShareItems]];
}

- (void)testGetCurrentActivities {
    NSArray *activities = [share getCurrentActivities:dummyActivities];
    GHAssertNotNil(activities, @"");
}

- (void)testNewActivityViewController {
    UIActivityViewController *controller = [share newActivityViewController:dummyShareItems withActivities:dummyActivities];
    GHAssertNotNil(controller, @"");
}

- (void)testNewActivityShareController {
    for (id<SZActivity> activity in dummyActivities) {
        SLComposeViewController *controller = [share newActivityShareController:activity];
        GHAssertNotNil(controller, @"");
        GHAssertEqualStrings([activity activityType], [controller serviceType], @"");
    }
}

@end
