//
//  VDDRootViewController.h
//  GimVic
//
//  Created by Vid Drobnič on 09/13/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VDDRootViewController : UIViewController

#pragma mark - Class Initializaiton
+ (instancetype)sharedRootViewController;


#pragma mark - ViewController Changing

- (void)changeToSettings;
- (void)changeToSuplence;
- (void)changeToUrnik;
- (void)changeToHybrid;
- (void)changeToHybridWithTutorial;
- (void)changeToJedilnik;
- (void)changeToSetup;

typedef enum {
    VDDSuplenceView,
    VDDSettingsView,
    VDDUrnikView,
    VDDTestiView,
    VDDSprasvanjaView,
    VDDJedilnikView,
    VDDHybridView,
    VDDSetupView
} VDDViewIndex;

#pragma mark - Static Variables

@property (atomic, strong) NSString *profPassword;

@end