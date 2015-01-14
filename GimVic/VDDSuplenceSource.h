//
//  VDDSuplenceSource.h
//  GimVic
//
//  Created by Vid Drobnič on 09/14/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VDDSuplenceSource : NSObject <UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithIndex:(int)index data:(NSDictionary *)data numberOfSections:(int)numberOfSections;
- (void)reloadData:(NSDictionary *)newData;

@end