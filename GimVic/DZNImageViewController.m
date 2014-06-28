//
//  DZNImageViewController.m
//  GimVic
//
//  Created by Vid Drobnič on 21/05/14.
//  Copyright (c) 2014 Vid Drobnic. All rights reserved.
//

#import "DZNImageViewController.h"

@interface DZNImageViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end


@implementation DZNImageViewController

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _imageView.image = [UIImage imageNamed:_imageName];
    _navigationBar.topItem.title = _barTitle;
    
    /*CGRect screenSize = [[UIScreen mainScreen] bounds];
    _imageView.frame = CGRectMake(0, 45, screenSize.size.width, screenSize.size.height - 45);
    _navigationBar.frame = CGRectMake(0, 0, screenSize.size.width, 43);*/
}

@end
