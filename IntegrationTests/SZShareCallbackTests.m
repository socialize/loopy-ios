//
//  SZShareCallbackTests.m
//  Loopy
//
//  Created by David Jedeikin on 10/24/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "SZShare.h"
#import "SZFacebookActivity.h"
#import "SZTwitterActivity.h"
#import "SZConstants.h"
#import <GHUnitIOS/GHUnit.h>
#import <OCMock/OCMock.h>

@interface SZShareCallbackTests : GHAsyncTestCase {
    id share;
    SZFacebookActivity *facebookActivity;
    SZTwitterActivity *twitterActivity;
    NSArray *shareItems;
    NSArray *activities;
    BOOL facebookShared;
    BOOL twitterShared;
}

@end

@implementation SZShareCallbackTests

- (void)setUpClass {
    facebookActivity = [[SZFacebookActivity alloc] init];
    twitterActivity = [[SZTwitterActivity alloc] init];
    
    share = [[SZShare alloc] initWithParent:nil];
    activities = @[facebookActivity, twitterActivity];
    shareItems = @[@"ShareItem1",@"ShareItem2"];

    facebookShared = NO;
    twitterShared = NO;
}

//simulate FB share being selected
- (void)testFacebookShareCallbacks {
    id mockShare = [OCMockObject partialMockForObject:share];
    [[[mockShare stub] andReturn:activities] getCurrentActivities];
    [self prepare];
    [[[mockShare stub] andCall:@selector(shareFacebookCallback:) onObject:self] handleBeginShare:[OCMArg any]];
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
    [[[mockShare stub] andReturn:activities] getCurrentActivities];
    [[[mockShare stub] andCall:@selector(shareTwitterCallback:) onObject:self] handleBeginShare:[OCMArg any]];
    [twitterActivity prepareWithActivityItems:shareItems];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
    
    GHAssertTrue(twitterShared, @"");
}

//callback from share test
- (void)shareTwitterCallback:(NSNotification *)notification{
    twitterShared = YES;
    [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testTwitterShareCallbacks)];
}

@end
