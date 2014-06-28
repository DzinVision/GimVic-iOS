//
//  DZNImageViewController.h
//  GimVic
//
//  Created by Vid Drobnič on 21/05/14.
//  Copyright (c) 2014 Vid Drobnic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DZNImageViewController : UIViewController

@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *barTitle;

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@end
