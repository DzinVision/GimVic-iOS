//
//  VDDJedilnikViewController.m
//  GimVic
//
//  Created by Vid Drobnič on 10/12/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import "VDDJedilnikViewController.h"
#import "VDDRootViewController.h"
#import "VDDSideMenuViewController.h"
#import "VDDSideMenuTransitioner.h"
#import "VDDJedilnikDataFetch.h"

@interface VDDJedilnikViewController () <UIScrollViewDelegate, UIWebViewDelegate>
{
    UIScrollView *mainScrollView;
    UIScrollView *tabBarScroll;
    UIWebView *malicaView;
    UIWebView *kosiloView;
    
    UIButton *refreshButton;
    UIActivityIndicatorView *refreshing;
    
    id <UIViewControllerTransitioningDelegate> transitioningDelegate;
}
@end


@implementation VDDJedilnikViewController

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadViews)
                                                 name:@"VDDJedilnikFetchComplete"
                                               object:nil];
    
    
    mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, self.view.bounds.size.width, self.view.bounds.size.height - 60)];
    mainScrollView.pagingEnabled = YES;
    mainScrollView.userInteractionEnabled = YES;
    mainScrollView.showsHorizontalScrollIndicator = NO;
    mainScrollView.showsVerticalScrollIndicator = NO;
    mainScrollView.contentSize = CGSizeMake(2*self.view.bounds.size.width, self.view.bounds.size.height - 60);
    mainScrollView.delegate = self;
    mainScrollView.backgroundColor = [UIColor colorWithRed:165/255.0 green:214/255.0 blue:167/255.0 alpha:1.0];
    [self.view addSubview:mainScrollView];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = (paths.count > 0) ? paths[0] : nil;
    
    NSData *malicaCheckData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/malica.pdf", documentsPath]];
    if (malicaCheckData) {
        malicaView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, mainScrollView.bounds.size.height)];
        malicaView.scalesPageToFit = YES;
        
        NSURL *malicaPath = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/malica.pdf", documentsPath]];
        NSURLRequest *malicaRequest = [NSURLRequest requestWithURL:malicaPath];
        [malicaView loadRequest:malicaRequest];
        [mainScrollView addSubview:malicaView];
    }
    else {
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"VDDNilJedilnik" owner:self options:nil];
        UIView *view = views[0];
        view.frame = CGRectMake(0, 0, self.view.bounds.size.width, mainScrollView.bounds.size.height);
        [mainScrollView addSubview:view];
    }
    
    NSData *kosiloCheckData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/kosilo.pdf", documentsPath]];
    if (kosiloCheckData) {
        kosiloView = [[UIWebView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, mainScrollView.bounds.size.height)];
        kosiloView.scalesPageToFit = YES;
        NSURL *kosiloPath = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/kosilo.pdf", documentsPath]];
        NSURLRequest *kosiloRequest = [NSURLRequest requestWithURL:kosiloPath];
        [kosiloView loadRequest:kosiloRequest];
        [mainScrollView addSubview:kosiloView];
    }
    else {
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"VDDNilJedilnik" owner:self options:nil];
        UIView *view = views[0];
        view.frame = CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, mainScrollView.bounds.size.height);
        [mainScrollView addSubview:view];
    }
    
    
    UIView *tabBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 60)];
    tabBar.backgroundColor = [UIColor colorWithRed:76/255.0 green:175/255.0 blue:80/255.0 alpha:1.0];
    [self.view addSubview:tabBar];
    
    
    UIImage *sideMenuImage = [UIImage imageNamed:@"Menu.png"];
    UIButton *button = [[UIButton alloc] init];
    [button addTarget:self action:@selector(showSideMenu) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:sideMenuImage forState:UIControlStateNormal];
    button.frame = CGRectMake(20, 20, 30, 30);
    [self.view addSubview:button];
    
    
    UIImage *refreshImage = [UIImage imageNamed:@"Reload.png"];
    refreshButton = [[UIButton alloc] init];
    [refreshButton addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
    [refreshButton setImage:refreshImage forState:UIControlStateNormal];
    refreshButton.frame = CGRectMake(self.view.bounds.size.width - 50, 20, 30, 30);
    [self.view addSubview:refreshButton];
    
    refreshing = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 50, 20, 30, 30)];
    refreshing.color = [UIColor colorWithRed:200/255.0 green:230/255.0 blue:201/255.0 alpha:1.0];
    [self.view addSubview:refreshing];
    [refreshing stopAnimating];
    
    
    tabBarScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(70, 20, self.view.bounds.size.width - 2*70, 30)];
    [self.view addSubview:tabBarScroll];
    tabBarScroll.userInteractionEnabled = NO;
    tabBarScroll.showsHorizontalScrollIndicator = NO;
    tabBarScroll.showsVerticalScrollIndicator = NO;
    tabBarScroll.pagingEnabled = YES;
    tabBarScroll.contentSize = CGSizeMake(2*tabBarScroll.bounds.size.width, tabBarScroll.bounds.size.height);
    
    UILabel *malicaLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tabBarScroll.bounds.size.width, tabBarScroll.bounds.size.height)];
    UILabel *kosiloLabel = [[UILabel alloc] initWithFrame:CGRectMake(tabBarScroll.bounds.size.width, 0, tabBarScroll.bounds.size.width, tabBarScroll.bounds.size.height)];
    
    malicaLabel.text = @"Malica";
    kosiloLabel.text = @"Kosilo";
    
    malicaLabel.textAlignment = NSTextAlignmentCenter;
    kosiloLabel.textAlignment = NSTextAlignmentCenter;
    
    malicaLabel.textColor = [UIColor colorWithRed:200/255.0 green:230/255.0 blue:201/255.0 alpha:1.0];
    kosiloLabel.textColor = [UIColor colorWithRed:200/255.0 green:230/255.0 blue:201/255.0 alpha:1.0];
    
    [tabBarScroll addSubview:malicaLabel];
    [tabBarScroll addSubview:kosiloLabel];
}

#pragma mark - Refreshing

- (void)reloadViews {
    if (refreshing.isAnimating == YES) {
        [refreshing stopAnimating];
        refreshButton.hidden = NO;
    }
    
    
    NSMutableArray *subviews = [NSMutableArray arrayWithArray:mainScrollView.subviews];
    BOOL sorted = NO;
    while (!sorted) {
        sorted = YES;
        for (int i = 0; i < subviews.count-1; i++) {
            UIView *view1 = subviews[i];
            UIView *view2 = subviews[i+1];
            if (view1.frame.origin.x > view2.frame.origin.x) {
                subviews[i] = view2;
                subviews[i+1] = view1;
                sorted = NO;
            }
        }
    }

    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = (paths.count > 0) ? paths[0] : nil;
    
    NSData *malicaCheckData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/malica.pdf", documentsPath]];
    if (malicaCheckData) {
        if (!malicaView) {
            [subviews[0] removeFromSuperview];
            malicaView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, mainScrollView.bounds.size.height)];
            malicaView.scalesPageToFit = YES;
            [mainScrollView addSubview:malicaView];
        }
        NSURL *malicaPath = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/malica.pdf", documentsPath]];
        NSURLRequest *malicaRequest = [NSURLRequest requestWithURL:malicaPath];
        [malicaView loadRequest:malicaRequest];
    }
    else if (malicaView) {
        [malicaView removeFromSuperview];
        malicaView = nil;
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"VDDNilJedilnik" owner:self options:nil];
        UIView *view = views[0];
        view.frame = CGRectMake(0, 0, self.view.bounds.size.width, mainScrollView.bounds.size.height);
        [mainScrollView addSubview:view];
    }
    
    NSData *kosiloCheckData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/kosilo.pdf", documentsPath]];
    if (kosiloCheckData) {
        if (!kosiloView) {
            [subviews[1] removeFromSuperview];
            kosiloView = [[UIWebView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, mainScrollView.bounds.size.height)];
            kosiloView.scalesPageToFit = YES;
            [mainScrollView addSubview:kosiloView];
        }
        NSURL *kosiloPath = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/kosilo.pdf", documentsPath]];
        NSURLRequest *kosiloRequest = [NSURLRequest requestWithURL:kosiloPath];
        [kosiloView loadRequest:kosiloRequest];
    }
    else if (kosiloView){
        [kosiloView removeFromSuperview];
        kosiloView = nil;
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"VDDNilJedilnik" owner:self options:nil];
        UIView *view = views[0];
        view.frame = CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, mainScrollView.bounds.size.height);
        [mainScrollView addSubview:view];
    }
}

- (void)refresh {
    if (refreshButton.hidden == NO) {
        refreshButton.hidden = YES;
        [refreshing startAnimating];
    }
    if ([VDDJedilnikDataFetch sharedJedilnikDataFetch].isRefreshing == NO)
        [NSThread detachNewThreadSelector:@selector(forceRefresh) toTarget:[VDDJedilnikDataFetch sharedJedilnikDataFetch] withObject:nil];
}

#pragma mark - UI Actions

- (void)showSideMenu {
    VDDSideMenuViewController *sideMenu = [[VDDSideMenuViewController alloc] initWithSelectedView:VDDJedilnikView];
    sideMenu.modalPresentationStyle = UIModalPresentationCustom;
    
    transitioningDelegate = [[VDDSideMenuTransitioningDelegate alloc] init];
    sideMenu.transitioningDelegate = transitioningDelegate;
    
    [self presentViewController:sideMenu animated:YES completion:NULL];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    double percentageScrolled = scrollView.contentOffset.x / scrollView.contentSize.width;
    tabBarScroll.contentOffset = CGPointMake(tabBarScroll.contentSize.width * percentageScrolled, 0);
}

@end