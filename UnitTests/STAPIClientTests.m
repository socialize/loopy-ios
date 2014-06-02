//
//  STAPIClientTests.m
//  Loopy
//
//  Created by David Jedeikin on 9/11/13.
//  Copyright (c) 2013 ShareThis. All rights reserved.
//

#import "STAPIClient.h"
#import "STJSONUtils.h"
#import "STTestUtils.h"
#import "STObject.h"
#import "STInstall.h"
#import "STOpen.h"
#import "STShare.h"
#import "STShortlink.h"
#import "STSharelink.h"
#import "STDevice.h"
#import "STApp.h"
#import "STClient.h"
#import "STGeo.h"
#import "STItem.h"
#import "STIdentifier.h"
#import <GHUnitIOS/GHUnit.h>
#import <OCMock/OCMock.h>
#import <AFNetworking/AFNetworking.h>
#import <CoreLocation/CoreLocation.h>

@interface STAPIClientTests : GHAsyncTestCase {
    STAPIClient *apiClient;
    NSString *endpoint;
}
@end

@implementation STAPIClientTests

- (void)setUpClass {
    endpoint = @"/endpoint";
    apiClient = [[STAPIClient alloc] initWithAPIKey:@"hkg435723o4tho95fh29"
                                           loopyKey: @"4q7cd6ngw3vu7gram5b9b9t6"
                                  locationsDisabled:NO
                                     identifierType:STIdentifierTypeHeadless];
    
    //simulate current location and stdid
    if(!apiClient.deviceSettings.currentLocation) {
        apiClient.deviceSettings.currentLocation = [[CLLocation alloc] initWithLatitude:45.0f longitude:45.0f];
    }
    if(!apiClient.stdid) {
        NSUUID *stdidObj = (NSUUID *)[NSUUID UUID];
        apiClient.stdid = (NSString *)[stdidObj UUIDString];
    }
}

- (void)testNewURLRequest {
    BOOL containsAPIKey = NO;
    BOOL containsLoopyKey = NO;
    NSData *dummyData = [[NSData alloc] init];
    NSURLRequest *request = [apiClient newURLRequest:dummyData length:0 endpoint:endpoint];
    
    //verify header fields
    NSDictionary *headerFields = [request allHTTPHeaderFields];
    for(NSString *key in headerFields) {
        id value = [headerFields valueForKey:key];
        GHAssertNotNil(value, @"");
        
        if([key isEqualToString:API_KEY]) {
            containsAPIKey = YES;
        }
        else if([key isEqualToString:LOOPY_KEY]) {
            containsLoopyKey = YES;
        }
    }
    GHAssertTrue(containsAPIKey && containsLoopyKey, @"");
    NSString *acceptVal = [request valueForHTTPHeaderField:@"Accept"];
    NSString *contentTypeVal = [request valueForHTTPHeaderField:@"Content-Type"];
    GHAssertEqualStrings(@"application/json", acceptVal, @"");
    GHAssertEqualStrings(@"application/json", contentTypeVal, @"");
}

- (void)testNewHTTPSURLRequest {
    BOOL containsAPIKey = NO;
    BOOL containsLoopyKey = NO;
    NSData *dummyData = [[NSData alloc] init];
    NSURLRequest *request = [apiClient newHTTPSURLRequest:dummyData length:0 endpoint:endpoint];
    
    //verify header fields
    NSDictionary *headerFields = [request allHTTPHeaderFields];
    for(NSString *key in headerFields) {
        id value = [headerFields valueForKey:key];
        GHAssertNotNil(value, @"");
        
        if([key isEqualToString:API_KEY]) {
            containsAPIKey = YES;
        }
        else if([key isEqualToString:LOOPY_KEY]) {
            containsLoopyKey = YES;
        }
    }
    GHAssertTrue(containsAPIKey && containsLoopyKey, @"");
    NSString *acceptVal = [request valueForHTTPHeaderField:@"Accept"];
    NSString *contentTypeVal = [request valueForHTTPHeaderField:@"Content-Type"];
    GHAssertEqualStrings(@"application/json", acceptVal, @"");
    GHAssertEqualStrings(@"application/json", contentTypeVal, @"");
}

- (void)testNewURLRequestOperation {
    NSData *dummyData = [[NSData alloc] init];
    
    //https -- verify serialization & challenge block created
    NSURLRequest *httpsRequest = [apiClient newHTTPSURLRequest:dummyData length:0 endpoint:endpoint];
    AFHTTPRequestOperation *httpsOperation = [apiClient newURLRequestOperation:httpsRequest isHTTPS:YES success:nil failure:nil];
    GHAssertTrue([httpsOperation.responseSerializer isKindOfClass:[AFJSONResponseSerializer class]], @"");
    NSString *authChallengeName = @"authenticationChallenge";
    id authChallengeBlock = [httpsOperation valueForKey:authChallengeName];
    GHAssertNotNil(authChallengeBlock, @"");
    
    //https -- no challenge block but same serialization
    NSURLRequest *request = [apiClient newURLRequest:dummyData length:0 endpoint:endpoint];
    AFHTTPRequestOperation *operation = [apiClient newURLRequestOperation:request isHTTPS:NO success:nil failure:nil];
    GHAssertTrue([httpsOperation.responseSerializer isKindOfClass:[AFJSONResponseSerializer class]], @"");
    authChallengeBlock = [operation valueForKey:authChallengeName];
    GHAssertNil(authChallengeBlock, @"");
}

- (void)testInstallObjectWithReferrer {
    STInstall *installObj = [apiClient installWithReferrer:@"www.facebook.com"];
    GHAssertNotNil(installObj, @"");
    GHAssertNotNil(installObj.stdid, @"");
    GHAssertNotNil(installObj.md5id, @"");
    GHAssertNotNil(installObj.timestamp, @"");
    GHAssertNotNil(installObj.device, @"");
    GHAssertNotNil(installObj.app, @"");
    GHAssertNotNil(installObj.client, @"");
    
    //test subsidiary objects
    STDevice *device = installObj.device;
    GHAssertNotNil(device.id, @"");
    GHAssertNotNil(device.carrier, @"");
    GHAssertNotNil(device.model, @"");
    GHAssertNotNil(device.os, @"");
    GHAssertNotNil(device.osv, @"");
    GHAssertNotNil(device.wifi, @"");
    GHAssertNotNil(device.geo, @"");
    
    STGeo *geo = device.geo;
    GHAssertNotNil(geo.lat, @"");
    GHAssertNotNil(geo.lon, @"");

    STApp *app = installObj.app;
    GHAssertNotNil(app.id, @"");
    GHAssertNotNil(app.name, @"");
    GHAssertNotNil(app.version, @"");

    STClient *client = installObj.client;
    GHAssertNotNil(client.lang, @"");
    GHAssertNotNil(client.version, @"");
}

- (void)testOpenObjectWithReferrer {
    STOpen *openObj = [apiClient openWithReferrer:@"www.facebook.com"];
    GHAssertNotNil(openObj, @"");
    GHAssertNotNil(openObj.stdid, @"");
    GHAssertNotNil(openObj.md5id, @"");
    GHAssertNotNil(openObj.timestamp, @"");
    GHAssertNotNil(openObj.device, @"");
    GHAssertNotNil(openObj.app, @"");
    GHAssertNotNil(openObj.client, @"");
    
    //test subsidiary objects
    STDevice *device = openObj.device;
    GHAssertNotNil(device.id, @"");
    GHAssertNotNil(device.carrier, @"");
    GHAssertNotNil(device.model, @"");
    GHAssertNotNil(device.os, @"");
    GHAssertNotNil(device.osv, @"");
    GHAssertNotNil(device.wifi, @"");
    GHAssertNotNil(device.geo, @"");
    
    STGeo *geo = device.geo;
    GHAssertNotNil(geo.lat, @"");
    GHAssertNotNil(geo.lon, @"");
    
    STApp *app = openObj.app;
    GHAssertNotNil(app.id, @"");
    GHAssertNotNil(app.name, @"");
    GHAssertNotNil(app.version, @"");
    
    STClient *client = openObj.client;
    GHAssertNotNil(client.lang, @"");
    GHAssertNotNil(client.version, @"");
}

- (void)testReportShareObject {
    NSString *dummyShortlink = @"www.shortlink.com";
    NSString *dummyChannel = @"Facebook";
    
    STShare *shareObj = [apiClient reportShareWithShortlink:dummyShortlink channel:dummyChannel];
    GHAssertNotNil(shareObj, @"");
    GHAssertNotNil(shareObj.stdid, @"");
    GHAssertNotNil(shareObj.md5id, @"");
    GHAssertNotNil(shareObj.timestamp, @"");
    GHAssertNotNil(shareObj.device, @"");
    GHAssertNotNil(shareObj.app, @"");
    NSString *channel = shareObj.channel;
    GHAssertEqualStrings(channel, dummyChannel, @"");
    NSString *shortlink = shareObj.shortlink;
    GHAssertEqualStrings(shortlink, dummyShortlink, @"");
    GHAssertNotNil(shareObj.client, @"");
    
    //test subsidiary objects
    STDevice *device = shareObj.device;
    GHAssertNotNil(device.id, @"");
    GHAssertNotNil(device.carrier, @"");
    GHAssertNotNil(device.model, @"");
    GHAssertNotNil(device.os, @"");
    GHAssertNotNil(device.osv, @"");
    GHAssertNotNil(device.wifi, @"");
    GHAssertNotNil(device.geo, @"");
    
    STGeo *geo = device.geo;
    GHAssertNotNil(geo.lat, @"");
    GHAssertNotNil(geo.lon, @"");
    
    STApp *app = shareObj.app;
    GHAssertNotNil(app.id, @"");
    GHAssertNotNil(app.name, @"");
    GHAssertNotNil(app.version, @"");
    
    STClient *client = shareObj.client;
    GHAssertNotNil(client.lang, @"");
    GHAssertNotNil(client.version, @"");
}

- (void)testShortlinkObject {
    STShortlink *shortlinkObj = [apiClient shortlinkWithURL:@"http://www.facebook.com"
                                               title:@"Share This"
                                                meta:[NSDictionary dictionaryWithObjectsAndKeys:
                                                      @"A description should go here.", @"og:description",
                                                      @"http://someimageurl.com/foobar.jpg", @"og:image",
                                                      @"http://someimageurl.com/foobar.jpg", @"og:video",
                                                      @"http://someimageurl.com/foobar.jpg", @"og:video:type",
                                                      nil]
                                                tags:[NSArray arrayWithObjects:@"sports", @"movies", @"music", nil]];

    GHAssertNotNil(shortlinkObj, @"");
    GHAssertNotNil(shortlinkObj.stdid, @"");
    GHAssertNotNil(shortlinkObj.md5id, @"");
    GHAssertNotNil(shortlinkObj.timestamp, @"");
    GHAssertNotNil(shortlinkObj.item, @"");
    GHAssertNotNil(shortlinkObj.tags, @"");
    
    STItem *item = (STItem *)shortlinkObj.item;
    GHAssertNotNil(item.title, @"");
    GHAssertNotNil(item.meta, @"");
}

- (void)testSharelinkObject {
    NSString *dummyChannel = @"Facebook";
    STSharelink *sharelinkObj = [apiClient sharelinkWithURL:@"http://www.facebook.com"
                                                    channel:dummyChannel
                                                      title:@"Share This"
                                                       meta:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            @"A description should go here.", @"og:description",
                                                            @"http://someimageurl.com/foobar.jpg", @"og:image",
                                                            @"http://someimageurl.com/foobar.jpg", @"og:video",
                                                            @"http://someimageurl.com/foobar.jpg", @"og:video:type",
                                                            nil]
                                                       tags:[NSArray arrayWithObjects:@"sports", @"movies", @"music", nil]];
    GHAssertNotNil(sharelinkObj, @"");
    GHAssertNotNil(sharelinkObj.stdid, @"");
    GHAssertNotNil(sharelinkObj.md5id, @"");
    GHAssertNotNil(sharelinkObj.timestamp, @"");
    GHAssertNotNil(sharelinkObj.item, @"");
    GHAssertNotNil(sharelinkObj.tags, @"");
    GHAssertNotNil(sharelinkObj.app, @"");
    NSString *channel = sharelinkObj.channel;
    GHAssertEqualStrings(channel, dummyChannel, @"");
    
    STItem *item = (STItem *)sharelinkObj.item;
    GHAssertNotNil(item.title, @"");
    GHAssertNotNil(item.meta, @"");
    
    STDevice *device = sharelinkObj.device;
    GHAssertNotNil(device.id, @"");
    GHAssertNotNil(device.carrier, @"");
    GHAssertNotNil(device.model, @"");
    GHAssertNotNil(device.os, @"");
    GHAssertNotNil(device.osv, @"");
    GHAssertNotNil(device.wifi, @"");
    GHAssertNotNil(device.geo, @"");
    
    STGeo *geo = device.geo;
    GHAssertNotNil(geo.lat, @"");
    GHAssertNotNil(geo.lon, @"");
    
    STApp *app = sharelinkObj.app;
    GHAssertNotNil(app.id, @"");
    GHAssertNotNil(app.name, @"");
    GHAssertNotNil(app.version, @"");
    
    STClient *client = sharelinkObj.client;
    GHAssertNotNil(client.lang, @"");
    GHAssertNotNil(client.version, @"");
}

- (void)testLogObject {
    STLog *logObj = [apiClient logWithType:@"share"
                                      meta:[NSDictionary dictionaryWithObjectsAndKeys:@"value0",@"key0",
                                                                                      @"value1",@"key1",
                                                                                      nil]];
    GHAssertNotNil(logObj, @"");
    GHAssertNotNil(logObj.stdid, @"");
    GHAssertNotNil(logObj.md5id, @"");
    GHAssertNotNil(logObj.timestamp, @"");
    GHAssertNotNil(logObj.device, @"");
    GHAssertNotNil(logObj.app, @"");
    GHAssertNotNil(logObj.client, @"");
    GHAssertNotNil(logObj.event, @"");
    
    STEvent *eventObj = logObj.event;
    NSString *type = @"share";
    GHAssertEqualStrings(type, eventObj.type, @"");
    NSDictionary *meta = eventObj.meta;
    GHAssertNotNil(meta, @"");
    GHAssertTrue([(NSString *)[meta valueForKey:@"key0"] isEqualToString:@"value0"], @"");
    GHAssertTrue([(NSString *)[meta valueForKey:@"key1"] isEqualToString:@"value1"], @"");
    
    STDevice *device = logObj.device;
    GHAssertNotNil(device.id, @"");
    GHAssertNotNil(device.carrier, @"");
    GHAssertNotNil(device.model, @"");
    GHAssertNotNil(device.os, @"");
    GHAssertNotNil(device.osv, @"");
    GHAssertNotNil(device.wifi, @"");
    GHAssertNotNil(device.geo, @"");
    
    STGeo *geo = device.geo;
    GHAssertNotNil(geo.lat, @"");
    GHAssertNotNil(geo.lon, @"");
    
    STApp *app = logObj.app;
    GHAssertNotNil(app.id, @"");
    GHAssertNotNil(app.name, @"");
    GHAssertNotNil(app.version, @"");
    
    STClient *client = logObj.client;
    GHAssertNotNil(client.lang, @"");
    GHAssertNotNil(client.version, @"");
}

@end
