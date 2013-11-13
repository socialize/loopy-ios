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
#import "SZAPIClient.h"
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
    SZAPIClient *dummyAPIClient = (SZAPIClient *)[OCMockObject mockForClass:[SZAPIClient class]];
    share = [[SZShare alloc] initWithParent:dummyController apiClient:dummyAPIClient];
    dummyShareItems = @[@"www.shortlink.com", @"More information about this site"];
    
    //add activity items as a setter (i.e. no notification of intent to share)
    SZFacebookActivity *fbActivity = [[SZFacebookActivity alloc] init];
    SZTwitterActivity *twActivity = [[SZTwitterActivity alloc] init];
    fbActivity.shareItems = dummyShareItems;
    twActivity.shareItems = dummyShareItems;
    dummyActivities = @[fbActivity, twActivity];
}

- (void)testGetCurrentActivities {
    NSArray *activities = [share getDefaultActivities:dummyActivities];
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
