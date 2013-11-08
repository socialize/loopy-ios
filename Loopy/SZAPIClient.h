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
extern NSString *const SHORTLINK;
extern NSString *const SHARE;
extern NSTimeInterval const TIMEOUT;
extern NSString *const API_KEY;
extern NSString *const LOOPY_KEY;
extern NSString *const API_KEY_VAL;
extern NSString *const LOOPY_KEY_VAL;

@property (nonatomic, strong) NSString *urlPrefix;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

- (id)initWithURLPrefix:(NSString *)url;
- (NSMutableURLRequest *)newURLRequest:(NSData *)jsonData
                         length:(NSNumber *)length
                       endpoint:(NSString *)endpoint;
- (SZURLRequestOperation *)newURLRequestOperation:(NSMutableURLRequest *)request;
- (NSNumber *)loopyErrorCode:(NSError *)error;
- (NSArray *)loopyErrorArray:(NSError *)error;

- (void)open:(NSDictionary *)jsonDict withCallback:(void (^)(NSURLResponse *, NSData *, NSError *))callback;
- (void)shortlink:(NSDictionary *)jsonDict withCallback:(void (^)(NSURLResponse *, NSData *, NSError *))callback;
- (void)share:(NSDictionary *)jsonDict withCallback:(void (^)(NSURLResponse *, NSData *, NSError *))callback;

@end
