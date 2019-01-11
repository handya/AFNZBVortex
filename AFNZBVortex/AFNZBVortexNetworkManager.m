//
//  AFNZBVortexRequests.m
//  Total NZB
//
//  Created by Andrew Farquharson on 8/01/19.
//  Copyright © 2019 Andrew Farquharson. All rights reserved.
//

#import "AFNZBVortexNetworkManager.h"
#import "AFNetworking.h"

@implementation AFNZBVortexNetworkManager

- (void)GET:(NSString *)URL
 parameters:(nullable id)parameters
    success:(void (^)(id responseObject))response
    failure:(void (^)(NSError *error))failure {
    
    AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
    [securityPolicy setAllowInvalidCertificates:YES];
    [securityPolicy setValidatesDomainName:NO];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setSecurityPolicy:securityPolicy];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/x-json"];
    
    [manager GET:URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        response(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)POST:(NSString *)URL
  parameters:(nullable id)parameters
     success:(void (^)(id responseObject))response
     failure:(void (^)(NSError *error))failure {
    AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
    [securityPolicy setAllowInvalidCertificates:YES];
    [securityPolicy setValidatesDomainName:NO];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setSecurityPolicy:securityPolicy];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/x-json"];
    
    [manager POST:URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        response(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)UPLOAD:(NSData *)nzbFile
           url:(NSString *)URL
      fileName:(NSString *)fileName
          name:(NSString *)name
uploadProgressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block
      withSuccess:(void (^)(NSDictionary *responceObject))response
          failure:(void (^)(NSError *error))failure {
    
    AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
    [securityPolicy setAllowInvalidCertificates:YES];
    [securityPolicy setValidatesDomainName:NO];
    
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];

    NSMutableURLRequest *request = [serializer multipartFormRequestWithMethod:@"POST" URLString:URL parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:nzbFile name:name fileName:fileName mimeType:@"application/x-nzb"];
    } error:nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setSecurityPolicy:securityPolicy];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/x-json"];
    
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        response(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
    
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        block(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    }];
    
    [operation start];

}


@end
