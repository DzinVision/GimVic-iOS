//
//  VDDSubPredmetiViewController.m
//  GimVic
//
//  Created by Vid Drobnič on 11/18/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import "VDDSubPredmetiViewController.h"
#import "VDDSubPredmetiCell.h"
#import "VDDMetaData.h"

@interface VDDSubPredmetiViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSString *class;
    NSArray *razredi;
    NSMutableArray *selected;
}
@end


@implementation VDDSubPredmetiViewController

#pragma mark - Initialization

- (instancetype)initWithSelectedRazreds:(NSMutableArray *)selectedRazreds class:(NSString *)razred {
    self = [super init];
    if (self) {
        class = razred;
        selected = [selectedRazreds mutableCopy];
        if (selected.count > 0) {
            for (int i = 0; i < selected.count; i++)
                selected[i] = [selected[i] uppercaseString];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    
    UIView *tabBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 60)];
    tabBar.backgroundColor = [UIColor colorWithRed:76/255.0 green:175/255.0 blue:80/255.0 alpha:1.0];
    [self.view addSubview:tabBar];
    
    UIButton *dismiss = [[UIButton alloc] init];
    [dismiss addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [dismiss setTitle:@"Vredu" forState:UIControlStateNormal];
    [dismiss setTitleColor:[UIColor colorWithRed:200/255.0 green:230/255.0 blue:201/255.0 alpha:1.0] forState:UIControlStateNormal];
    [dismiss sizeToFit];
    dismiss.frame = CGRectMake(self.view.bounds.size.width - 20 - dismiss.frame.size.width,
                               20,
                               dismiss.frame.size.width,
                               dismiss.frame.size.height);
    [self.view addSubview:dismiss];
    
    UILabel *dodatneNastavitveLabel = [[UILabel alloc] init];
    dodatneNastavitveLabel.text = @"Dodatne Nastavitve";
    dodatneNastavitveLabel.textColor = [UIColor colorWithRed:165/255.0 green:214/255.0 blue:167/255.0 alpha:1.0];
    [dodatneNastavitveLabel sizeToFit];
    dodatneNastavitveLabel.frame = CGRectMake(self.view.bounds.size.width / 2 - dodatneNastavitveLabel.frame.size.width / 2,
                                              20,
                                              dodatneNastavitveLabel.frame.size.width,
                                              30);
    dodatneNastavitveLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:dodatneNastavitveLabel];
    
    
    UITableView *dodatniPredmeti = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                                 60,
                                                                                 self.view.bounds.size.width,
                                                                                 self.view.bounds.size.height - 60)
                                                                style:UITableViewStylePlain];
    dodatniPredmeti.separatorColor = [UIColor colorWithRed:67/255.0 green:160/255.0 blue:71/255.0 alpha:1.0];
    dodatniPredmeti.dataSource = self;
    dodatniPredmeti.delegate = self;
    [self.view addSubview:dodatniPredmeti];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    razredi = [[[NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/unfilteredPodatki", documentsPath]] objectForKey:@"podRazredi"] objectForKey:class];
    
    if (selected == nil)
        selected = [[NSMutableArray alloc] init];
}

#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return razredi.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VDDSubPredmetiCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VDDSubPredmetiCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VDDSubPredmetiCell" owner:self options:nil];
        cell = nib[0];
        UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        selectedBackgroundView.backgroundColor = [UIColor colorWithRed:200/255.0 green:230/255.0 blue:201/255.0 alpha:1.0];
        cell.selectedBackgroundView = selectedBackgroundView;
        cell.tintColor = [UIColor colorWithRed:76/255.0 green:175/255.0 blue:80/255.0 alpha:1.0];
    }

    cell.predmet.text = razredi[indexPath.row];
    
    if ([selected containsObject:cell.predmet.text])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    VDDSubPredmetiCell *cell = (VDDSubPredmetiCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (![selected containsObject:cell.predmet.text]) {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        [selected addObject: cell.predmet.text];
    } else {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
        [selected removeObject:cell.predmet.text];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Button Actions

- (void)dismiss {
    if (selected.count > 0) {
        for (int i = 0; i < selected.count; i++) {
            selected[i] = [selected[i] stringByReplacingOccurrencesOfString:@" " withString:@""];
            selected[i] = [selected[i] lowercaseString];
        }
    }
    
    [self.delegate changeSubFilter:selected];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end