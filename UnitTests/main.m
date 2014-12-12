//
//  main.m
//  UnitTests
//
//  Created by David Jedeikin on 9/11/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GHUnitIOS/GHUnit.h>///GHUnitIOSViewController.h>

//extern void __gcov_flush(void);

int main(int argc, char * argv[]) {
    @autoreleasepool {
        int retVal;
//        if (getenv("GHUNIT_CLI")) {
//            retVal = [GHTestRunner run];
//            __gcov_flush();
//        }
//        else {
            retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([GHUnitIOSAppDelegate class]));
//        }
        return retVal;
    }
}
