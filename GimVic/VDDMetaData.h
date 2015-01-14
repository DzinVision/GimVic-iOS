//
//  VDDMetaData.h
//  GimVic
//
//  Created by Vid Drobnič on 10/08/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDDMetaData : NSObject

#pragma mark - Class Functions

+ (instancetype)sharedMetaData;

#pragma mark - Object Functions

- (void)changeMetaDataAtributeWithKey:(NSString *)key toObject:(NSObject *)object;
- (NSObject *)metaDataObjectForKey:(NSString *)key;

@end