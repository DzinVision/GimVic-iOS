//
//  VDDSubPredmetiViewController.h
//  GimVic
//
//  Created by Vid Drobnič on 11/18/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VDDDijakViewController.h"

#pragma mark - Protocol Declaration

@protocol VDDSubPredmetiDelegate

- (void)changeSubFilter:(NSMutableArray *)newSubFilter;

@end


#pragma mark - Class Declaration

@interface VDDSubPredmetiViewController : UIViewController

- (instancetype)initWithSelectedRazreds:(NSMutableArray *)selectedRazreds class:(NSString *)razred NS_DESIGNATED_INITIALIZER;

@property (nonatomic, weak) id<VDDSubPredmetiDelegate> delegate;

@end