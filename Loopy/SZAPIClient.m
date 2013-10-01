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

@synthesize responseCode;
@synthesize responseData;
@synthesize urlPrefix;

//constructor with specified endpoint
- (id)initWithURLPrefix:(NSString *)url {
    self = [super init];
    if(self) {
        self.urlPrefix = url;
    }
    return self;
}

//factory method for URLConnection
- (NSURLConnection *)newURLConnection:(NSURLRequest *)request delegate:(id)delegate {
    return [[NSURLConnection alloc] initWithRequest:request
                                           delegate:delegate
                                   startImmediately:NO];
}

//factory method for URLRequest for specified JSON data and endpoint
- (NSURLRequest *)newURLRequest:(NSData *)jsonData
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

//calls open endpoint
- (void)open:(NSDictionary *)jsonDict withConnection:(NSURLConnection *)connection {
    self.responseData = [NSMutableData data];
    [connection start];
}

//protocol impl
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    self.responseCode = [httpResponse statusCode];
    NSLog(@"didReceiveResponse; code: %d", self.responseCode);
    [self.responseData setLength:0];
}

//protocol impl
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

//protocol impl
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    NSLog(@"Connection failed: %@", [error description]);
}

//protocol impl
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    
    //success
    if(self.responseCode == 200) {
        NSLog(@"Succeeded! Received %d bytes of data",[self.responseData length]);
    }
    else {
        NSLog(@"FAILED; responseCode: %d; responseData: %@", self.responseCode, [self responseDataToString]);
    }
}

//returns response JSON data as NSDictionary
- (NSDictionary *)responseDataToDictionary {
    NSError *error = nil;
    return (NSDictionary *)[NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingAllowFragments error:&error];
}

//returns Stringified version of response JSON data
- (NSString *)responseDataToString {
    return [[NSString alloc] initWithBytes:[self.responseData bytes] length:[self.responseData length] encoding: NSASCIIStringEncoding];
}

@end
