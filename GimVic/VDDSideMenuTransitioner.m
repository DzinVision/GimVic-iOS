//
//  VDDSideMenuTransitioner.m
//  GimVic
//
//  Created by Vid Drobnič on 10/03/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import "VDDSideMenuTransitioner.h"
#import "VDDSideMenuPresentationCotroller.h"

#pragma mark - Transition Coordination Delegate

@implementation VDDSideMenuTransitioningDelegate

#pragma mark - Presentation Controller

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                      presentingViewController:(UIViewController *)presenting
                                                          sourceViewController:(UIViewController *)source {
    return [[VDDSideMenuPresentationCotroller alloc] initWithPresentedViewController:presented
                                                            presentingViewController:presenting];
}

#pragma mark - Animation Delegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source {
    VDDSideMenuAnimatedTransitioning *animationController = [[VDDSideMenuAnimatedTransitioning alloc] init];
    animationController.isPresentation = YES;
    
    return animationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    VDDSideMenuAnimatedTransitioning *animationController = [[VDDSideMenuAnimatedTransitioning alloc] init];
    animationController.isPresentation = NO;
    
    return animationController;
}

@end


#pragma mark - Transition Animation Delegate

@implementation VDDSideMenuAnimatedTransitioning

#pragma mark - Duration

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

#pragma mark - Animation

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *fromView = fromVC.view;
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = toVC.view;
    
    UIView *containerView = [transitionContext containerView];
    
    BOOL isPresentation = _isPresentation;
    if (isPresentation)
        [containerView addSubview:toView];
    
    UIViewController *animatingVC = isPresentation ? toVC : fromVC;
    UIView *animatingView = animatingVC.view;
    
    CGRect appearedFrame = [transitionContext finalFrameForViewController:animatingVC];
    CGRect dissmisedFrame = appearedFrame;
    dissmisedFrame.origin.x = 0 - dissmisedFrame.size.width;
    
    CGRect initialFrame = isPresentation ? dissmisedFrame : appearedFrame;
    CGRect finalFrame = isPresentation ? appearedFrame : dissmisedFrame;
    
    [animatingView setFrame:initialFrame];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.0
         usingSpringWithDamping:300.0
          initialSpringVelocity:5.0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [animatingView setFrame:finalFrame];
                     }
                     completion:^(BOOL finished){
                         if (!isPresentation)
                             [fromView removeFromSuperview];
                         [transitionContext completeTransition:YES];
                     }];
}

@end