//
//  NZBVortex.m
//  Total NZB
//
//  Created by Andrew Farquharson on 7/01/19.
//  Copyright © 2019 Andrew Farquharson. All rights reserved.
//

#import "AFNZBVortex.h"
#import "AFNZBVortexNetworkManager.h"

@implementation AFNZBVortex

+ (instancetype)sharedInstance {
    static AFNZBVortex *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AFNZBVortex alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self){
        _sessionManager = [[AFNZBVortexSessionManager alloc] init];
        _host = [[AFNZBVortexHost alloc] init];
    }
    return self;
}

- (void)setNewHostWithURL:(NSString *)url
                     port:(NSString *)port
                   APIKey:(NSString *)api
                customURL:(NSString *)customURL
               SSLEnabled:(BOOL)ssl {
    
    _host.URL = url;
    _host.PORT = port;
    _host.APIKEY = api;
    _host.customURL = customURL;
    _host.SSL = ssl;
    
    [_sessionManager setHost:_host];
}

- (void)GETRequest:(NSString *)request
        parameters:(nullable NSDictionary *)params
       withSuccess:(void (^)(NSDictionary *responce))response
           failure:(void (^)(NSError *error))failure {

    if ([@"2.0" compare:_host.version options:NSNumericSearch] == NSOrderedDescending) {
        // if app version is lower than 2.0 and trying to pause all or resume all, append 'All' as-per api docs
        if ([request isEqualToString:kAFNZBVortexNZBPauseAll] || [request isEqualToString:kAFNZBVortexNZBResumeAll] ) {
            request = [request stringByAppendingString:@"All"];
        }
    }
    
    // get current session ID, AFNZBVortexSessionManager will handle login (if needed) and return SessionID
    [_sessionManager currentSessionID:^(NSString * _Nonnull SID) {
        NSString *requestURL = [NSString stringWithFormat:@"%@%@?sessionid=%@", [self->_host baseURL], request, SID];
        
        NSMutableDictionary *mutableParams = [params mutableCopy];

        // check if there is a nzb id in the api constant and replace it with real nzb id, return if no nzb id in params
        if ([request rangeOfString:@":nzbid"].location != NSNotFound) {
            if ([mutableParams objectForKey:@"nzbid"]) {
                requestURL = [requestURL stringByReplacingOccurrencesOfString:@":nzbid" withString:[mutableParams objectForKey:@"nzbid"]];
                [mutableParams removeObjectForKey:@"nzbid"];
            } else {
                // no NZBID parsed in params, required for request
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:@"NO NZBID - NZBID need for this request, please add params with object with 'nzbid' for key"
                           forKey:NSLocalizedDescriptionKey];
                NSError *error = [NSError errorWithDomain:@"AFNZBVortex" code:400 userInfo:details];
                failure(error);
                return;
            }
        }
        
        if ([request isEqualToString:kAFNZBVortexNZBAdd]) {
            if (![mutableParams objectForKey:@"url"]) {
                // no URL parsed in params, required for request
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:@"NO URL - NZB URL need for this request, please add params with object with 'url' for key"
                           forKey:NSLocalizedDescriptionKey];
                NSError *error = [NSError errorWithDomain:@"AFNZBVortex" code:400 userInfo:details];
                failure(error);
                return;
            }
        }

        NSLog(@"requestURL: %@", requestURL);
        NSLog(@"Params %@", mutableParams);

        AFNZBVortexNetworkManager *NZBVortexRequest = [[AFNZBVortexNetworkManager alloc] init];
        [NZBVortexRequest GET:requestURL parameters:mutableParams success:^(id  _Nonnull responseObject) {
            response(responseObject);
            //NSLog(@"%@", responseObject);
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"%@", error);
            failure(error);
                        // failed to get nonce
        }];

    } failure:^(NSError * _Nonnull error) {
        // return failer if unable to get valid session ID
        failure(error);
    }];
}
                           
- (void)uploadNZB:(NSData *)nzbFile
         fileName:(NSString *)filename
             name:(NSString *)name
        groupName:(NSString *)groupName
uploadProgressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block
      withSuccess:(void (^)(NSDictionary *responce))response
          failure:(void (^)(NSError *error))failure {
    [_sessionManager currentSessionID:^(NSString * _Nonnull SID) {

        NSString *stringToAppend = @"";
        if ([@"2.2" compare:self->_host.version options:NSNumericSearch] == NSOrderedAscending) {
            if (name.length || name.length != 0) {
                stringToAppend = [NSString stringWithFormat:@"%@&name=%@", stringToAppend, name];
            }
            if (groupName.length || groupName.length != 0) {
                stringToAppend = [NSString stringWithFormat:@"%@&groupName=%@", stringToAppend, groupName];
            }
        }
        
        NSString *requestURL = [NSString stringWithFormat:@"%@%@?sessionid=%@", [self->_host baseURL], kAFNZBVortexNZBAdd, SID];
        
        NSString *escapedString = [requestURL stringByAppendingString:[stringToAppend stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
        
        NSString *uploadFileName = filename;
        if (![uploadFileName hasSuffix:@".nzb"] || ![uploadFileName hasSuffix:@".NZB"]) {
            uploadFileName = [NSString stringWithFormat:@"%@.nzb", uploadFileName];
        }
        
        AFNZBVortexNetworkManager *NZBVortexRequest = [[AFNZBVortexNetworkManager alloc] init];
        [NZBVortexRequest UPLOAD:nzbFile url:escapedString
                        fileName:uploadFileName
                            name:name
             uploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            block(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
        } withSuccess:^(NSDictionary * _Nonnull responceObject) {
            response(responceObject);
        } failure:^(NSError * _Nonnull error) {
            failure(error);
        }];

    } failure:^(NSError * _Nonnull error) {
        // return failer if unable to get valid session ID
        failure(error);
    }];
}

- (void)testHostWithURL:(NSString *)url
                   port:(NSString *)port
                 APIKey:(NSString *)api
              customURL:(NSString *)customURL
             SSLEnabled:(BOOL)ssl
            withSuccess:(void (^)(NSString *sessionID))response
                failure:(void (^)(NSError *error))failure {
    
    AFNZBVortexHost *testHost = [[AFNZBVortexHost alloc] init];
    testHost.URL = url;
    testHost.PORT = port;
    testHost.APIKEY = api;
    testHost.customURL = customURL;
    testHost.SSL = ssl;
    
    AFNZBVortexSessionManager *testSession = [[AFNZBVortexSessionManager alloc] init];
    [testSession setHost:testHost];
    
    [testSession currentSessionID:^(NSString * _Nonnull SID) {
        response(SID);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}
                           
@end
