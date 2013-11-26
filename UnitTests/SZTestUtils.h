//
//  SZTestUtils.h
//  Loopy
//
//  Created by David Jedeikin on 9/30/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SZTestUtils : NSObject

+ (NSDictionary *)jsonForInstall;
+ (NSDictionary *)jsonForOpen;
+ (NSDictionary *)jsonForSTDID;
+ (NSDictionary *)jsonForShortlink;
+ (NSDictionary *)jsonForShare;
+ (NSDictionary *)addLatencyToMock:(int)latency forDictionary:(NSDictionary *)originalDict;

@end
