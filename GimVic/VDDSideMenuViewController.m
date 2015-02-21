//
//  VDDSideMenuViewController.m
//  GimVic
//
//  Created by Vid Drobnič on 10/03/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import "VDDSideMenuViewController.h"
#import "VDDSideMenuTransitioner.h"
#import <QuartzCore/QuartzCore.h>

@interface VDDSideMenuViewController ()
{
    VDDViewIndex selectedView;
}
@end


@implementation VDDSideMenuViewController

#pragma mark - Initialization

- (instancetype)initWithSelectedView:(VDDViewIndex)viewIndex {
    self = [super init];
    if (self) {
        selectedView = viewIndex;
    }
    
    return self;
}

- (instancetype)init {
    return [self initWithSelectedView:VDDHybridView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    float width = self.view.frame.size.width * 0.7;
    
    UITraitCollection *currentTraits = [[UIScreen mainScreen] traitCollection];
    if (currentTraits.horizontalSizeClass == UIUserInterfaceSizeClassRegular && currentTraits.verticalSizeClass == UIUserInterfaceSizeClassRegular)
        width = self.view.bounds.size.width * 0.4;
    
    self.view.frame = CGRectMake(0, 0, width, self.view.frame.size.height);
    self.view.backgroundColor = [UIColor colorWithRed:76/255.0 green:175/255.0 blue:80/255.0 alpha:1.0];
    
    UIImage *closeButtonImage = [UIImage imageNamed:@"Cancel.png"];
    UIButton *dismissButton = [[UIButton alloc] init];
    [dismissButton addTarget:self action:@selector(dismissedButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [dismissButton setImage:closeButtonImage forState:UIControlStateNormal];
    dismissButton.frame = CGRectMake(self.view.bounds.size.width - 40, 25, 25, 25);
    [self.view addSubview:dismissButton];
    
    UIColor *buttonTextColor = [UIColor colorWithRed:200/255.0 green:230/255.0 blue:201/255.0 alpha:1.0];
    UIColor *buttonBorderColor = [UIColor colorWithRed:56/255.0 green:142/255.0 blue:60/255.0 alpha:1.0];
    UIColor *buttonSelectedColor = [UIColor colorWithRed:102/255.0 green:187/255.0 blue:106/255.0 alpha:1.0];
    
    UIButton *hybridButton = [[UIButton alloc] init];
    [hybridButton addTarget:self action:@selector(hybridButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [hybridButton setTitle:@"Urnik & Suplence" forState:UIControlStateNormal];
    [hybridButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
    [hybridButton sizeToFit];
    hybridButton.frame = CGRectMake(0, 65, self.view.bounds.size.width, hybridButton.frame.size.height + 10);
    hybridButton.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    hybridButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.view addSubview:hybridButton];
    
    if (selectedView == VDDHybridView) {
        hybridButton.backgroundColor = buttonSelectedColor;
        hybridButton.layer.borderWidth = 0.3;
        hybridButton.layer.borderColor = [buttonBorderColor CGColor];
    }
    
    
    UIButton *suplenceButton = [[UIButton alloc] init];
    [suplenceButton addTarget:self action:@selector(suplenceButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [suplenceButton setTitle:@"Suplence" forState:UIControlStateNormal];
    [suplenceButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
    [suplenceButton sizeToFit];
    suplenceButton.frame = CGRectMake(0, hybridButton.frame.origin.y + hybridButton.frame.size.height + 5, self.view.bounds.size.width, suplenceButton.frame.size.height + 10);
    suplenceButton.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    suplenceButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.view addSubview:suplenceButton];
    
    if (selectedView == VDDSuplenceView) {
        suplenceButton.backgroundColor = buttonSelectedColor;
        suplenceButton.layer.borderWidth = 0.3;
        suplenceButton.layer.borderColor = [buttonBorderColor CGColor];
    }
    
    
    UIButton *urnikButton = [[UIButton alloc] init];
    [urnikButton addTarget:self action:@selector(urnikButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [urnikButton setTitle:@"Urnik" forState:UIControlStateNormal];
    [urnikButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
    [urnikButton sizeToFit];
    urnikButton.frame = CGRectMake(0, suplenceButton.frame.origin.y + suplenceButton.frame.size.height + 5, self.view.bounds.size.width, urnikButton.frame.size.height + 10);
    urnikButton.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    urnikButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.view addSubview:urnikButton];
    
    if (selectedView == VDDUrnikView) {
        urnikButton.backgroundColor = buttonSelectedColor;
        urnikButton.layer.borderWidth = 0.3;
        urnikButton.layer.borderColor = [buttonBorderColor CGColor];
    }
    
    
    UIButton *jedilnikButton = [[UIButton alloc] init];
    [jedilnikButton addTarget:self action:@selector(jedilnikButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [jedilnikButton setTitle:@"Jedilnik" forState:UIControlStateNormal];
    [jedilnikButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
    [jedilnikButton sizeToFit];
    jedilnikButton.frame = CGRectMake(0, urnikButton.frame.origin.y + urnikButton.frame.size.height + 5, self.view.bounds.size.width, jedilnikButton.frame.size.height + 10);
    jedilnikButton.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    jedilnikButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.view addSubview:jedilnikButton];
    
    if (selectedView == VDDJedilnikView) {
        jedilnikButton.backgroundColor = buttonSelectedColor;
        jedilnikButton.layer.borderWidth = 0.3;
        jedilnikButton.layer.borderColor = [buttonBorderColor CGColor];
    }
    
    
    /*UIButton *testiButton = [[UIButton alloc] init];
    [testiButton addTarget:self action:@selector(testiButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [testiButton setTitle:@"Testi" forState:UIControlStateNormal];
    [testiButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
    [testiButton sizeToFit];
    testiButton.frame = CGRectMake(0, jedilnikButton.frame.origin.y + jedilnikButton.frame.size.height + 5, self.view.bounds.size.width, testiButton.frame.size.height + 10);
    testiButton.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    testiButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.view addSubview:testiButton];
    
    if (selectedView == VDDTestiView) {
        testiButton.backgroundColor = buttonSelectedColor;
        testiButton.layer.borderWidth = 0.3;
        testiButton.layer.borderColor = [buttonBorderColor CGColor];
    }
    
    
    UIButton *sprasevanjaButton = [[UIButton alloc] init];
    [sprasevanjaButton addTarget:self action:@selector(sprasevanjaButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [sprasevanjaButton setTitle:@"Spraševanja" forState:UIControlStateNormal];
    [sprasevanjaButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
    [sprasevanjaButton sizeToFit];
    sprasevanjaButton.frame = CGRectMake(0, testiButton.frame.origin.y + testiButton.frame.size.height + 5, self.view.bounds.size.width, sprasevanjaButton.frame.size.height + 10);
    sprasevanjaButton.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    sprasevanjaButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.view addSubview:sprasevanjaButton];
    
    if (selectedView == VDDSprasvanjaView) {
        sprasevanjaButton.backgroundColor = buttonSelectedColor;
        sprasevanjaButton.layer.borderWidth = 0.3;
        sprasevanjaButton.layer.borderColor = [buttonBorderColor CGColor];
    }*/
    
    
    UIButton *settingsButton = [[UIButton alloc] init];
    [settingsButton addTarget:self action:@selector(settingsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [settingsButton setTitle:@"Nastavitve" forState:UIControlStateNormal];
    [settingsButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
    [settingsButton sizeToFit];
    settingsButton.frame = CGRectMake(0, jedilnikButton.frame.origin.y + jedilnikButton.frame.size.height + 5, self.view.bounds.size.width, settingsButton.frame.size.height + 10);
    settingsButton.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    settingsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.view addSubview:settingsButton];
    
    if (selectedView == VDDSettingsView) {
        settingsButton.backgroundColor = buttonSelectedColor;
        settingsButton.layer.borderWidth = 0.3;
        settingsButton.layer.borderColor = [buttonBorderColor CGColor];
    }
}

#pragma mark - Button Actions

- (void)dismissedButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)hybridButtonPressed {
    if (selectedView == VDDHybridView) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[VDDRootViewController sharedRootViewController] changeToHybrid];
    }];
}

- (void)suplenceButtonPressed {
    if (selectedView == VDDSuplenceView) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[VDDRootViewController sharedRootViewController] changeToSuplence];
    }];
}

- (void)urnikButtonPressed {
    if (selectedView == VDDUrnikView) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[VDDRootViewController sharedRootViewController] changeToUrnik];
    }];
}

- (void)jedilnikButtonPressed {
    if (selectedView == VDDJedilnikView) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[VDDRootViewController sharedRootViewController] changeToJedilnik];
    }];
}

- (void)testiButtonPressed {
    if (selectedView == VDDTestiView) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
}

- (void)sprasevanjaButtonPressed {
    if (selectedView == VDDSprasvanjaView) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
}

- (void)settingsButtonPressed {
    if (selectedView == VDDSettingsView) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[VDDRootViewController sharedRootViewController] changeToSettings];
    }];
}

@end