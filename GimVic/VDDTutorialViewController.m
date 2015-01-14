//
//  VDDTutorialViewController.m
//  GimVic
//
//  Created by Vid Drobnič on 12/29/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import "VDDTutorialViewController.h"

@interface VDDTutorialViewController () <UIScrollViewDelegate>
{
    UIPageControl *pageControl;
    UIButton *end;
}
@end


@implementation VDDTutorialViewController

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *hybridChanges = [[NSBundle mainBundle] loadNibNamed:@"HybridChanges" owner:self options:nil][0];
    UIView *hybridNavigation = [[NSBundle mainBundle] loadNibNamed:@"HybridNavigation" owner:self options:nil][0];
    UIView *hybridRefresh = [[NSBundle mainBundle] loadNibNamed:@"HybridRefresh" owner:self options:nil][0];
    UIView *hybridMenuButton = [[NSBundle mainBundle] loadNibNamed:@"HybridMenuButton" owner:self options:nil][0];
    UIView *hybridMenu = [[NSBundle mainBundle] loadNibNamed:@"HybridMenu" owner:self options:nil][0];
    UIView *suplence = [[NSBundle mainBundle] loadNibNamed:@"Suplence" owner:self options:nil][0];
    UIView *urnik = [[NSBundle mainBundle] loadNibNamed:@"Urnik" owner:self options:nil][0];
    UIView *jedilnik = [[NSBundle mainBundle] loadNibNamed:@"Jedilnik" owner:self options:nil][0];
    UIView *settings = [[NSBundle mainBundle] loadNibNamed:@"Settings" owner:self options:nil][0];
    
    NSArray *views = @[hybridChanges, hybridNavigation, hybridRefresh, hybridMenuButton, hybridMenu, suplence, urnik, jedilnik, settings];
    for (int i = 0; i < views.count; i++)
        ((UIView *)views[i]).frame = CGRectMake(self.view.bounds.size.width * i, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    
    UIScrollView *mainScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    mainScrollView.contentSize = CGSizeMake(self.view.bounds.size.width * views.count, self.view.bounds.size.height);
    mainScrollView.pagingEnabled = YES;
    mainScrollView.userInteractionEnabled = YES;
    mainScrollView.showsHorizontalScrollIndicator = NO;
    mainScrollView.showsVerticalScrollIndicator = NO;
    mainScrollView.delegate = self;
    mainScrollView.backgroundColor = [UIColor colorWithRed:165/255.0 green:214/255.0 blue:167/255.0 alpha:1.0];
    
    for (int i = 0; i < views.count; i++)
         [mainScrollView addSubview:views[i]];
    
    [self.view addSubview:mainScrollView];
    
    
    pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = views.count;
    pageControl.currentPage = 0;
    [pageControl sizeToFit];
    pageControl.frame = CGRectMake(self.view.bounds.size.width / 2 - pageControl.frame.size.width / 2,
                                   self.view.bounds.size.height - 8 - pageControl.frame.size.height,
                                   pageControl.frame.size.width,
                                   pageControl.frame.size.height);
    [self.view addSubview:pageControl];
    
    
    end = [[UIButton alloc] init];
    [end addTarget:self action:@selector(skip) forControlEvents:UIControlEventTouchUpInside];
    [end setTitle:@"Preskoči" forState:UIControlStateNormal];
    [end setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    end.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [end sizeToFit];
    end.frame = CGRectMake(self.view.bounds.size.width - 10 - end.frame.size.width,
                           self.view.bounds.size.height - 13 - end.frame.size.height,
                           end.frame.size.width,
                           end.frame.size.height);
    [self.view addSubview:end];
}

#pragma mark - Button Actions

- (void)skip {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    pageControl.currentPage = scrollView.contentOffset.x / self.view.bounds.size.width;
    if (pageControl.currentPage == 8)
        [end setTitle:@"Končaj" forState:UIControlStateNormal];
    else
        [end setTitle:@"Preskoči" forState:UIControlStateNormal];
}

@end