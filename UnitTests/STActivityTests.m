//
//  STActivityTests.m
//  Loopy
//
//  Created by David Jedeikin on 10/24/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "STShareActivityUI.h"
#import "STFacebookActivity.h"
#import "STTwitterActivity.h"
#import "STConstants.h"
#import <Social/Social.h>
#import <GHUnitIOS/GHUnit.h>
#import <OCMock/OCMock.h>

@interface STActivityTests : GHTestCase {
    STFacebookActivity *facebookActivity;
    STTwitterActivity *twitterActivity;
    NSArray *dummyShareItems;
}

@end

@implementation STActivityTests

- (void)setUpClass {
    dummyShareItems = @[@"MyShareItem1", @"MyShareItem2"];
    facebookActivity = [[STFacebookActivity alloc] init];
    twitterActivity = [[STTwitterActivity alloc] init];
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

@end
