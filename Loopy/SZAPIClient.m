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

NSString *const INSTALL = @"/install";
NSString *const OPEN = @"/open";
NSString *const STDID = @"/stdid";
NSString *const SHORTLINK = @"/shortlink";
NSString *const REPORT_SHARE = @"/share";
NSString *const LOG = @"/log";

NSTimeInterval const TIMEOUT = 1.0f;
NSString *const API_KEY = @"X-LoopyAppID";
NSString *const LOOPY_KEY = @"X-LoopyKey";
NSString *const IDFA_KEY = @"idfa";
NSString *const STDID_KEY = @"stdid";
NSString *const LANGUAGE_ID = @"objc";
NSString *const LANGUAGE_VERSION = @"1.3";
NSString *const IDENTITIES_FILENAME = @"SZIdentities.plist";

@synthesize urlPrefix;
@synthesize httpsURLPrefix;
@synthesize apiKey;
@synthesize loopyKey;
@synthesize locationManager;
@synthesize carrierName;
@synthesize osVersion;
@synthesize deviceModel;
@synthesize idfa;
@synthesize stdid;
@synthesize currentLocation;
@synthesize shortlinks;

//constructor with specified endpoint
//performs actions to check for stdid and calls "install" or "open" as required
- (id)initWithAPIKey:(NSString *)key loopyKey:(NSString *)lkey {
    self = [super init];
    if(self) {
        //init shortlink cache
        self.shortlinks = [NSMutableDictionary dictionary];
        
        //set keys
        self.apiKey = key;
        self.loopyKey = lkey;
        
        //set URLs
        NSBundle *bundle =  [NSBundle bundleForClass:[self class]];
        NSString *configPath = [bundle pathForResource:@"LoopyApiInfo" ofType:@"plist"];
        NSDictionary *configurationDict = [[NSDictionary alloc]initWithContentsOfFile:configPath];
        NSDictionary *apiInfoDict = [configurationDict objectForKey:@"Loopy API info"];
        self.urlPrefix = [apiInfoDict objectForKey:@"urlPrefix"];
        self.httpsURLPrefix = [apiInfoDict objectForKey:@"urlHttpsPrefix"];
        
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
    }
    return self;
}

//updates identities file
- (void)updateIdentities {
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [rootPath stringByAppendingPathComponent:IDENTITIES_FILENAME];
    NSMutableDictionary *identities = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [self.idfa UUIDString],IDFA_KEY,
                                       self.stdid,STDID_KEY,
                                       nil];
    NSString *error;
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:(id)identities
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&error];
    [plistData writeToFile:filePath atomically:YES];
}

#pragma mark - Identities Handling

//loads identities file from disk, and calls appropriate recording endpoint (/open or /install) as required
- (void)loadIdentitiesWithReferrer:(NSString *)referrer
                       postSuccess:(void(^)(AFHTTPRequestOperation *, id))postSuccessCallback
                           failure:(void(^)(AFHTTPRequestOperation *, NSError *))failureCallback {
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [rootPath stringByAppendingPathComponent:IDENTITIES_FILENAME];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    
    //call /install and store stdid returned in new file
    if(!plistDict) {
        [self install:[self installDictionaryWithReferrer:referrer]
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSDictionary *responseDict = (NSDictionary *)responseObject;
                  self.stdid = (NSString *)[responseDict valueForKey:STDID_KEY];
                  [self updateIdentities];
                  postSuccessCallback(operation, responseObject);
              }
              failure:failureCallback];
    }
    else {
        //load it and compare idfa
        //if they don't match, call /stdid, then /open with new stdid
        //if they do, call /open
        NSString *idfaStrCached = (NSString *)[plistDict valueForKey:IDFA_KEY];
        NSString *idfaStrLocal = [self.idfa UUIDString];
        if(![idfaStrCached isEqualToString:idfaStrLocal]) {
            [self stdid:[self stdidDictionary]
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSDictionary *responseDict = (NSDictionary *)responseObject;
                    self.stdid = (NSString *)[responseDict valueForKey:STDID_KEY];
                    [self updateIdentities];
                    [self open:[self openDictionaryWithReferrer:referrer]
                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                           postSuccessCallback(operation, responseObject);
                       }
                       failure:failureCallback];
                }
                failure:failureCallback];
        }
        else {
            self.stdid = (NSString *)[plistDict valueForKey:STDID_KEY];
            [self open:[self openDictionaryWithReferrer:referrer]
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   [self updateIdentities];
                   postSuccessCallback(operation, responseObject);
               }
               failure:failureCallback];
        }
    }
}

#pragma mark - URL Requests

//factory method for URLRequest for specified JSON data and endpoint
- (NSMutableURLRequest *)newHTTPSURLRequest:(NSData *)jsonData
                                     length:(NSNumber *)length
                                   endpoint:(NSString *)endpoint {
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", httpsURLPrefix, endpoint];
    return [self jsonURLRequestForURL:urlStr data:jsonData length:length];
}

//factory method for URLRequest for specified JSON data and endpoint
- (NSMutableURLRequest *)newURLRequest:(NSData *)jsonData
                                length:(NSNumber *)length
                              endpoint:(NSString *)endpoint {
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", urlPrefix, endpoint];
    return [self jsonURLRequestForURL:urlStr data:jsonData length:length];
}

//convenience method
-(NSMutableURLRequest *)jsonURLRequestForURL:(NSString *)urlStr
                                        data:(NSData *)jsonData
                                      length:(NSNumber *)length {
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:TIMEOUT];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:self.apiKey forHTTPHeaderField:API_KEY];
    [request setValue:self.loopyKey forHTTPHeaderField:LOOPY_KEY];
    [request setValue:[length stringValue] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    return request;
}

//factory method to init operations with specified requests and callbacks
- (AFHTTPRequestOperation *)newURLRequestOperation:(NSURLRequest *)request
                                           isHTTPS:(BOOL)https
                                           success:(void(^)(AFHTTPRequestOperation *, id))successCallback
                                           failure:(void(^)(AFHTTPRequestOperation *, NSError *))failureCallback {
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:successCallback
                                     failure:failureCallback];
    
    //allow self-signed certs for HTTPS
    if(https) {
        [operation setWillSendRequestForAuthenticationChallengeBlock:^(NSURLConnection *connection, NSURLAuthenticationChallenge *challenge) {
            SecTrustRef trust = challenge.protectionSpace.serverTrust;
            NSURLCredential *cred = [NSURLCredential credentialForTrust:trust];
            [challenge.sender useCredential:cred forAuthenticationChallenge:challenge];
            [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
        }];
    }
    return operation;
}

//Returns error code
//if code is nil or no error value contained, returns nil
- (NSNumber *)loopyErrorCode:(NSDictionary *)errorDict {
    NSNumber *errorCode = nil;
    id codeObj = [errorDict valueForKey:@"code"];
    if([codeObj isKindOfClass:[NSNumber class]]) {
        errorCode = (NSNumber *)codeObj;
    }
    return errorCode;
}

//Returns array of error values taken from the userInfo portion of error returned from request
//if error is nil or no error value contained, returns nil
- (NSArray *)loopyErrorArray:(NSDictionary *)errorDict {
    NSArray *errorArray = nil;
    id errorObj = [errorDict valueForKey:@"error"];
    
    if([errorObj isKindOfClass:[NSArray class]]) {
        errorArray = (NSArray *)errorObj;
    }
    return errorArray;
}

#pragma mark - JSON For Endpoints

//returns JSON-ready dictionary for /install endpoint for specified referrer
- (NSDictionary *)installDictionaryWithReferrer:(NSString *)referrer {
    int timestamp = [[NSDate date] timeIntervalSince1970];
    NSDictionary *installObj = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInt:timestamp],@"timestamp",
                                referrer,@"referrer",
                                [self deviceDictionary],@"device",
                                [self appDictionary],@"app",
                                [self clientDictionary],@"client",
                                nil];
    return installObj;
}

//returns JSON-ready dictionary for /open endpoint for specified referrer
- (NSDictionary *)openDictionaryWithReferrer:(NSString *)referrer {
    int timestamp = [[NSDate date] timeIntervalSince1970];
    NSDictionary *openObj = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.stdid,@"stdid",
                             [NSNumber numberWithInt:timestamp],@"timestamp",
                             referrer,@"referrer",
                             [self deviceDictionary],@"device",
                             [self appDictionary],@"app",
                             [self clientDictionary],@"client",
                             nil];
    return openObj;
}

//returns JSON-ready dictionary for /stdid endpoint
- (NSDictionary *)stdidDictionary {
    int timestamp = [[NSDate date] timeIntervalSince1970];
    NSDictionary *stdidObj = [NSDictionary dictionaryWithObjectsAndKeys:
                              self.stdid,@"stdid",
                              [NSNumber numberWithInt:timestamp],@"timestamp",
                              [self deviceDictionary],@"device",
                              [self appDictionary],@"app",
                              [self clientDictionary],@"client",
                              nil];
    return stdidObj;
}

//returns JSON-ready dictionary for /share endpoint, based on shortlink and channel
- (NSDictionary *)reportShareDictionary:(NSString *)shortlink channel:(NSString *)socialChannel {
    int timestamp = [[NSDate date] timeIntervalSince1970];
    NSDictionary *shareObj = [NSDictionary dictionaryWithObjectsAndKeys:
                              self.stdid,@"stdid",
                              [NSNumber numberWithInt:timestamp],@"timestamp",
                              [self deviceDictionary],@"device",
                              [self appDictionary],@"app",
                              socialChannel,@"channel",
                              shortlink,@"shortlink",
                              [self clientDictionary],@"client",
                              nil];
    
    return shareObj;
}

//returns JSON-ready dictionary for /log endpoint, based on type and meta
- (NSDictionary *)logDictionaryWithType:(NSString *)type meta:(NSDictionary *)meta {
    int timestamp = [[NSDate date] timeIntervalSince1970];
    NSDictionary *logObj = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.stdid,@"stdid",
                            [NSNumber numberWithInt:timestamp],@"timestamp",
                            [self deviceDictionary],@"device",
                            [self appDictionary],@"app",
                            [self clientDictionary],@"client",
                            type,@"type",
                            meta,@"meta",
                            nil];
    
    return logObj;
}

//required subset of endpoint calls
- (NSDictionary *)deviceDictionary {
    CLLocationCoordinate2D coordinate;
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
    
    return deviceObj;
}

//required subset of endpoint calls
- (NSDictionary *)appDictionary {
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *info = [bundle infoDictionary];
    NSString *appID = [info valueForKey:@"CFBundleIdentifier"];
    NSString *appName = [info valueForKey:@"CFBundleName"];
    NSString *appVersion = [info valueForKey:@"CFBundleVersion"];
    NSDictionary *appObj = [NSDictionary dictionaryWithObjectsAndKeys:
                            appID,@"id",
                            appName,@"name",
                            appVersion,@"version",
                            nil];
    return appObj;
}

//required subset of endpoint calls
- (NSDictionary *)clientDictionary {
    NSDictionary *clientObj = [NSDictionary dictionaryWithObjectsAndKeys:
                               LANGUAGE_ID,@"lang",
                               LANGUAGE_VERSION,@"version",
                               nil];
    return clientObj;
}

#pragma mark - Calling Endpoints

- (void)install:(NSDictionary *)jsonDict
        success:(void(^)(AFHTTPRequestOperation *, id))successCallback
        failure:(void(^)(AFHTTPRequestOperation *, NSError *))failureCallback {
    [self callHTTPSEndpoint:INSTALL json:jsonDict success:successCallback failure:failureCallback];
}

- (void)open:(NSDictionary *)jsonDict
     success:(void(^)(AFHTTPRequestOperation *, id))successCallback
     failure:(void(^)(AFHTTPRequestOperation *, NSError *))failureCallback {
    [self callEndpoint:OPEN json:jsonDict success:successCallback failure:failureCallback];
}

- (void)stdid:(NSDictionary *)jsonDict
      success:(void(^)(AFHTTPRequestOperation *, id))successCallback
      failure:(void(^)(AFHTTPRequestOperation *, NSError *))failureCallback {
    [self callHTTPSEndpoint:STDID json:jsonDict success:successCallback failure:failureCallback];
}

- (void)shortlink:(NSDictionary *)jsonDict
          success:(void(^)(AFHTTPRequestOperation *, id))successCallback
          failure:(void(^)(AFHTTPRequestOperation *, NSError *))failureCallback {
    //check the cache to see if shortlink already exists, and if so, simply call successCallback
    NSDictionary *item = (NSDictionary *)[jsonDict valueForKey:@"item"];
    NSString *url = (NSString *)[item valueForKey:@"url"];
    if([self.shortlinks valueForKey:url]) {
        NSDictionary *shortlinkDict = [NSDictionary dictionaryWithObjectsAndKeys:[self.shortlinks valueForKey:url], @"shortlink", nil];
        successCallback(nil, shortlinkDict);
    }
    else {
        [self callEndpoint:SHORTLINK
                      json:jsonDict
                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                       //cache the shortlink for future reuse
                       NSDictionary *responseDict = (NSDictionary *)responseObject;
                       [self.shortlinks setValue:[responseDict valueForKey:@"shortlink"] forKey:url];
                       successCallback(operation, responseObject);
                   }
                   failure:failureCallback];
    }
}

- (void)reportShare:(NSDictionary *)jsonDict
            success:(void(^)(AFHTTPRequestOperation *, id))successCallback
            failure:(void(^)(AFHTTPRequestOperation *, NSError *))failureCallback {
    [self callEndpoint:REPORT_SHARE json:jsonDict
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   //remove current shortlink from cache
                   //although shortlinks are the values (not keys) of the shortlinks dictionary, they should be unique
                   //thus keys should contain only one element
                   NSString *shortlink = (NSString *)[jsonDict objectForKey:@"shortlink"];
                   NSArray *keys = [self.shortlinks allKeysForObject:shortlink];
                   for(id key in keys) {
                       [self.shortlinks removeObjectForKey:key];
                   }
                   successCallback(operation, responseObject);
               }
               failure:failureCallback];
}

- (void)log:(NSDictionary *)jsonDict
    success:(void(^)(AFHTTPRequestOperation *, id))successCallback
    failure:(void(^)(AFHTTPRequestOperation *, NSError *))failureCallback {
    [self callEndpoint:LOG json:jsonDict success:successCallback failure:failureCallback];
}

//convenience method
- (void)callHTTPSEndpoint:(NSString *)endpoint
                     json:(NSDictionary *)jsonDict
                  success:(void(^)(AFHTTPRequestOperation *, id))successCallback
                  failure:(void(^)(AFHTTPRequestOperation *, NSError *))failureCallback {
    NSData *jsonData = [SZJSONUtils toJSONData:jsonDict];
    NSString *jsonStr = [SZJSONUtils toJSONString:jsonData];
    NSNumber *jsonLength = [NSNumber numberWithInt:[jsonStr length]];
    NSURLRequest *request = [self newHTTPSURLRequest:jsonData
                                              length:jsonLength
                                            endpoint:endpoint];
    AFHTTPRequestOperation *operation = [self newURLRequestOperation:request
                                                             isHTTPS:YES
                                                             success:successCallback
                                                             failure:failureCallback];
    [operation start];
}

//convenience method
- (void)callEndpoint:(NSString *)endpoint
                json:(NSDictionary *)jsonDict
             success:(void(^)(AFHTTPRequestOperation *, id))successCallback
             failure:(void(^)(AFHTTPRequestOperation *, NSError *))failureCallback {
    NSData *jsonData = [SZJSONUtils toJSONData:jsonDict];
    NSString *jsonStr = [SZJSONUtils toJSONString:jsonData];
    NSNumber *jsonLength = [NSNumber numberWithInt:[jsonStr length]];
    NSURLRequest *request = [self newURLRequest:jsonData
                                         length:jsonLength
                                       endpoint:endpoint];
    AFHTTPRequestOperation *operation = [self newURLRequestOperation:request
                                                             isHTTPS:NO
                                                             success:successCallback
                                                             failure:failureCallback];
    [operation start];
}

#pragma mark - Location And Device Information

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
