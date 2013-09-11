//
//  SZAPIClient.m
//  Loopy
//
//  Created by David Jedeikin on 9/10/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "SZAPIClient.h"

@implementation SZAPIClient

@synthesize responseData = _responseData;

- (void)open {
    self.responseData = [NSMutableData data];
    /*
     {
         "stdid": "69",
         "timestamp": 1234567890,
         "referrer": "origin of open",
         "device" : {
             "model" : "Nexus 4",
             "os" : "ios",
             "osv" : "6.1",
             "carrier" : "verizon",
             "wifi" : "on",
             "geo": {
                 "lat" : 123.456,
                 "lon" : 78.000
             }
         },
         "app" : {
             "id" : "com.socialize.appname",
             "name" : "App Name",
             "version": "123.4"
         },
         "client" : {
             "lang" : "java",
             "version": "123.4"
         },
         "mock": {
             "http": 200
         }
     }
     */
    
    //build an open object and convert to json
    NSError *jsonError;
    NSDictionary *geoObj = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithDouble:12.456],@"lat",
                            [NSNumber numberWithDouble:78.900],@"lon",
                            nil];
    NSDictionary *deviceObj = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"iPhone 4S",@"model",
                               @"ios",@"os",
                               @"6.1",@"osv",
                               @"verizon",@"carrier",
                               @"on",@"wifi",
                               geoObj,@"geo",
                               nil];
    NSDictionary *appObj = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"com.socialize.appname",@"id",
                            @"App Name",@"name",
                            @"123.4",@"version",
                            nil];
    NSDictionary *clientObj = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"objc",@"lang",
                               @"1.3",@"version",
                               nil];
    NSDictionary *mockObj = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"200",@"http",
                               nil];
    NSDictionary *openObj = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"69",@"stdid",
                             [NSNumber numberWithInt:1234567890],@"timestamp",
                             @"ABCDEF",@"referrer",
                             deviceObj,@"device",
                             appObj,@"app",
                             clientObj,@"client",
                             mockObj,@"mock",
                             nil];
    BOOL isValid = [NSJSONSerialization isValidJSONObject:openObj];
    if(isValid) {
        NSData *jsonOpenObj = [NSJSONSerialization dataWithJSONObject:openObj
                                                              options:NSJSONWritingPrettyPrinted
                                                                error:&jsonError];
        NSString *jsonOpenObjStr = nil;
        if (!jsonOpenObj && jsonError) {
            //TODO handle error
        } else {
            jsonOpenObjStr = [[NSString alloc] initWithData:jsonOpenObj encoding:NSUTF8StringEncoding];
        }
        NSURL *url = [NSURL URLWithString:@"http://ec2-54-227-157-217.compute-1.amazonaws.com:8080/loopymock/open"];
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

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int code = [httpResponse statusCode];
    NSLog(@"didReceiveResponse; code: %d", code);
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    NSLog(@"Connection failed: %@", [error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[self.responseData length]);
    
    //try converting to JSON
    NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingAllowFragments error:&error];
    
    if(!result && self.responseData) {
        NSLog(@"result: %@", self.responseData);
        NSString *resultStr = [[NSString alloc] initWithBytes:[self.responseData bytes] length:[self.responseData length] encoding: NSASCIIStringEncoding];
        NSLog(@"resultStr: %@", resultStr);
    }
    else {
        //TODO
    }
//    //error
//    if(error && !resultDict) {
//        NSLog(@"ERROR code: %d", error.code);
//        for(id key in error.userInfo) {
//            id value = [error.userInfo objectForKey:key];
//            NSString *keyAsString = (NSString *)key;
//            NSString *valueAsString = (NSString *)value;
//            
//            NSLog(@"ERROR key: %@", keyAsString);
//            NSLog(@"ERROR value: %@", valueAsString);
//        }
//    }
//    
//    // show all values
//    for(id key in resultDict) {
//        id value = [resultDict objectForKey:key];
//        NSString *keyAsString = (NSString *)key;
//        NSString *valueAsString = (NSString *)value;
//        
//        NSLog(@"key: %@", keyAsString);
//        NSLog(@"value: %@", valueAsString);
//    }
}
@end
