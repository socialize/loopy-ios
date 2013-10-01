//
//  main.m
//  IntegrationTests
//
//  Created by David Jedeikin on 9/12/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GHUnitIOS/GHUnitIOSViewController.h>

int main(int argc, char * argv[]) {
    int retVal;
    @autoreleasepool {
        if (getenv("GHUNIT_CLI")) {
            retVal = [GHTestRunner run];
        }
        else {
            retVal = UIApplicationMain(argc, argv, nil, @"GHUnitIOSAppDelegate");
        }
    }
    return retVal;
}
