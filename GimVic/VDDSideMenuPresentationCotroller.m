//
//  VDDSideMenuPresentationCotroller.m
//  GimVic
//
//  Created by Vid Drobnič on 10/03/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import "VDDSideMenuPresentationCotroller.h"

@interface VDDSideMenuPresentationCotroller ()
{
    UIView *dimmingView;
}
@end


@implementation VDDSideMenuPresentationCotroller

#pragma mark - Initialization

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                      presentingViewController:(UIViewController *)presentingViewController {
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        dimmingView = [[UIView alloc] init];
        dimmingView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
        dimmingView.alpha = 0.0;
    }
    return self;
}

#pragma mark - Beginning & Ending

- (void)presentationTransitionWillBegin {
    dimmingView.frame = self.containerView.bounds;
    [self.containerView insertSubview:dimmingView atIndex:0];
    
    if ([self.presentedViewController transitionCoordinator]) {
        [[self.presentedViewController transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            dimmingView.alpha = 1.0;
        } completion:nil];
    } else dimmingView.alpha = 1.0;
}

- (void)dismissalTransitionWillBegin {
    if ([self.presentedViewController transitionCoordinator]) {
        [[self.presentedViewController transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            dimmingView.alpha = 0.0;
        } completion:nil];
    } else dimmingView.alpha = 0.0;
}

#pragma mark - Size

- (CGSize)sizeForChildContentContainer:(id<UIContentContainer>)container
               withParentContainerSize:(CGSize)parentSize {
    float width = parentSize.width * 0.7;
    
    UITraitCollection *currentTraits = [[UIScreen mainScreen] traitCollection];
    if (currentTraits.horizontalSizeClass == UIUserInterfaceSizeClassRegular && currentTraits.verticalSizeClass == UIUserInterfaceSizeClassRegular)
        width = parentSize.width * 0.4;
    
    return CGSizeMake(width, parentSize.height);
}

- (CGRect)frameOfPresentedViewInContainerView {
    UITraitCollection *currentTraits = [[UIScreen mainScreen] traitCollection];
    if (currentTraits.horizontalSizeClass == UIUserInterfaceSizeClassRegular && currentTraits.verticalSizeClass == UIUserInterfaceSizeClassRegular)
        return CGRectMake(0, 0, self.presentingViewController.view.bounds.size.width * 0.4, self.presentingViewController.view.bounds.size.height);
    
    return CGRectMake(0, 0, self.presentingViewController.view.bounds.size.width * 0.7, self.presentingViewController.view.bounds.size.height);
}

- (BOOL)shouldPresentInFullscreen {
    return NO;
}

@end