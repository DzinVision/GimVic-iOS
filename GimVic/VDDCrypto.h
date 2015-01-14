//
//  VDDCrypto.h
//  GimVic
//
//  Created by Vid Drobnič on 01/14/15.
//  Copyright (c) 2015 Vid Drobnič. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDDCrypto : NSObject

+ (NSString *)sha256hashFor:(NSString *)input;

@end