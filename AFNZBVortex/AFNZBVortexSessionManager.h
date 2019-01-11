//
//  AFNZBVortexSessionManager.h
//  Total NZB
//
//  Created by Andrew Farquharson on 7/01/19.
//  Copyright © 2019 Andrew Farquharson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNZBVortexHost.h"

NS_ASSUME_NONNULL_BEGIN

@interface AFNZBVortexSessionManager : NSObject

- (id)init;

// set session manage current host
- (void)setHost:(AFNZBVortexHost *)host;

// get current session ID
- (void)currentSessionID:(void (^)(NSString *SID))validSID
                 failure:(void (^)(NSError *error))failure;

// check if session is active
- (BOOL)sessionActive;

// total time current session ID has been active for in seconds from last login
- (NSTimeInterval )sessionTime;

// Readable String of Reamaing time eg: "Session expires in 2min 4sec"
- (NSString *)readableRemainingSessionTime;

@end

NS_ASSUME_NONNULL_END
