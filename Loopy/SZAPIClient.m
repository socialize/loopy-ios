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
NSString *const SHORTLINK = @"/shortlink";
NSString *const SHARE = @"/share";
NSTimeInterval const TIMEOUT = 1.0f;
NSString *const API_KEY = @"X-LoopyAppID";
NSString *const LOOPY_KEY = @"X-LoopyKey";
NSString *const API_KEY_VAL = @"4q7cd6ngw3vu7gram5b9b9t6"; //TODO real key
NSString *const LOOPY_KEY_VAL = @"LOOPY_KEY"; //TODO real key

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
                                                       timeoutInterval:TIMEOUT];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:API_KEY_VAL forHTTPHeaderField:API_KEY];
    [request setValue:LOOPY_KEY_VAL forHTTPHeaderField:LOOPY_KEY];
    [request setValue:[length stringValue] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    return request;
}

//factory method for URLRequestOperation for specified request
- (SZURLRequestOperation *)newURLRequestOperation:(NSMutableURLRequest *)request {
    return [[SZURLRequestOperation alloc] initWithURLRequest:request];
}

//Returns error code 
//if code is nil or no error value contained, returns nil
- (NSNumber *)loopyErrorCode:(NSError *)error {
    NSNumber *errorCode = nil;
    if(error) {
        NSDictionary *userInfo = error.userInfo;
        id responseBody = [userInfo valueForKey:@"SZErrorURLResponseBodyKey"];
        if([responseBody isKindOfClass:[NSData class]]) {
            NSDictionary *errorDict = [SZJSONUtils toJSONDictionary:(NSData *)responseBody];
            id codeObj = [errorDict valueForKey:@"code"];
            if([codeObj isKindOfClass:[NSNumber class]]) {
                errorCode = (NSNumber *)codeObj;
            }
        }
    }
    return errorCode;
}

//Returns array of error values taken from the userInfo portion of error returned from request
//if error is nil or no error value contained, returns nil
- (NSArray *)loopyErrorArray:(NSError *)error {
    NSArray *errorArray = nil;
    if(error) {
        NSDictionary *userInfo = error.userInfo;
        id responseBody = [userInfo valueForKey:@"SZErrorURLResponseBodyKey"];
        if([responseBody isKindOfClass:[NSData class]]) {
            NSDictionary *errorDict = [SZJSONUtils toJSONDictionary:(NSData *)responseBody];
            id errorObj = [errorDict valueForKey:@"error"];
            
            if([errorObj isKindOfClass:[NSArray class]]) {
                errorArray = (NSArray *)errorObj;
            }
        }
    }
    return errorArray;
}


//calls open endpoint, including manufacturing URLRequest for it
- (void)open:(NSDictionary *)jsonDict withCallback:(void (^)(NSURLResponse *, NSData *, NSError *))callback {
    [self callEndpoint:OPEN withJSON:jsonDict andCallback:callback];
}

//calls shortlink endpoint, including manufacturing URLRequest for it
- (void)shortlink:(NSDictionary *)jsonDict withCallback:(void (^)(NSURLResponse *, NSData *, NSError *))callback {
    [self callEndpoint:SHORTLINK withJSON:jsonDict andCallback:callback];
}

- (void)share:(NSDictionary *)jsonDict withCallback:(void (^)(NSURLResponse *, NSData *, NSError *))callback {
    [self callEndpoint:SHARE withJSON:jsonDict andCallback:callback];
}

//convenience method
- (void)callEndpoint:(NSString *)endpoint
            withJSON:(NSDictionary *)jsonDict
        andCallback:(void (^)(NSURLResponse *, NSData *, NSError *))callback {
    NSData *jsonData = [SZJSONUtils toJSONData:jsonDict];
    NSString *jsonStr = [SZJSONUtils toJSONString:jsonData];
    NSNumber *jsonLength = [NSNumber numberWithInt:[jsonStr length]];
    NSMutableURLRequest *request = [self newURLRequest:jsonData
                                                length:jsonLength
                                              endpoint:endpoint];
    SZURLRequestOperation *operation = [self newURLRequestOperation:request];
    operation.URLCompletionBlock = callback;
    [operationQueue addOperation:operation];
}

@end
