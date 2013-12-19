//
//  STShareTests.m
//  Loopy
//
//  Created by David Jedeikin on 10/23/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "STShare.h"
#import "STActivity.h"
#import "STFacebookActivity.h"
#import "STTwitterActivity.h"
#import "STConstants.h"
#import "STAPIClient.h"
#import <Social/Social.h>
#import <GHUnitIOS/GHUnit.h>
#import <OCMock/OCMock.h>

@interface STShareTests : GHTestCase {
    STShare *share;
    NSArray *dummyActivities;
    NSArray *dummyShareItems;
}
@end

@implementation STShareTests

- (void)setUpClass {
    UIViewController *dummyController = (UIViewController *)[OCMockObject mockForClass:[UIViewController class]];
    STAPIClient *dummyAPIClient = (STAPIClient *)[OCMockObject mockForClass:[STAPIClient class]];
    share = [[STShare alloc] initWithParent:dummyController apiClient:dummyAPIClient];
    dummyShareItems = @[@"www.shortlink.com", @"More information about this site"];
    
    //add activity items as a setter (i.e. no notification of intent to share)
    STFacebookActivity *fbActivity = [[STFacebookActivity alloc] init];
    STTwitterActivity *twActivity = [[STTwitterActivity alloc] init];
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
    for (id<STActivity> activity in dummyActivities) {
        SLComposeViewController *controller = [share newActivityShareController:activity];
        GHAssertNotNil(controller, @"");
        GHAssertEqualStrings([activity activityType], [controller serviceType], @"");
    }
}

@end
