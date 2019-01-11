//
//  AFCryptography.m
//  Total NZB
//
//  Created by Andrew Farquharson on 8/01/19.
//  Copyright © 2019 Andrew Farquharson. All rights reserved.
//

#import "AFCryptography.h"
#include <CommonCrypto/CommonDigest.h>


@implementation AFCryptography

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
