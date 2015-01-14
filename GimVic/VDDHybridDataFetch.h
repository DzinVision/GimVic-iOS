//
//  VDDHybridDataFetch.h
//  GimVic
//
//  Created by Vid Drobnič on 11/13/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDDHybridDataFetch : NSObject

@property (atomic) BOOL isRefreshing;

#pragma mark - Class Funcitons

+ (instancetype)sharedHybridDataFetch;

#pragma mark - Object Functions

- (void)refresh;

@end