//
//  DZNDaysViewController.m
//  GimVic
//
//  Created by Vid Drobnič on 18/05/14.
//  Copyright (c) 2014 Vid Drobnic. All rights reserved.
//

#import "DZNDaysViewController.h"
#import "DZNRefresh.h"
#import "Reachability.h"
#import "DZNDetailViewController.h"
#import "DZNImageViewController.h"

@interface DZNDaysViewController ()

@property (nonatomic) int nadomescanjaNum;
@property (nonatomic) int menjavaPredmetaNum;
@property (nonatomic) int menjavaUrNum;
@property (nonatomic) int menjavaUcilnicNum;
@property (nonatomic) int rezervacijaUcilnicNum;
@property (nonatomic) int vecUciteljevRazreduNum;

@property (weak, nonatomic) IBOutlet UILabel *sideLabel0;
@property (weak, nonatomic) IBOutlet UILabel *sideLabel1;
@property (weak, nonatomic) IBOutlet UILabel *sideLabel2;
@property (weak, nonatomic) IBOutlet UILabel *sideLabel3;
@property (weak, nonatomic) IBOutlet UILabel *sideLabel4;
@property (weak, nonatomic) IBOutlet UILabel *sideLabel5;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end


@implementation DZNDaysViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:NSCalendarUnitWeekday fromDate:[NSDate dateWithTimeIntervalSinceNow:24*3600*_pageIndex]];
    int weekday = [comps weekday];
    weekday--;
    
    NSArray *days = @[@"Nedelja", @"Ponedeljek", @"Torek", @"Sreda", @"Četrtek", @"Petek", @"Sobota"];
    self.navigationController.navigationBar.topItem.title = days[weekday];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [self contentRefresh];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentRefresh)
                                                 name:@"DZNRefreshComplete" object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)refresh
{
    DZNRefresh *refresh = [[DZNRefresh alloc] init];
    
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (status == NotReachable) {
        [self.refreshControl endRefreshing];
    }
    else if (status == ReachableViaWiFi) {
        [NSThread detachNewThreadSelector:@selector(downloadNewContent) toTarget:refresh withObject:nil];
    }
    else if (status == ReachableViaWWAN) {
        [NSThread detachNewThreadSelector:@selector(downloadNewContent) toTarget:refresh withObject:nil];
    }
}

-(void)contentRefresh
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSDateFormatter *dFormatter = [[NSDateFormatter alloc] init];
    dFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *date = [dFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:24*3600*_pageIndex]];
    NSDictionary *content = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/organised-%@", documentsPath, date]];
    
    _nadomescanjaNum = [[content valueForKey:@"nadomescanja"] count];
    _menjavaPredmetaNum = [[content valueForKey:@"menjavaPredmeta"] count];
    _menjavaUrNum = [[content valueForKey:@"menjavaUr"] count];
    _menjavaUcilnicNum = [[content valueForKey:@"menjavaUcilnic"] count];
    _rezervacijaUcilnicNum = [[content valueForKey:@"rezervacijaUcilnic"] count];
    _vecUciteljevRazreduNum = [[content valueForKey:@"vecUciteljevVRazredu"] count];
    
    _sideLabel0.text = [NSString stringWithFormat:@"%d", _nadomescanjaNum];
    _sideLabel1.text = [NSString stringWithFormat:@"%d", _menjavaPredmetaNum];
    _sideLabel2.text = [NSString stringWithFormat:@"%d", _menjavaUrNum];
    _sideLabel3.text = [NSString stringWithFormat:@"%d", _menjavaUcilnicNum];
    _sideLabel4.text = [NSString stringWithFormat:@"%d", _rezervacijaUcilnicNum];
    _sideLabel5.text = [NSString stringWithFormat:@"%d", _vecUciteljevRazreduNum];
    
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

-(void)checkmark:(NSInteger)cellIndex
{
    DZNImageViewController *imageView = [self.storyboard instantiateViewControllerWithIdentifier:@"imageView"];
    imageView.imageName = @"checkmark.png";
    NSArray *titles = @[@"Nadomeščanja", @"Menjava Predmeta", @"Menjava Ur", @"Menjava Učilnic", @"Rezervacija Učilnic", @"Več Učiteljev v Razredu"];
    imageView.barTitle = titles[cellIndex];
    [self presentViewController:imageView animated:YES completion:nil];
}

-(void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSDateFormatter *dFormatter = [[NSDateFormatter alloc] init];
    dFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *date = [dFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:24*3600*_pageIndex]];
    NSDictionary *content = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/organised-%@", documentsPath, date]];
    
    
    if ((indexPath.row == 0) && ([[content valueForKeyPath:@"nadomescanja"] count] == 0)) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [self checkmark:indexPath.row];
    }
    else if ((indexPath.row == 1) && ([[content valueForKeyPath:@"menjavaPredmeta"] count] == 0)) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [self checkmark:indexPath.row];
    }
    else if ((indexPath.row == 2) && ([[content valueForKeyPath:@"menjavaUr"] count] == 0)) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [self checkmark:indexPath.row];
    }
    else if ((indexPath.row == 3) && ([[content valueForKeyPath:@"menjavaUcilnic"] count] == 0)) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [self checkmark:indexPath.row];
    }
    else if ((indexPath.row == 4) && ([[content valueForKeyPath:@"rezervacijaUcilnic"] count] == 0)) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [self checkmark:indexPath.row];
    }
    else if ((indexPath.row == 5) && ([[content valueForKeyPath:@"vecUciteljevVRazredu"] count] == 0)) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [self checkmark:indexPath.row];
    }
    
    else {
        DZNDetailViewController *detailView = [self.storyboard instantiateViewControllerWithIdentifier:@"detailViewController"];
        detailView.cellIndex = indexPath.row;
        detailView.pageIndex = _pageIndex;
    
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self presentViewController:detailView animated:YES completion:nil];
    }
}

@end
