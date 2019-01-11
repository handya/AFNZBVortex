//
//  AFNZBVortexRequests.h
//  Total NZB
//
//  Created by Andrew Farquharson on 8/01/19.
//  Copyright © 2019 Andrew Farquharson. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AFNZBVortexNetworkManager : NSObject

// make standard AFNetworking GET Request
- (void)GET:(NSString *)URL
 parameters:(nullable id)parameters
    success:(void (^)(id responseObject))response
    failure:(void (^)(NSError *error))failure;

// make standard AFNetworking POST Request
- (void)POST:(NSString *)URL
  parameters:(nullable id)parameters
     success:(void (^)(id responseObject))response
     failure:(void (^)(NSError *error))failure;

- (void)UPLOAD:(NSData *)nzbFile
           url:(NSString *)URL
      fileName:(NSString *)fileName
          name:(NSString *)name
uploadProgressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block
   withSuccess:(void (^)(NSDictionary *responceObject))response
       failure:(void (^)(NSError *error))failure;


@end

NS_ASSUME_NONNULL_END
