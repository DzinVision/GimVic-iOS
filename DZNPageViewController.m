//
//  DZNPageViewController.m
//  GimVic
//
//  Created by Vid Drobnič on 18/05/14.
//  Copyright (c) 2014 Vid Drobnic. All rights reserved.
//

#import "DZNPageViewController.h"
#import "DZNPageContentViewController.h"

@interface DZNPageViewController ()

@property (strong, nonatomic) UIPageViewController *pageViewController;

@end


@implementation DZNPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
    
    DZNPageContentViewController *startingViewController = [self viewControllerAtIndex: 0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
    self.pageViewController.dataSource = self;
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];
}

-(DZNPageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (index >= 3) {
        return nil;
    }
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    DZNPageContentViewController *pageContentViewController = [sb instantiateViewControllerWithIdentifier:@"pageContentViewController"];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController
     viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((DZNPageContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((DZNPageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == 3) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return 3;
}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

@end
