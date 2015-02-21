//
//  VDDDijakiFilterViewController.m
//  GimVic
//
//  Created by Vid Drobnič on 11/27/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import "VDDDijakiFilterViewController.h"
#import "VDDMetaData.h"
#import "VDDSubPredmetiViewController.h"
#import "VDDSuplenceDataFetch.h"
#import "VDDUrnikDataFetch.h"
#import "VDDHybridDataFetch.h"

@interface VDDDijakiFilterViewController () <UIPickerViewDataSource, UIPickerViewDelegate, VDDSubPredmetiDelegate>

#pragma mark - Variable Creation

{
    NSMutableArray *subFilter;
    NSMutableArray *razredi;
    int changesLeft;
}
@property (weak, nonatomic) IBOutlet UIButton *changeSubFilter;
@property (weak, nonatomic) IBOutlet UIPickerView *changeFilter;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end


@implementation VDDDijakiFilterViewController

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    subFilter = (NSMutableArray *)[[VDDMetaData sharedMetaData] metaDataObjectForKey:@"podFilter"];
    if (subFilter == nil)
        subFilter = [[NSMutableArray alloc] init];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = ([paths count] > 0) ? paths[0] : nil;
    razredi = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/unfilteredPodatki", documentsPath]][@"razredi"];
    razredi = [[razredi sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
    
    
    NSNumber *changesLeftObject = (NSNumber *)[[VDDMetaData sharedMetaData] metaDataObjectForKey:@"numberOfChangesLeft"];
    changesLeft = [changesLeftObject intValue];
    
    
    _infoLabel.text = [NSString stringWithFormat:@"To šolsko leto si razred lahko spremeniš še %dx.", changesLeft];
    

    NSString *filter = (NSString *)[[VDDMetaData sharedMetaData] metaDataObjectForKey:@"filter"];
    if (![filter isEqualToString:@""])
        [_changeFilter selectRow:[razredi indexOfObject:filter] inComponent:0 animated:NO];
    
    
    NSString *currentFilter = razredi[[_changeFilter selectedRowInComponent:0]];
    if ([[currentFilter substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"3"] ||
         [[currentFilter substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"4"])
    {
        _changeSubFilter.hidden = NO;
    } else _changeSubFilter.hidden = YES;
}

#pragma mark - PickerView Delegeate

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

#pragma mark - Button Actions

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)changeSubFilterView:(id)sender {
    NSString *currentFilter = razredi[[_changeFilter selectedRowInComponent:0]];
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

- (IBAction)setFilter:(id)sender {
    changesLeft--;
    
    if (changesLeft < 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Napaka!"
                                                                       message:@"V tem šolskem letu si filter že spremenil 3x. Če si profesor vklopi profesorski način."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Vredu"
                                                 style:UIAlertActionStyleDefault
                                               handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"numberOfChangesLeft" toObject:@(changesLeft)];
    
    NSString *filter = razredi[[_changeFilter selectedRowInComponent:0]];
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
    
    [NSThread detachNewThreadSelector:@selector(filterEveyrthing) toTarget:self withObject:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Filtering

- (void)changeSubFilter:(NSMutableArray *)newSubFilter {
    subFilter = [newSubFilter copy];
}

- (void)filterEveyrthing {
    [[VDDSuplenceDataFetch sharedSuplenceDataFetch] filter];
    [[VDDUrnikDataFetch sharedUrnikDataFetch] filter];
    [[VDDHybridDataFetch sharedHybridDataFetch] refresh];
}

@end