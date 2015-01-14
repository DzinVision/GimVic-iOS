//
//  VDDAboutViewController.m
//  GimVic
//
//  Created by Vid Drobnič on 11/27/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import "VDDAboutViewController.h"

@interface VDDAboutViewController ()

@end


@implementation VDDAboutViewController

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Button Actions

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end