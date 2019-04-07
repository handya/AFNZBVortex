//
//  AFNZBVortexSessionManager.m
//  Total NZB
//
//  Created by Andrew Farquharson on 7/01/19.
//  Copyright © 2019 Andrew Farquharson. All rights reserved.
//

#import "AFNZBVortexSessionManager.h"
#import "AFNZBVortexConstants.h"
#import "AFNZBVortexNetworkManager.h"
#include <CommonCrypto/CommonDigest.h>

#define sessionlength 300 // session time in seconds

@implementation AFNZBVortexSessionManager {
    //valid for 30s
    NSString *sessionID;
    // last successfull login time
    NSDate *sessionStartTime;
    
    AFNZBVortexHost *currentHost;
}

- (id)init {
    return [super init];
}

- (void)setHost:(AFNZBVortexHost *)host {
    currentHost = host;
    // if this has been called, the host has been started or changed invalidate old keys etc.
    sessionID = nil;
    sessionStartTime = nil;
}

// return a current ID or get a new one and return it
- (void)currentSessionID:(void (^)(NSString *SID))validSID
                 failure:(void (^)(NSError *error))failure {
    // if session id is active return it
    if ([self sessionActive]) {
        validSID(sessionID);
    } else {
        // if id is invalid get a new one and return it
        sessionID = nil;
        [self loginWithSuccess:^(NSString *SID) {
            validSID(SID);
        } failure:^(NSError *error) {
            failure(error);
        }];
    }
}

// login and get current session ID
- (void)loginWithSuccess:(void (^)(NSString *SID))validSID
                 failure:(void (^)(NSError *error))failure {
    NSLog(@"logging in");
    // get nonce from host
    [self getNonceWithSuccess:^(NSString *nonce) {
        // use nonce to login and get sessionID
        [self getNewSessionIDWithNonce:nonce success:^(NSString *SID) {
            NSLog(@"Successfully Logged In");
            //return correct session ID
            self->sessionID = SID;
            // set time of last valid sessionID
            self->sessionStartTime = [NSDate date];
            //make sure current host has api level before continuing...
            [self getAPILevelWithCompletion:^(BOOL complete) {
                // got API Level, send SID Back to Main controller for next request
                validSID(SID);
            }];
            
        } failure:^(NSError *error) {
            // failed to get session id
            failure(error);
        }];
        
    } failure:^(NSError *error) {
        // failed to get nonce
        failure(error);
    }];

}

// void get nonce from host
- (void)getNonceWithSuccess:(void (^)(NSString *nonce))responseNonce
                    failure:(void (^)(NSError *error))failure {
    NSLog(@"Getting Nonce");
    NSString *requestURL = [NSString stringWithFormat:@"%@%@", [currentHost baseURL], kAFNZBVortexAuthNonce];

    AFNZBVortexNetworkManager *NZBVortexRequest = [[AFNZBVortexNetworkManager alloc] init];
    [NZBVortexRequest GET:requestURL parameters:nil success:^(id  _Nonnull responseObject) {
        if ([[responseObject allKeys] containsObject:@"authNonce"]) {
            NSString *authNonce = [responseObject objectForKey:@"authNonce"];
            if (!authNonce.length || authNonce.length == 0) {
                // invalid nonce
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:@"Failed to get Authentication code - Check Host and Port settings are correct"
                           forKey:NSLocalizedDescriptionKey];
                NSError *error = [NSError errorWithDomain:@"AFNZBVortex" code:400 userInfo:details];
                failure(error);
            } else {
                responseNonce(authNonce);
            }
        } else {
            // invalid nonce
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:@"Failed to get Authentication code - Check Host and Port settings are correct"
                       forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:@"AFNZBVortex" code:400 userInfo:details];
            failure(error);
        }
    } failure:^(NSError * _Nonnull error) {
        // failed to get nonce
        failure(error);
    }];
}

// get new session id from host with nonce
- (void)getNewSessionIDWithNonce:(NSString *)nonce
                         success:(void (^)(NSString *SID))responseSessionID
                         failure:(void (^)(NSError *error))failure {
    NSLog(@"Getting Session ID");
    
    NSString *cnonce = [self generateClientNonce];
    
    NSString *hash = [NSString stringWithFormat:@"%@:%@:%@", nonce, cnonce, currentHost.APIKEY];
    
    hash = [self hashStringWithSHA256ToBase64:hash];
    
    // url encode "+", yes i know its hacky
    hash = [hash stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];

    NSString *requestURL = [NSString stringWithFormat:@"%@%@?nonce=%@&cnonce=%@&hash=%@", [currentHost baseURL], kAFNZBVortexAuthLogin, nonce, cnonce, hash];

    AFNZBVortexNetworkManager *NZBVortexRequest = [[AFNZBVortexNetworkManager alloc] init];
    [NZBVortexRequest GET:requestURL parameters:nil success:^(id  _Nonnull responseObject) {
        if ([[responseObject objectForKey:@"loginResult"] isEqualToString:@"successful"]) {
            responseSessionID([responseObject objectForKey:@"sessionID"]);
        } else {
            // login failed
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:@"Login Failed - Check API Key is correct" forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:@"AFNZBVortex" code:401 userInfo:details];
            failure(error);
        }
        //NSLog(@"%@", responseObject);
    } failure:^(NSError * _Nonnull error) {
        //NSLog(@"%@", error);
        failure(error);
        // failed to get nonce
    }];
}

// if current host does not have api level, get current api level and add it to current host object
- (void)getAPILevelWithCompletion:(void (^)(BOOL complete))requestCompleted {
    if (!currentHost.version.length || currentHost.version.length == 0) {
        NSString * requestURL = [NSString stringWithFormat:@"%@%@?sessionid=%@", [currentHost baseURL], kAFNZBVortexAppAPILevel, sessionID];
        
        AFNZBVortexNetworkManager *NZBVortexRequest = [[AFNZBVortexNetworkManager alloc] init];
        [NZBVortexRequest GET:requestURL parameters:nil success:^(id  _Nonnull responseObject) {
            if ([responseObject objectForKey:@"apilevel"]) {
                self->currentHost.version = [NSString stringWithFormat:@"%@", [responseObject objectForKey:@"apilevel"]];
                NSLog(@"Current Host API Version %@", self->currentHost.version);
            }
            requestCompleted(YES);
        } failure:^(NSError * _Nonnull error) {
            // failed to get api level
            requestCompleted(NO);
        }];
    } else {
        requestCompleted(YES);
    }
}

// check if seeion had expired/is active
- (BOOL)sessionActive {
    // check if sessionID is valid string
    if (!sessionID.length || sessionID.length == 0) {
        NSLog(@"Your SessionID Invalid");
        return NO;
    }
    // sessionID expires after 5mins
    if ([self sessionTime] < sessionlength) {
        NSLog(@"%@", [self readableRemainingSessionTime]);
        return YES;
    } else {
        NSLog(@"Your SessionID has Expired");
        return NO;
    }
}

// generate random onetime client side nonce
- (NSString *)generateClientNonce {
    return [self randomStringWithLength:8];
}

- (NSTimeInterval )sessionTime {
    return [[NSDate date] timeIntervalSinceDate:sessionStartTime];
}

- (NSString *)readableRemainingSessionTime {
    int time = sessionlength - (int)[self sessionTime];
    return [NSString stringWithFormat:@"Session expires in %dmin %dsec", time / 60, time % 60];
}

// return nsstring with random charters and numbers
- (NSString *)randomStringWithLength:(int)len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((int)[letters length])]];
    }
    return randomString;
}

// hash string to SHA256 bytes then hash bites to base64 string
- (NSString *)hashStringWithSHA256ToBase64:(NSString *)stringToHash {
    const char *s = [stringToHash cStringUsingEncoding:NSASCIIStringEncoding];
    
    NSData *keyData = [NSData dataWithBytes:s length:strlen(s)];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH] = {0};
    CC_SHA256(keyData.bytes, (int)keyData.length, digest);
    NSData *output = [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    
    NSString *base64 = [output base64EncodedStringWithOptions:kNilOptions];
    return base64;
}

// hash string to MD5 using NSUTF16 Little Endian Encoding
- (NSString *)md5HexDigest:(NSString *)input {
    NSData *data = [input dataUsingEncoding:NSUTF16LittleEndianStringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5([data bytes], (CC_LONG)[data length], result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

@end
