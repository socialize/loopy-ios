//
//  STAPIClient.h
//  Loopy
//
//  Created by David Jedeikin on 9/10/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "STDeviceSettings.h"

@interface STAPIClient : NSObject <NSURLConnectionDataDelegate>

extern NSString *const INSTALL;
extern NSString *const OPEN;
extern NSString *const SHORTLINK;
extern NSString *const REPORT_SHARE;
extern NSString *const SHARELINK;
extern NSString *const LOG;

extern NSString *const OPEN_TIMEOUT_KEY;
extern NSString *const CALL_TIMEOUT_KEY;
extern NSString *const API_KEY;
extern NSString *const LOOPY_KEY;
extern NSString *const STDID_KEY;
extern NSString *const MD5ID_KEY;
extern NSString *const LAST_OPEN_TIME_KEY;
extern NSString *const LANGUAGE_ID;
extern NSString *const LANGUAGE_VERSION;
extern NSString *const SESSION_DATA_FILENAME;

@property (nonatomic) NSTimeInterval callTimeout;
@property (nonatomic) NSTimeInterval openTimeout;
@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *loopyKey;
@property (nonatomic, strong) NSString *httpsURLPrefix;
@property (nonatomic, strong) NSString *urlPrefix;
@property (nonatomic, strong) NSString *stdid;
@property (nonatomic, strong) NSMutableDictionary *shortlinks;
@property (nonatomic, strong) STDeviceSettings *deviceSettings;

- (id)initWithAPIKey:(NSString *)key
            loopyKey:(NSString *)lkey;
- (id)initWithAPIKey:(NSString *)key
            loopyKey:(NSString *)lkey
   locationsDisabled:(BOOL)locationServicesDisabled;
- (void)getSessionWithReferrer:(NSString *)referrer
                   postSuccess:(void(^)(AFHTTPRequestOperation *, id))postSuccessCallback
                       failure:(void(^)(AFHTTPRequestOperation *, NSError *))failureCallback;
- (NSMutableURLRequest *)newURLRequest:(NSData *)jsonData
                                length:(NSNumber *)length
                              endpoint:(NSString *)endpoint;
- (NSMutableURLRequest *)newHTTPSURLRequest:(NSData *)jsonData
                                     length:(NSNumber *)length
                                   endpoint:(NSString *)endpoint;
- (AFHTTPRequestOperation *)newURLRequestOperation:(NSURLRequest *)request
                                           isHTTPS:(BOOL)https
                                           success:(void(^)(AFHTTPRequestOperation *, id))successCallback
                                           failure:(void(^)(AFHTTPRequestOperation *, NSError *))failureCallback;
- (NSNumber *)loopyErrorCode:(NSDictionary *)errorDict;
- (NSArray *)loopyErrorArray:(NSDictionary *)errorDict;
- (NSDictionary *)installDictionaryWithReferrer:(NSString *)referrer;
- (NSDictionary *)openDictionaryWithReferrer:(NSString *)referrer;
- (NSDictionary *)reportShareDictionary:(NSString *)shortlink channel:(NSString *)socialChannel;
- (NSDictionary *)logDictionaryWithType:(NSString *)type meta:(NSDictionary *)meta;
- (NSDictionary *)shortlinkDictionary:(NSString *)link
                                title:(NSString *)title
                                 meta:(NSDictionary *)meta
                                 tags:(NSArray *)tags;
- (NSDictionary *)sharelinkDictionary:(NSString *)link
                              channel:(NSString *)socialChannel
                                title:(NSString *)title
                                 meta:(NSDictionary *)meta
                                 tags:(NSArray *)tags;

- (void)install:(NSDictionary *)jsonDict
        success:(void(^)(AFHTTPRequestOperation *, id))successCallback
        failure:(void(^)(AFHTTPRequestOperation *, NSError *))failureCallback;

- (void)open:(NSDictionary *)jsonDict
     success:(void(^)(AFHTTPRequestOperation *, id))successCallback
     failure:(void(^)(AFHTTPRequestOperation *, NSError *))failureCallback;

- (void)shortlink:(NSDictionary *)jsonDict
          success:(void(^)(AFHTTPRequestOperation *, id))successCallback
          failure:(void(^)(AFHTTPRequestOperation *, NSError *))failureCallback;

- (void)reportShare:(NSDictionary *)jsonDict
            success:(void(^)(AFHTTPRequestOperation *, id))successCallback
            failure:(void(^)(AFHTTPRequestOperation *, NSError *))failureCallback;

- (void)sharelink:(NSDictionary *)jsonDict
          success:(void(^)(AFHTTPRequestOperation *, id))successCallback
          failure:(void(^)(AFHTTPRequestOperation *, NSError *))failureCallback;

- (void)log:(NSDictionary *)jsonDict
    success:(void(^)(AFHTTPRequestOperation *, id))successCallback
    failure:(void(^)(AFHTTPRequestOperation *, NSError *))failureCallback;

@end
