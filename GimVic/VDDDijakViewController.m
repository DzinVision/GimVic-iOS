//
//  VDDDijakViewController.m
//  GimVic
//
//  Created by Vid Drobnič on 11/23/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import "VDDDijakViewController.h"
#import "VDDMetaData.h"
#import "VDDSubPredmetiViewController.h"
#import "VDDSuplenceDataFetch.h"
#import "VDDHybridDataFetch.h"
#import "VDDUrnikDataFetch.h"
#import "VDDRootViewController.h"

@interface VDDDijakViewController () <UIPickerViewDataSource, UIPickerViewDelegate, VDDSubPredmetiDelegate>
{
    NSMutableArray *subFilter;
    NSMutableArray *razredi;
}

@property (weak, nonatomic) IBOutlet UIButton *changeSubFilter;
@property (weak, nonatomic) IBOutlet UIPickerView *changFilter;

@end


@implementation VDDDijakViewController

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    subFilter = (NSMutableArray *)[[VDDMetaData sharedMetaData] metaDataObjectForKey:@"podFilter"];
    if (subFilter == nil)
        subFilter = [[NSMutableArray alloc] init];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;

    razredi = [[NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/unfilteredPodatki", documentsPath]] objectForKey:@"razredi"];
    razredi = [[razredi sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
    
    _changeSubFilter.hidden = YES;
}

#pragma mark - PickerViewController Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return razredi.count;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title = razredi[row];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title
                                                                    attributes:@{NSForegroundColorAttributeName:
                                                                                     [UIColor colorWithRed:200/255.0 green:230/255.0 blue:201/255.0 alpha:1.0]
                                                                                 }];
    return attString;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *filterString = razredi[row];
    
    if (([[filterString substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"3"] ||
         [[filterString substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"4"]) &&
        _changeSubFilter.hidden == YES)
    {
        _changeSubFilter.alpha = 0.0;
        _changeSubFilter.hidden = NO;
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             _changeSubFilter.alpha = 1.0;
                         }];
    }
    
    
    if (([[filterString substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"1"] ||
         [[filterString substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"2"]) &&
        _changeSubFilter.hidden == NO)
    {
        [UIView animateWithDuration:0.3
                         animations:^{
                             _changeSubFilter.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             _changeSubFilter.hidden = YES;
                         }];
    }
}

#pragma mark - Filtering

- (IBAction)setFilter:(id)sender {
    NSString *filter = razredi[[_changFilter selectedRowInComponent:0]];
    filter = filter.lowercaseString;
    [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"filter" toObject:filter];
    
    
    filter = [filter substringWithRange:NSMakeRange(0, 1)];
    if ([filter isEqualToString:@"1"] || [filter isEqualToString:@"2"])
        subFilter = [@[] mutableCopy];
    
    if (subFilter.count > 0) {
        NSMutableString *buffString = [subFilter[0] mutableCopy];
        buffString = [[buffString substringWithRange:NSMakeRange(0, 1)] mutableCopy];
        if ([buffString isEqualToString:@"m"] && ![filter isEqualToString:@"4"])
            subFilter = [@[] mutableCopy];
        
        if ([buffString isEqualToString:@"3"] && ![filter isEqualToString:@"3"])
            subFilter = [@[] mutableCopy];
    }
    
    NSArray *subFilterFinal = subFilter;
    [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"podFilter" toObject:subFilterFinal];
    
    [NSThread detachNewThreadSelector:@selector(filterEverything) toTarget:self withObject:nil];
    
    [[VDDRootViewController sharedRootViewController] changeToHybridWithTutorial];
}

- (void)filterEverything {
    [[VDDSuplenceDataFetch sharedSuplenceDataFetch] filter];
    [[VDDUrnikDataFetch sharedUrnikDataFetch] filter];
    [[VDDHybridDataFetch sharedHybridDataFetch] refresh];
}

- (IBAction)changeSubFilterView:(id)sender {
    NSString *currentFilter = razredi[[_changFilter selectedRowInComponent:0]];
    currentFilter = [currentFilter substringWithRange:NSMakeRange(0, 1)];

    if (subFilter.count > 0) {
        NSMutableString *buffString = [subFilter[0] mutableCopy];
        buffString = [[buffString substringWithRange:NSMakeRange(0, 1)] mutableCopy];
        if ([buffString isEqualToString:@"M"] && ![currentFilter isEqualToString:@"4"])
            subFilter = [@[] mutableCopy];
        
        if ([buffString isEqualToString:@"3"] && ![currentFilter isEqualToString:@"3"])
            subFilter = [@[] mutableCopy];
    }
    
    VDDSubPredmetiViewController *changeSubPredmetiVC = [[VDDSubPredmetiViewController alloc] initWithSelectedRazreds:subFilter class:currentFilter];
    changeSubPredmetiVC.delegate = self;
    changeSubPredmetiVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:changeSubPredmetiVC animated:YES completion:nil];
}

- (void)changeSubFilter:(NSMutableArray *)newSubFilter {
    subFilter = [newSubFilter copy];
}

#pragma mark - Button Actions

- (IBAction)back:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end