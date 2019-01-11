//
//  AFNZBVortexSessionManager.m
//  Total NZB
//
//  Created by Andrew Farquharson on 7/01/19.
//  Copyright © 2019 Andrew Farquharson. All rights reserved.
//

#import "AFNZBVortexSessionManager.h"
#import "AFCryptography.h"
#import "AFNZBVortexConstants.h"
#import "AFNZBVortexNetworkManager.h"

#define sessionlength 300 // session time in seconds

@implementation AFNZBVortexSessionManager {
    //valid for 30s
    NSString *sessionID;
    // last successfull login time
    NSDate *sessionStartTime;
    
    AFNZBVortexHost *currentHost;
    
    AFCryptography *crypto;
}

- (id)init {
    self = [super init];
    if (self){
        crypto = [[AFCryptography alloc] init];
    }
    return self;
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
    
    hash = [crypto hashStringWithSHA256ToBase64:hash];
    
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
    return [crypto randomStringWithLength:8];
}

- (NSTimeInterval )sessionTime {
    return [[NSDate date] timeIntervalSinceDate:sessionStartTime];
}

- (NSString *)readableRemainingSessionTime {
    int time = sessionlength - (int)[self sessionTime];
    return [NSString stringWithFormat:@"Session expires in %dmin %dsec", time / 60, time % 60];
}

@end
