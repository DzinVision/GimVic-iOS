//
//  VDDRootViewController.m
//  GimVic
//
//  Created by Vid Drobnič on 09/13/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import "VDDRootViewController.h"
#import "VDDSuplenceViewController.h"
#import "VDDJedilnikViewController.h"
#import "VDDUrnikViewController.h"
#import "VDDHybridViewController.h"
#import "VDDMetaData.h"
#import "VDDTutorialViewController.h"

@interface VDDRootViewController ()

@end


@implementation VDDRootViewController

#pragma mark - Initialization

+ (instancetype)sharedRootViewController {
    static VDDRootViewController *sharedRootViewController;
    if (!sharedRootViewController) {
        sharedRootViewController = [[self alloc] initPrivate];
    }
    return sharedRootViewController;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"VDDRootViewController is a singleton. You should use +sharedRootViewController to access its instance."
                                 userInfo:nil];
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor colorWithRed:76/255.0 green:175/255.0 blue:80/255.0 alpha:1.0];
        
    }
    return self;
}

#pragma mark - Set Up

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.profPassword = @"c00c09606b70d76cd018a432116c3c91ef683d9756eaae7f93574c5789cdcacb";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    int savedView = [(NSNumber *)[[VDDMetaData sharedMetaData] metaDataObjectForKey:@"showedView"] intValue];
    
    if (savedView ==VDDSuplenceView) {
        [self changeToSuplence];
        return;
    }
    if (savedView == VDDSettingsView) {
        [self changeToSettings];
        return;
    }
    if (savedView == VDDJedilnikView) {
        [self changeToJedilnik];
        return;
    }
    if (savedView == VDDUrnikView) {
        [self changeToUrnik];
        return;
    }
    if (savedView == VDDHybridView) {
        [self changeToHybrid];
        return;
    }
    if (savedView == VDDSetupView) {
        [self changeToSetup];
        return;
    }
}

#pragma mark - ViewController Manipulation

- (void)cleanViews {
    NSArray *viewControllers = self.childViewControllers;
    for (UIViewController *i in viewControllers)
        [i removeFromParentViewController];
    
    NSArray *views = self.view.subviews;
    if (views.count == 0 || views == nil) return;
    
    
    [UIView transitionWithView:self.view
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [views[0] removeFromSuperview];
                    }
                    completion:nil];
}

- (void)changeToHybrid {
    [self cleanViews];
    
    VDDHybridViewController *hybridVC = [[VDDHybridViewController alloc] init];
    [self addChildViewController:hybridVC];
    [self.view addSubview:hybridVC.view];
    
    [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"showedView" toObject:[NSNumber numberWithInt:VDDHybridView]];
}

- (void)changeToHybridWithTutorial {
    [self changeToHybrid];
    VDDTutorialViewController *tutorialVC = [[VDDTutorialViewController alloc] init];
    tutorialVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:tutorialVC animated:YES completion:nil];
}

- (void)changeToSuplence {
    [self cleanViews];
    
    VDDSuplenceViewController *suplenceVC = [[VDDSuplenceViewController alloc] init];
    [self addChildViewController:suplenceVC];
    [self.view addSubview:suplenceVC.view];
    
    [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"showedView" toObject:[NSNumber numberWithInt:VDDSuplenceView]];
}

- (void)changeToJedilnik {
    [self cleanViews];
    
    VDDJedilnikViewController *jedilnikVC = [[VDDJedilnikViewController alloc] init];
    [self addChildViewController:jedilnikVC];
    [self.view addSubview:jedilnikVC.view];
    
    [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"showedView" toObject:[NSNumber numberWithInt:VDDJedilnikView]];
}

- (void)changeToSettings {
    [self cleanViews];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"VDDSettingsStoryboard" bundle:nil];
    UINavigationController *settingsVC = [storyboard instantiateInitialViewController];

    [self addChildViewController:settingsVC];
    [self.view addSubview:settingsVC.view];
    
    [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"showedView" toObject:[NSNumber numberWithInt:VDDSettingsView]];
}

- (void)changeToUrnik {
    [self cleanViews];
    
    VDDUrnikViewController *urnikVC = [[VDDUrnikViewController alloc] init];
    [self addChildViewController: urnikVC];
    [self.view addSubview:urnikVC.view];
    
    [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"showedView" toObject:[NSNumber numberWithInt:VDDUrnikView]];
}

- (void)changeToSetup {
    [self cleanViews];
    
    UIStoryboard *introStoryBaord = [UIStoryboard storyboardWithName:@"VDDIntroStoryboard" bundle:nil];
    UINavigationController *navigationVC = [introStoryBaord instantiateInitialViewController];
    [self addChildViewController:navigationVC];
    [self.view addSubview:navigationVC.view];
}

@end