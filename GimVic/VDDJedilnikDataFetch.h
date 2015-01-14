//
//  VDDJedilnikDataFetch.h
//  GimVic
//
//  Created by Vid Drobnič on 10/09/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDDJedilnikDataFetch : NSObject

@property (atomic) BOOL isRefreshing;

#pragma mark - Class Funcitons

+ (instancetype)sharedJedilnikDataFetch;

#pragma mark - Object Functions

- (void)forceRefresh;
- (void)downloadJedilnik;

@end
