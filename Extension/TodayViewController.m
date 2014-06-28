//
//  TodayViewController.m
//  Extension
//
//  Created by Vid Drobnič on 6/6/14.
//  Copyright (c) 2014 Vid Drobnic. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation TodayViewController

- (IBAction)openApp:(id)sender {
    NSString *url = @"GimVic://";
    [[self extensionContext] openURL:[NSURL URLWithString:url] completionHandler:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSDateFormatter *dFormatter = [[NSDateFormatter alloc] init];
    dFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *date = [dFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSDictionary *content = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/organised-%@", documentsPath, date]];
    
    NSUInteger nadomescanjaNum = [[content valueForKey:@"nadomescanja"] count];
    NSUInteger menjavaPredmetaNum = [[content valueForKey:@"menjavaPredmeta"] count];
    NSUInteger menjavaUrNum = [[content valueForKey:@"menjavaUr"] count];
    NSUInteger menjavaUcilnicNum = [[content valueForKey:@"menjavaUcilnic"] count];
    NSUInteger rezervacijaUcilnicNum = [[content valueForKey:@"rezervacijaUcilnic"] count];
    NSUInteger vecUciteljevRazreduNum = [[content valueForKey:@"vecUciteljevVRazredu"] count];
    
    
    NSUInteger sum = nadomescanjaNum + menjavaPredmetaNum + menjavaUrNum + menjavaUcilnicNum + rezervacijaUcilnicNum + vecUciteljevRazreduNum;
    if (sum == 0) {
        _label.text = @"Danes nimaš nobenih posebnosti na urniku.";
    } else if (sum == 1) {
        _label.text = @"Danes imaš 1 posebnost na urniku.";
    } else if (sum == 2) {
        _label.text = @"Danes imaš 2 posebnosti na urniku.";
    } else {
        _label.text = [NSString stringWithFormat:@"Danes imaš %i nadomeščanj.", sum];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encoutered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

@end
