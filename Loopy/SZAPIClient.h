//
//  SZAPIClient.h
//  Loopy
//
//  Created by David Jedeikin on 9/10/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SZNetworking/SZNetworking.h>

@interface SZAPIClient : NSObject <NSURLConnectionDataDelegate>

extern NSString *const OPEN;

@property (nonatomic, strong) NSString *urlPrefix;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

- (id)initWithURLPrefix:(NSString *)url;
- (NSMutableURLRequest *)newURLRequest:(NSData *)jsonData
                         length:(NSNumber *)length
                       endpoint:(NSString *)endpoint;
- (SZURLRequestOperation *)newURLRequestOperation:(NSMutableURLRequest *)request;
- (void)open:(NSDictionary *)jsonDict withCallback:(void (^)(NSURLResponse *, NSData *, NSError *))callback; //TEST with NEW SZNetworking

@end
