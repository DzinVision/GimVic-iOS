//
//  VDDDataFetch.h
//  GimVic
//
//  Created by Vid Drobnič on 09/13/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDDSuplenceDataFetch : NSObject

@property (atomic) BOOL isRefreshing;

#pragma mark - Class Functions

+ (instancetype)sharedSuplenceDataFetch;

#pragma mark - Object Functions

- (void)refresh;
- (void)filter;

@end
