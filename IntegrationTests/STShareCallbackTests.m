//
//  STShareCallbackTests.m
//  Loopy
//
//  Created by David Jedeikin on 10/24/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "STShareActivityUI.h"
#import "STFacebookActivity.h"
#import "STTwitterActivity.h"
#import "STConstants.h"
#import <GHUnitIOS/GHUnit.h>
#import <OCMock/OCMock.h>

@interface STShareCallbackTests : GHAsyncTestCase {
    id share;
    STFacebookActivity *facebookActivity;
    STTwitterActivity *twitterActivity;
    NSArray *shareItems;
    NSArray *activities;
    BOOL facebookShared;
    BOOL twitterShared;
}

@end

@implementation STShareCallbackTests

- (void)setUpClass {
    facebookActivity = [[STFacebookActivity alloc] init];
    twitterActivity = [[STTwitterActivity alloc] init];
    
    share = [[STShareActivityUI alloc] initWithParent:nil apiClient:nil];
    activities = @[facebookActivity, twitterActivity];
    shareItems = @[@"ShareItem1",@"ShareItem2"];

    facebookShared = NO;
    twitterShared = NO;
}

//simulate FB share being selected
- (void)testFacebookShareCallbacks {
    id mockShare = [OCMockObject partialMockForObject:share];
    [[[mockShare stub] andReturn:activities] getDefaultActivities:shareItems];
    [self prepare];
    [[[mockShare stub] andCall:@selector(shareFacebookCallback:) onObject:self] handleShareDidBegin:[OCMArg any]];
    [facebookActivity prepareWithActivityItems:shareItems];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
    
    GHAssertTrue(facebookShared, @"");
}

//callback from share test
- (void)shareFacebookCallback:(NSNotification *)notification{
    facebookShared = YES;
    [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testFacebookShareCallbacks)];
}


//simulate TW share being selected
- (void)testTwitterShareCallbacks {
    [self prepare];
    id mockShare = [OCMockObject partialMockForObject:share];
    [[[mockShare stub] andReturn:activities] getDefaultActivities:shareItems];
    [[[mockShare stub] andCall:@selector(shareTwitterCallback:) onObject:self] handleShareDidBegin:[OCMArg any]];
    [twitterActivity prepareWithActivityItems:shareItems];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
    
    GHAssertTrue(twitterShared, @"");
}

//callback from share test
- (void)shareTwitterCallback:(NSNotification *)notification{
    twitterShared = YES;
    [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testTwitterShareCallbacks)];
}

//TODO the share complete callback doesn't do anything yet...
- (void)testHandleShareComplete {
    STFacebookActivity *dummyActivity = [[STFacebookActivity alloc] init];
    dummyActivity.shareItems = shareItems;
    NSNotification *dummyNotification = [NSNotification notificationWithName:LoopyShareDidComplete object:dummyActivity];
    [share handleShareDidComplete:dummyNotification];
}

@end
