//
//  AFNZBVortexHost.m
//  Total NZB
//
//  Created by Andrew Farquharson on 7/01/19.
//  Copyright © 2019 Andrew Farquharson. All rights reserved.
//

#import "AFNZBVortexHost.h"

@implementation AFNZBVortexHost

// return base host url from current host params
- (NSString *)baseURL {
    if (self.customURL.length || self.customURL.length != 0) {
        if(![self.customURL hasSuffix:@"/"]){
            self.customURL = [self.customURL stringByAppendingString:@"/"];
        }
        return self.customURL;
    }
    
    NSString *requestURL = [NSString stringWithFormat:@"%@:%@", self.URL, self.PORT];
    if (self.SSL) {
        requestURL = [NSString stringWithFormat:@"https://%@/", requestURL];
    } else {
        requestURL = [NSString stringWithFormat:@"http://%@/", requestURL];
    }
    return requestURL;
}

@end
