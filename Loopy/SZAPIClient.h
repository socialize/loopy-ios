//
//  SZAPIClient.h
//  Loopy
//
//  Created by David Jedeikin on 9/10/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SZAPIClient : NSObject

@property (nonatomic, strong) NSMutableData *responseData;

- (void)open;

@end
