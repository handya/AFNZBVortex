//
//  AFCryptography.h
//  Total NZB
//
//  Created by Andrew Farquharson on 8/01/19.
//  Copyright © 2019 Andrew Farquharson. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AFCryptography : NSObject

// return nsstring with random charters and numbers
- (NSString *)randomStringWithLength:(int)len;

// hash string to SHA256 bytes then hash bites to base64 string
- (NSString *)hashStringWithSHA256ToBase64:(NSString *)stringToHash;

// hash string to MD5 using NSUTF16 Little Endian Encoding
- (NSString *)md5HexDigest:(NSString *)input;

@end

NS_ASSUME_NONNULL_END
