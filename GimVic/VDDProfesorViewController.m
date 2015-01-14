//
//  VDDProfesorViewController.m
//  GimVic
//
//  Created by Vid Drobnič on 11/24/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import "VDDProfesorViewController.h"
#import "VDDMetaData.h"
#import "VDDRootViewController.h"
#import "VDDSuplenceDataFetch.h"
#import "VDDUrnikDataFetch.h"
#import "VDDHybridDataFetch.h"

@interface VDDProfesorViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
{
    int currentRubric;
    NSMutableArray *data;
}
@property (weak, nonatomic) IBOutlet UISegmentedControl *rubricChanger;
@property (weak, nonatomic) IBOutlet UIPickerView *changeFilter;

@end


@implementation VDDProfesorViewController

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentRubric = (int)_rubricChanger.selectedSegmentIndex;
    [self setData];
}

- (void)setData {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    
    if (currentRubric == 0) {
        NSMutableArray *profesorji = [[NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/unfilteredPodatki", documentsPath]]
                                      objectForKey:@"ucitelji"];
        data = [[profesorji sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
        return;
    }
    
    if (currentRubric == 1) {
        NSMutableArray *razredi = [[NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/unfilteredPodatki", documentsPath]]
                                   objectForKey:@"razredi"];

        NSDictionary *podRazredi = [[NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/unfilteredPodatki", documentsPath]]
                                      objectForKey:@"podRazredi"];
        
        NSArray *podRazredi3 = [podRazredi valueForKey:@"3"];
        NSArray *podRazredi4 = [podRazredi valueForKey:@"4"];

        for (NSString *razred in podRazredi3)
            [razredi addObject:razred];
        
        for (NSString *razred in podRazredi4)
            [razredi addObject:razred];
        
        data = [[razredi sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
        return;
    }
    
    if (currentRubric == 2) {
        NSMutableArray *ucilnice = [[NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/unfilteredPodatki", documentsPath]]
                                    objectForKey:@"ucilnice"];
        data = [[ucilnice sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
    }
}

#pragma mark - PickerViewController Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return data.count;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title = data[row];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title
                                                                    attributes:@{NSForegroundColorAttributeName:
                                                                                     [UIColor colorWithRed:200/255.0 green:230/255.0 blue:201/255.0 alpha:1.0]
                                                                                 }];
    return attString;
}

#pragma mark - Filtering

- (IBAction)setFilter:(id)sender {
    NSString *filter = data[[_changeFilter selectedRowInComponent:0]];
    filter = [filter stringByReplacingOccurrencesOfString:@" " withString:@""];
    filter = filter.lowercaseString;
    [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"filter" toObject:filter];
    
    [NSThread detachNewThreadSelector:@selector(filterEverything) toTarget:self withObject:nil];
    
    [[VDDRootViewController sharedRootViewController] changeToHybridWithTutorial];
}

- (void)filterEverything {
    [[VDDSuplenceDataFetch sharedSuplenceDataFetch] filter];
    [[VDDUrnikDataFetch sharedUrnikDataFetch] filter];
    [[VDDHybridDataFetch sharedHybridDataFetch] refresh];
}

- (IBAction)rubricChanged:(id)sender {
    currentRubric = (int)_rubricChanger.selectedSegmentIndex;
    [self setData];
    [_changeFilter reloadAllComponents];
}

#pragma mark - Button Actions

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end