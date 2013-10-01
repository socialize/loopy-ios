//
//  SZAPIClient.h
//  Loopy
//
//  Created by David Jedeikin on 9/10/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SZAPIClient : NSObject <NSURLConnectionDataDelegate>

extern NSString *const OPEN;

@property (nonatomic) int responseCode;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSString *urlPrefix;

- (id)initWithURLPrefix:(NSString *)url;
- (NSURLConnection *)newURLConnection:(NSURLRequest *)request delegate:(id)delegate;
- (NSURLRequest *)newURLRequest:(NSData *)jsonData
                         length:(NSNumber *)length
                       endpoint:(NSString *)endpoint;
- (void)open:(NSDictionary *)jsonDict withConnection:(NSURLConnection *)connection;
- (NSDictionary *)responseDataToDictionary;
- (NSString *)responseDataToString;

@end
