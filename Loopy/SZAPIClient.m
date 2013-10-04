//
//  SZAPIClient.m
//  Loopy
//
//  Created by David Jedeikin on 9/10/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "SZAPIClient.h"
#import "SZJSONUtils.h"

@implementation SZAPIClient

NSString *const OPEN = @"/open";

@synthesize urlPrefix;
@synthesize operationQueue;

//constructor with specified endpoint
- (id)initWithURLPrefix:(NSString *)url {
    self = [super init];
    if(self) {
        self.urlPrefix = url;
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 5;
    }
    return self;
}

//factory method for URLRequest for specified JSON data and endpoint
- (NSMutableURLRequest *)newURLRequest:(NSData *)jsonData
                         length:(NSNumber *)length
                       endpoint:(NSString *)endpoint {
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", urlPrefix, endpoint];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[length stringValue] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    return request;
}

//factory method for URLRequestOperation for specified request
- (SZURLRequestOperation *)newURLRequestOperation:(NSMutableURLRequest *)request {
    return [[SZURLRequestOperation alloc] initWithURLRequest:request];
}

//calls open endpoint, including manufacturing URLRequest for it
- (void)open:(NSDictionary *)jsonDict withCallback:(void (^)(NSURLResponse *, NSData *, NSError *))callback {
    NSData *jsonData = [SZJSONUtils toJSONData:jsonDict];
    NSString *jsonStr = [SZJSONUtils toJSONString:jsonData];
    NSNumber *jsonLength = [NSNumber numberWithInt:[jsonStr length]];
    NSMutableURLRequest *request = [self newURLRequest:jsonData
                                                length:jsonLength
                                              endpoint:OPEN];
    SZURLRequestOperation *operation = [self newURLRequestOperation:request];
    operation.URLCompletionBlock = callback;
    [operationQueue addOperation:operation];
}

@end
