//
//  SZAPIClient.h
//  Loopy
//
//  Created by David Jedeikin on 9/10/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <SZNetworking/SZNetworking.h>
#import <CoreLocation/CoreLocation.h>

@interface SZAPIClient : NSObject <NSURLConnectionDataDelegate,CLLocationManagerDelegate>

extern NSString *const OPEN;
extern NSString *const SHORTLINK;
extern NSString *const REPORT_SHARE;
extern NSTimeInterval const TIMEOUT;
extern NSString *const API_KEY;
extern NSString *const LOOPY_KEY;
extern NSString *const API_KEY_VAL;
extern NSString *const LOOPY_KEY_VAL;
extern NSString *const LANGUAGE_ID;
extern NSString *const LANGUAGE_VERSION;

@property (nonatomic, strong) NSString *urlPrefix;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSString *carrierName;
@property (nonatomic, strong) NSString *osVersion;
@property (nonatomic, strong) NSString *deviceModel;
@property (nonatomic, strong) NSUUID *idfa;
@property (nonatomic, strong) CLLocation *currentLocation;

- (id)initWithURLPrefix:(NSString *)url;
- (NSMutableURLRequest *)newURLRequest:(NSData *)jsonData
                         length:(NSNumber *)length
                       endpoint:(NSString *)endpoint;
- (SZURLRequestOperation *)newURLRequestOperation:(NSMutableURLRequest *)request;
- (NSNumber *)loopyErrorCode:(NSError *)error;
- (NSArray *)loopyErrorArray:(NSError *)error;
- (NSDictionary *)reportShareDictionary:(NSString *)shortlink channel:(NSString *)socialChannel;

- (void)open:(NSDictionary *)jsonDict withCallback:(void (^)(NSURLResponse *, NSData *, NSError *))callback;
- (void)shortlink:(NSDictionary *)jsonDict withCallback:(void (^)(NSURLResponse *, NSData *, NSError *))callback;
- (void)reportShare:(NSDictionary *)jsonDict withCallback:(void (^)(NSURLResponse *, NSData *, NSError *))callback;

@end
