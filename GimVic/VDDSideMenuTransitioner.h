//
//  VDDSideMenuTransitioner.h
//  GimVic
//
//  Created by Vid Drobnič on 10/03/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Transition Animation Delegate

@interface VDDSideMenuAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>
@property BOOL isPresentation;
@end


#pragma mark - Transition Coordination Delegate

@interface VDDSideMenuTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate>
@end