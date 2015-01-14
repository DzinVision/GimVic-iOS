//
//  VDDUrnikDataFetch.h
//  GimVic
//
//  Created by Vid Drobnič on 10/16/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDDUrnikDataFetch : NSObject

@property (atomic) BOOL isRefreshing;

#pragma mark - Class Funcitons

+ (instancetype)sharedUrnikDataFetch;

#pragma mark - Object Functions

- (void)refresh;
- (void)filter;

@end