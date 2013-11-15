//
//  SZAPIClient.m
//  Loopy
//
//  Created by David Jedeikin on 9/10/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "SZAPIClient.h"
#import "SZJSONUtils.h"
#import "Reachability.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <AdSupport/ASIdentifierManager.h>
#import <sys/utsname.h>

@implementation SZAPIClient

NSString *const OPEN = @"/open";
NSString *const SHORTLINK = @"/shortlink";
NSString *const REPORT_SHARE = @"/share";
NSTimeInterval const TIMEOUT = 1.0f;
NSString *const API_KEY = @"X-LoopyAppID";
NSString *const LOOPY_KEY = @"X-LoopyKey";
NSString *const API_KEY_VAL = @"4q7cd6ngw3vu7gram5b9b9t6"; //TODO real key
NSString *const LOOPY_KEY_VAL = @"LOOPY_KEY"; //TODO real key
NSString *const LANGUAGE_ID = @"objc";
NSString *const LANGUAGE_VERSION = @"1.3";

@synthesize urlPrefix;
@synthesize operationQueue;
@synthesize locationManager;
@synthesize carrierName;
@synthesize osVersion;
@synthesize deviceModel;
@synthesize idfa;
@synthesize stdid;
@synthesize currentLocation;

//constructor with specified endpoint
- (id)initWithURLPrefix:(NSString *)url {
    self = [super init];
    if(self) {
        self.urlPrefix = url;
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 5;
        
        //device information cached for sharing and other operations
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
        CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = [networkInfo subscriberCellularProvider];
        UIDevice *device = [UIDevice currentDevice];
        ASIdentifierManager *idManager = [ASIdentifierManager sharedManager];
        self.carrierName = [carrier carrierName];
        self.deviceModel = machineName();
        self.osVersion = device.systemVersion;
        self.idfa = idManager.advertisingIdentifier;
        
        self.stdid = @"69"; //this will be replaced with real stdid when /install is implemented
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

//returns JSON-ready dictionary for reportShare endpoint, based on shortlink and channel
- (NSDictionary *)reportShareDictionary:(NSString *)shortlink channel:(NSString *)socialChannel {
    CLLocationCoordinate2D coordinate;
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *info = [bundle infoDictionary];
    NSString *appID = [info valueForKey:@"CFBundleIdentifier"];
    NSString *appName = [info valueForKey:@"CFBundleName"];
    NSString *appVersion = [info valueForKey:@"CFBundleVersion"];
    int timestamp = [[NSDate date] timeIntervalSince1970];
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    NSString *wifiStatus = netStatus == ReachableViaWiFi ? @"on" : @"off";
    NSMutableDictionary *deviceObj = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [self.idfa UUIDString],@"id",
                                      self.deviceModel,@"model",
                                      @"ios",@"os",
                                      self.osVersion,@"osv",
                                      self.carrierName,@"carrier",
                                      wifiStatus,@"wifi",
                                      nil];
    NSDictionary *geoObj = nil;
    if(self.currentLocation) {
        coordinate = self.currentLocation.coordinate;
        geoObj = [NSDictionary dictionaryWithObjectsAndKeys:
                  [NSNumber numberWithDouble:coordinate.latitude],@"lat",
                  [NSNumber numberWithDouble:coordinate.longitude],@"lon",
                  nil];
        [deviceObj setObject:geoObj forKey:@"geo"];
    }
    
    NSDictionary *appObj = [NSDictionary dictionaryWithObjectsAndKeys:
                            appID,@"id",
                            appName,@"name",
                            appVersion,@"version",
                            nil];
    NSDictionary *clientObj = [NSDictionary dictionaryWithObjectsAndKeys:
                               LANGUAGE_ID,@"lang",
                               LANGUAGE_VERSION,@"version",
                               nil];
    NSDictionary *shareObj = [NSDictionary dictionaryWithObjectsAndKeys:
                              self.stdid,@"stdid",
                              [NSNumber numberWithInt:timestamp],@"timestamp",
                              deviceObj,@"device",
                              appObj,@"app",
                              socialChannel,@"channel",
                              shortlink,@"shortlink",
                              clientObj,@"client",
                              nil];
    
    return shareObj;
}

//calls open endpoint, including manufacturing URLRequest for it
- (void)open:(NSDictionary *)jsonDict withCallback:(void (^)(NSURLResponse *, NSData *, NSError *))callback {
    [self callEndpoint:OPEN withJSON:jsonDict andCallback:callback];
}

//calls shortlink endpoint, including manufacturing URLRequest for it
- (void)shortlink:(NSDictionary *)jsonDict withCallback:(void (^)(NSURLResponse *, NSData *, NSError *))callback {
    [self callEndpoint:SHORTLINK withJSON:jsonDict andCallback:callback];
}

- (void)reportShare:(NSDictionary *)jsonDict withCallback:(void (^)(NSURLResponse *, NSData *, NSError *))callback {
    [self callEndpoint:REPORT_SHARE withJSON:jsonDict andCallback:callback];
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

//location update
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if(locations.lastObject) {
        currentLocation = (CLLocation *)locations.lastObject;
    }
}

//convenience method to return "real" device name
//per http://stackoverflow.com/questions/11197509/ios-iphone-get-device-model-and-make
NSString *machineName() {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

@end
