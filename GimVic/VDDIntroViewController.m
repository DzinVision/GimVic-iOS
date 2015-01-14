//
//  VDDIntroViewController.m
//  GimVic
//
//  Created by Vid Drobnič on 11/22/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import "VDDIntroViewController.h"
#import "VDDAppDelegate.h"
#import "VDDRootViewController.h"
#import "VDDReachability.h"
#import "VDDSuplenceDataFetch.h"
#import "VDDUrnikDataFetch.h"
#import "VDDHybridDataFetch.h"
#import "VDDJedilnikDataFetch.h"

@interface VDDIntroViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *chooseLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *dijak;
@property (weak, nonatomic) IBOutlet UIButton *profesor;
@property (weak, nonatomic) IBOutlet UILabel *noInternetError;
@property (weak, nonatomic) IBOutlet UILabel *noDataError;
@property (weak, nonatomic) IBOutlet UIButton *retryButton;

@end


@implementation VDDIntroViewController

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setFilter) name:@"VDDUrnikFetchComplete" object:nil];
    
    self.navigationController.navigationBarHidden = YES;
    
    _chooseLabel.hidden = YES;
    _dijak.hidden = YES;
    _profesor.hidden = YES;
    _noDataError.hidden = YES;
    _noInternetError.hidden = YES;
    _retryButton.hidden = YES;
}

#pragma mark - Filtering

- (void)setFilter {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(setFilter) withObject:nil waitUntilDone:NO];
        return;
    }
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSMutableDictionary *urnikData = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/unfilteredPodatki", documentsPath]];
    
    if (![VDDReachability checkInternetConnection]) {
        _noInternetError.alpha = 0.0;
        _noInternetError.hidden = NO;
        
        _retryButton.alpha = 0.0;
        _retryButton.hidden = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            _noInternetError.alpha = 1.0;
            _retryButton.alpha = 1.0;
            
            _infoLabel.alpha = 0.0;
            _activityIndicator.alpha = 0.0;
        } completion:^(BOOL finished) {
            _infoLabel.hidden = YES;
            _activityIndicator.hidden = YES;
        }];
        
        return;
    }
    
    if (urnikData == nil) {
        _noDataError.alpha = 0.0;
        _noDataError.hidden = NO;
            
        [_activityIndicator stopAnimating];
            
        [UIView animateWithDuration:0.3 animations:^{
            _noDataError.alpha = 1.0;
            
            _infoLabel.alpha = 0.0;
            _activityIndicator.alpha = 0.0;
        } completion:^(BOOL finished) {
            _infoLabel.hidden = YES;
            _activityIndicator.hidden = YES;
        }];
        return;
    }
    
    
    
    _chooseLabel.alpha = 0.0;
    _chooseLabel.hidden = NO;
    
    _dijak.alpha = 0.0;
    _dijak.hidden = NO;
    
    _profesor.alpha = 0.0;
    _profesor.hidden = NO;
    
    [_activityIndicator stopAnimating];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         _chooseLabel.alpha = 1.0;
                         _dijak.alpha = 1.0;
                         _profesor.alpha = 1.0;
                         
                         _infoLabel.alpha = 0.0;
                         _activityIndicator.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         _infoLabel.hidden = YES;
                         _activityIndicator.hidden = YES;
                     }];
}

- (IBAction)retry:(id)sender {
    if (![VDDReachability checkInternetConnection]) return;
    
    _infoLabel.alpha = 0.0;
    _infoLabel.hidden = NO;
    
    _activityIndicator.alpha = 0.0;
    _activityIndicator.hidden = NO;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         _infoLabel.alpha = 1.0;
                         _activityIndicator.alpha = 1.0;
                         
                         _noInternetError.alpha = 0.0;
                         _retryButton.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         _noInternetError.hidden = YES;
                         _retryButton.hidden = YES;
                     }];
    
    [NSThread detachNewThreadSelector:@selector(refresh) toTarget:self withObject:nil];
}

#pragma mark - Refresh

- (void)refresh {
    [[VDDSuplenceDataFetch sharedSuplenceDataFetch] refresh];
    [[VDDUrnikDataFetch sharedUrnikDataFetch] refresh];
    [[VDDHybridDataFetch sharedHybridDataFetch] refresh];
    [[VDDJedilnikDataFetch sharedJedilnikDataFetch] downloadJedilnik];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end