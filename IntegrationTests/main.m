//
//  main.m
//  IntegrationTests
//
//  Created by David Jedeikin on 9/12/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GHUnitIOS/GHUnitIOSViewController.h>

//extern void __gcov_flush(void);

int main(int argc, char * argv[]) {
    @autoreleasepool {
        int retVal;
//        if (getenv("GHUNIT_CLI")) {
//            retVal = [GHTestRunner run];
//            __gcov_flush();
//        }
//        else {
        retVal = UIApplicationMain(argc, argv, nil, @"GHUnitIOSAppDelegate");
//        }
        return retVal;
    }
}
