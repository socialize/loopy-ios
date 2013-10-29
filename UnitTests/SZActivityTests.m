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
#import <Social/Social.h>
#import <GHUnitIOS/GHUnit.h>
#import <OCMock/OCMock.h>

@interface SZActivityTests : GHTestCase {
    SZFacebookActivity *facebookActivity;
    SZTwitterActivity *twitterActivity;
    NSArray *dummyShareItems;
}

@end

@implementation SZActivityTests

- (void)setUpClass {
    dummyShareItems = @[@"MyShareItem1", @"MyShareItem2"];
    facebookActivity = [SZFacebookActivity initWithActivityItems:dummyShareItems];
    twitterActivity = [SZTwitterActivity initWithActivityItems:dummyShareItems];
}

//TODO these may become more meaningful
- (void)testActivityTitles {
    NSString *facebookTitle = [facebookActivity activityTitle];
    GHAssertNotNil(facebookTitle, @"");

    NSString *twitterTitle = [twitterActivity activityTitle];
    GHAssertNotNil(twitterTitle, @"");
}

- (void)testActivityTypes {
    NSString *facebookType = [facebookActivity activityType];
    BOOL match = [facebookType isEqualToString:SLServiceTypeFacebook];
    GHAssertTrue(match, @"");
    
    NSString *twitterType = [twitterActivity activityType];
    match = [twitterType isEqualToString:SLServiceTypeTwitter];
    GHAssertTrue(match, @"");
}

- (void)testActivityImages {
    UIImage *facebookImage = [facebookActivity activityImage];
    GHAssertNotNil(facebookImage, @"");
    
    UIImage *twitterImage = [twitterActivity activityImage];
    GHAssertNotNil(twitterImage, @"");
}

- (void)testCanPerformWithActivityItems {
    BOOL fb = [facebookActivity canPerformWithActivityItems:dummyShareItems];
    GHAssertTrue(fb, @"");
    BOOL tw = [twitterActivity canPerformWithActivityItems:dummyShareItems];
    GHAssertTrue(tw, @"");
}

@end
