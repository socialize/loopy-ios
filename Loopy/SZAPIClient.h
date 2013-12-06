//
//  SZAPIClient.h
//  Loopy
//
//  Created by David Jedeikin on 9/10/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <AFNetworking/AFNetworking.h>

@interface SZAPIClient : NSObject <NSURLConnectionDataDelegate,CLLocationManagerDelegate>

extern NSString *const INSTALL;
extern NSString *const OPEN;
extern NSString *const SHORTLINK;
extern NSString *const REPORT_SHARE;
extern NSString *const LOG;

extern NSTimeInterval const TIMEOUT;
extern NSString *const API_KEY;
extern NSString *const LOOPY_KEY;
extern NSString *const IDFA_KEY;
extern NSString *const STDID_KEY;
extern NSString *const LANGUAGE_ID;
extern NSString *const LANGUAGE_VERSION;
extern NSString *const IDENTITIES_FILENAME;

@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *loopyKey;
@property (nonatomic, strong) NSString *httpsURLPrefix;
@property (nonatomic, strong) NSString *urlPrefix;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSString *carrierName;
@property (nonatomic, strong) NSString *osVersion;
@property (nonatomic, strong) NSString *deviceModel;
@property (nonatomic, strong) NSUUID *idfa;
@property (nonatomic, strong) NSString *stdid;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) NSMutableDictionary *shortlinks;

- (id)initWithAPIKey:(NSString *)key loopyKey:(NSString *)lkey;
- (void)loadIdentitiesWithReferrer:(NSString *)referrer
                       postSuccess:(void(^)(AFHTTPRequestOperation *, id))postSuccessCallback
                           failure:(void(^)(AFHTTPRequestOperation *, NSError *))failureCallback;
- (void)updateIdentities;
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
- (NSDictionary *)stdidDictionary;
- (NSDictionary *)reportShareDictionary:(NSString *)shortlink channel:(NSString *)socialChannel;
- (NSDictionary *)logDictionaryWithType:(NSString *)type meta:(NSDictionary *)meta;

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

- (void)log:(NSDictionary *)jsonDict
    success:(void(^)(AFHTTPRequestOperation *, id))successCallback
    failure:(void(^)(AFHTTPRequestOperation *, NSError *))failureCallback;

@end
