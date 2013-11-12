//
//  SZJSONUtils.m
//  Loopy
//
//  Created by David Jedeikin on 9/13/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "SZJSONUtils.h"

@implementation SZJSONUtils

//convert JSON dictionary to NSData
+ (NSData *)toJSONData:(NSDictionary *)jsonDict {
    NSError *jsonError;
    NSData *jsonObj = nil;
    @try {
        jsonObj = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                  options:NSJSONWritingPrettyPrinted
                                                    error:&jsonError];
    }
    @catch (NSException *exception) {
        [self logError:jsonError];
    }
    
    return jsonObj;
}

//convert JSON dictionary to NSString
+ (NSString *)toJSONString:(NSData *)jsonData {
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

//convert JSON data to NSDictionary
+ (NSDictionary *)toJSONDictionary:(NSData *)jsonData {
    NSError *error = nil;
    return (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData
                                                           options:NSJSONReadingAllowFragments
                                                             error:&error];
}

//error logging
+ (void)logError:(NSError *)error {
    //TODO have these output to an actual log
//    NSLog(@"ERROR code: %d", error.code);
    for(id key in error.userInfo) {
        id value = [error.userInfo objectForKey:key];
        NSString *keyAsString = (NSString *)key;
        NSString *valueAsString = (NSString *)value;
        
        //TODO have these output to an actual log
//        NSLog(@"ERROR key: %@", keyAsString);
//        NSLog(@"ERROR value: %@", valueAsString);
    }
}

@end
