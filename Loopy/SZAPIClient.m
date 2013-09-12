//
//  SZAPIClient.m
//  Loopy
//
//  Created by David Jedeikin on 9/10/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "SZAPIClient.h"

@implementation SZAPIClient

NSString *const OPEN = @"/open";

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

- (void)open:(NSDictionary *)openJSON {
    self.responseData = [NSMutableData data];
    BOOL isValid = [NSJSONSerialization isValidJSONObject:openJSON];
    if(isValid) {
        NSData *jsonOpenObj = [self toJSONData:openJSON];
        NSString *jsonOpenObjStr = [self toJSONString:jsonOpenObj];
        if (jsonOpenObj) {
            jsonOpenObjStr = [self toJSONString:jsonOpenObj];
        }

        NSString *urlStr = [NSString stringWithFormat:@"%@%@", urlPrefix, OPEN];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%d", [jsonOpenObjStr length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:jsonOpenObj];
        
        NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        if(!connection) {
            NSLog(@"Error creating URL connection.");
        }
    }
    else {
        //TODO handle error
    }
}

//convert JSON dictionary to NSData
- (NSData *)toJSONData:(NSDictionary *)jsonDict {
    NSError *jsonError;
    NSData *jsonObj = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                      options:NSJSONWritingPrettyPrinted
                                                        error:&jsonError];
    if (!jsonObj && jsonError) {
        NSLog(@"Error creating JSON data.");
        [self logError:jsonError];
    }
    
    return jsonObj;
}

//convert JSON dictionary to String
- (NSString *)toJSONString:(NSData *)jsonData {
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

//error logging
- (void)logError:(NSError *)error {
    NSLog(@"ERROR code: %d", error.code);
    for(id key in error.userInfo) {
        id value = [error.userInfo objectForKey:key];
        NSString *keyAsString = (NSString *)key;
        NSString *valueAsString = (NSString *)value;
        
        NSLog(@"ERROR key: %@", keyAsString);
        NSLog(@"ERROR value: %@", valueAsString);
    }
}

//protocol impl
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int code = [httpResponse statusCode];
    NSLog(@"didReceiveResponse; code: %d", code);
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
    NSLog(@"Succeeded! Received %d bytes of data",[self.responseData length]);
    
    //try converting to JSON
    NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingAllowFragments error:&error];
    
    //error of some kind
    if(!result && self.responseData) {
        NSLog(@"result: %@", self.responseData);
        NSString *resultStr = [[NSString alloc] initWithBytes:[self.responseData bytes] length:[self.responseData length] encoding: NSASCIIStringEncoding];
        NSLog(@"resultStr: %@", resultStr);
        
        //error
        if(error) {
            NSLog(@"ERROR code: %d", error.code);
            for(id key in error.userInfo) {
                id value = [error.userInfo objectForKey:key];
                NSString *keyAsString = (NSString *)key;
                NSString *valueAsString = (NSString *)value;
                
                NSLog(@"ERROR key: %@", keyAsString);
                NSLog(@"ERROR value: %@", valueAsString);
            }
        }
    }
    //valid JSON
    else {
        NSDictionary *resultDict = (NSDictionary *)result;
        // show all values
        for(id key in resultDict) {
            id value = [resultDict objectForKey:key];
            NSString *keyAsString = (NSString *)key;
            NSString *valueAsString = (NSString *)value;
            
            NSLog(@"key: %@", keyAsString);
            NSLog(@"value: %@", valueAsString);
        }
    }
}
@end
