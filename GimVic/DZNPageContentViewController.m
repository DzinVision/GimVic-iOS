//
//  DZNPageContentViewController.m
//  GimVic
//
//  Created by Vid Drobnič on 18/05/14.
//  Copyright (c) 2014 Vid Drobnic. All rights reserved.
//

#import "DZNPageContentViewController.h"
#import "DZNDaysViewController.h"
#import "DZNImageViewController.h"

@interface DZNPageContentViewController ()

@end

@implementation DZNPageContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.viewControllers[0] setPageIndex: _pageIndex];
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:NSCalendarUnitWeekday fromDate:[NSDate dateWithTimeIntervalSinceNow:24*3600*_pageIndex]];
    int weekday = [comps weekday];
    weekday--;
    
    if (weekday == 0 || weekday == 6) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        DZNImageViewController *imageViewController = [sb instantiateViewControllerWithIdentifier:@"imageView"];
        
/*        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
        [imageView setImage:[UIImage imageNamed:@"smile.png"]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        UIViewController *viewController = [[UIViewController alloc] init];
        viewController.view = imageView;
        
        self.navigationBarHidden = NO;
        [self pushViewController:viewController animated:NO];*/
        
        imageViewController.imageName = @"smile.png";
        
        NSArray *days = @[@"Nedelja", @"Ponedeljek", @"Torek", @"Sreda", @"Četrtek", @"Petek", @"Sobota"];

        imageViewController.barTitle = days[weekday];
        
        self.navigationBarHidden = YES;
        [self addChildViewController:imageViewController];
        [self.view addSubview:imageViewController.view];
    }
}

@end
