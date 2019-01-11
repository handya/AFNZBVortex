//
//  NZBVortex.h
//  Total NZB
//
//  Created by Andrew Farquharson on 7/01/19.
//  Copyright © 2019 Andrew Farquharson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNZBVortexHost.h"
#import "AFNZBVortexSessionManager.h"
#import "AFNZBVortexConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface AFNZBVortex : NSObject

@property (nonatomic, strong) AFNZBVortexSessionManager *sessionManager;

@property (nonatomic, strong) AFNZBVortexHost *host;

+ (instancetype)sharedInstance;

- (id)init;

// setting of host info, has to be done before 'GETRequest'
- (void)setNewHostWithURL:(NSString *)url
                     port:(NSString *)port
                   APIKey:(NSString *)api
                customURL:(NSString *)customURL
               SSLEnabled:(BOOL)ssl;

// make new get request to host
- (void)GETRequest:(NSString *)request
     parameters:(nullable NSDictionary *)params
    withSuccess:(void (^)(NSDictionary *responce))response
        failure:(void (^)(NSError *error))failure;

- (void)uploadNZB:(NSData *)nzbFile
         fileName:(NSString *)fileName
             name:(NSString *)name
        groupName:(NSString *)groupName
uploadProgressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block
      withSuccess:(void (^)(NSDictionary *responce))response
          failure:(void (^)(NSError *error))failure;

- (void)testHostWithURL:(NSString *)url
                   port:(NSString *)port
                 APIKey:(NSString *)api
              customURL:(NSString *)customURL
             SSLEnabled:(BOOL)ssl
            withSuccess:(void (^)(NSString *sessionID))response
                failure:(void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
