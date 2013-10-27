//
//  SZActivityTests.m
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

@interface SZActivityTests : GHTestCase {
    SZFacebookActivity *facebookActivity;
    SZTwitterActivity *twitterActivity;
}

@end

@implementation SZActivityTests

- (void)setUpClass {
    facebookActivity = [[SZFacebookActivity alloc] init];
    twitterActivity = [[SZTwitterActivity alloc] init];
}

//TODO these may become more meaningful
- (void)testActivityTitles {
    NSString *facebookTitle = [facebookActivity activityTitle];
    GHAssertNotNil(facebookTitle, @"");

    NSString *twitterTitle = [twitterActivity activityTitle];
    GHAssertNotNil(twitterTitle, @"");
}

//TODO these may become more meaningful
- (void)testActivityTypes {
    NSString *facebookType = [facebookActivity activityType];
    GHAssertNotNil(facebookType, @"");
    
    NSString *twitterType = [twitterActivity activityType];
    GHAssertNotNil(twitterType, @"");
}

- (void)testActivityImages {
    UIImage *facebookImage = [facebookActivity activityImage];
    GHAssertNotNil(facebookImage, @"");
    
    UIImage *twitterImage = [twitterActivity activityImage];
    GHAssertNotNil(twitterImage, @"");
}

- (void)testCanPerformWithActivityItems {
    NSArray *dummyShareItems = @[@"MyShareItem1", @"MyShareItem2"];
    BOOL fb = [facebookActivity canPerformWithActivityItems:dummyShareItems];
    GHAssertTrue(fb, @"");
    BOOL tw = [twitterActivity canPerformWithActivityItems:dummyShareItems];
    GHAssertTrue(tw, @"");
}

@end
