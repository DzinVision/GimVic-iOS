//
//  VDDSettingsTabBarViewController.m
//  GimVic
//
//  Created by Vid Drobnič on 11/26/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import "VDDSettingsTabBarViewController.h"
#import "VDDSideMenuViewController.h"
#import "VDDSideMenuTransitioner.h"

@interface VDDSettingsTabBarViewController ()
{
    id <UIViewControllerTransitioningDelegate> transitioningDelegate;
}
@end


@implementation VDDSettingsTabBarViewController

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - UI Actions

- (IBAction)showSideMenu:(id)sender {
    VDDSideMenuViewController *sideMenu = [[VDDSideMenuViewController alloc] initWithSelectedView:VDDSettingsView];
    sideMenu.modalPresentationStyle = UIModalPresentationCustom;
    
    transitioningDelegate = [[VDDSideMenuTransitioningDelegate alloc] init];
    sideMenu.transitioningDelegate = transitioningDelegate;
    
    [self presentViewController:sideMenu animated:YES completion:nil];
}

@end