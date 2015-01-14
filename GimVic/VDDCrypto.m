//
//  VDDCrypto.m
//  GimVic
//
//  Created by Vid Drobnič on 01/14/15.
//  Copyright (c) 2015 Vid Drobnič. All rights reserved.
//

#import "VDDCrypto.h"
#import <CommonCrypto/CommonDigest.h>

@implementation VDDCrypto

+ (NSString *)sha256hashFor:(NSString *)input {
    const char* str = [input UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, (unsigned int)strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [ret appendFormat:@"%02x", result[i]];
    return ret;
}

@end