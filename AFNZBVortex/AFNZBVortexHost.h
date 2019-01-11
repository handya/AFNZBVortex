//
//  AFNZBVortexHost.h
//  Total NZB
//
//  Created by Andrew Farquharson on 7/01/19.
//  Copyright © 2019 Andrew Farquharson. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AFNZBVortexHost : NSObject

// user set apikey
@property (nonatomic, strong, nullable) NSString *APIKEY;

// user set url
@property (nonatomic, strong, nullable) NSString *URL;

// user set port
@property (nonatomic, strong, nullable) NSString *PORT;

// user set param
@property (nonatomic, assign) BOOL SSL;

// server set App Version
@property (nonatomic, strong, nullable) NSString *customURL;

// server set App Version
@property (nonatomic, strong, nullable) NSString *version;

// return base host url from current host params
- (NSString *)baseURL;

@end

NS_ASSUME_NONNULL_END
