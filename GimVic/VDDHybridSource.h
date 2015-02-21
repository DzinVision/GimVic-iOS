//
//  VDDHybridSource.h
//  GimVic
//
//  Created by Vid Drobnič on 11/22/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VDDHybridSource : NSObject <UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithIndex:(int)index data:(NSArray *)urnikData NS_DESIGNATED_INITIALIZER;
- (void)reloadData:(NSArray *)newData;

@end