//
//  DZNDetailViewController.m
//  GimVic
//
//  Created by Vid Drobnič on 21/05/14.
//  Copyright (c) 2014 Vid Drobnic. All rights reserved.
//

#import "DZNDetailViewController.h"

@interface DZNDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (strong, nonatomic) NSArray *content;

@end


@implementation DZNDetailViewController

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *headers = @[@"Nadomeščanja", @"Menjava Predmeta", @"Menjava Ur", @"Menjava Učilnic", @"Rezervacija Učilnic", @"Več Učiteljev v Razredu"];
    self.navigationBar.topItem.title = headers[_cellIndex];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView
numberOfRowsInSection:(NSInteger)section
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSDateFormatter *dFormatter = [[NSDateFormatter alloc] init];
    dFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *date = [dFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:24*3600*_pageIndex]];
    NSDictionary *content = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/organised-%@", documentsPath, date]];
    
    
    switch (_cellIndex) {
        case 0:
            _content = [content valueForKey:@"nadomescanja"];
            return [[content valueForKey:@"nadomescanja"] count];
            break;
            
        case 1:
            _content = [content valueForKey:@"menjavaPredmeta"];
            return [[content valueForKey:@"menjavaPredmeta"] count];
            break;
            
        case 2:
            _content = [content valueForKey:@"menjavaUr"];
            return [[content valueForKey:@"menjavaUr"] count];
            break;
            
        case 3:
            _content = [content valueForKey:@"menjavaUcilnic"];
            return [[content valueForKey:@"menjavaUcilnic"] count];
            break;
            
        case 4:
            _content = [content valueForKey:@"rezervacijaUcilnic"];
            return [[content valueForKey:@"rezervacijaUcilnic"] count];
            break;
        
        case 5:
            _content = [content valueForKey:@"vecUciteljevVRazredu"];
            return [[content valueForKey:@"vecUciteljevVRazredu"] count];
            break;
            
        default:
            return 0;
            break;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DZNDetailCellIdentifier" forIndexPath:indexPath];
    cell.textLabel.numberOfLines = 10;
    
    switch (_cellIndex) {
        case 0:
            cell.textLabel.text = [NSString stringWithFormat:@"Odsoten: %@\nUra: %@\nRazred: %@\nUčilnica: %@\nNadomešča: %@\nPredmet: %@\nOpomba: %@", [_content[indexPath.row] valueForKey:@"odsoten"],
                                   [_content[indexPath.row] valueForKey:@"ura"],
                                   [_content[indexPath.row] valueForKey:@"razred"],
                                   [_content[indexPath.row] valueForKey:@"ucilnica"],
                                   [_content[indexPath.row] valueForKey:@"nadomesca"],
                                   [_content[indexPath.row] valueForKey:@"predmet"],
                                   [_content[indexPath.row] valueForKey:@"opomba"]];
            break;
            
        case 1:
            cell.textLabel.text = [NSString stringWithFormat:@"Ura: %@\nRazred %@\nUčilnica: %@\nUčitelj: %@\nPrvotni predmet: %@\nNov Predmet: %@\nOpomba: %@", [_content[indexPath.row] valueForKey:@"ura"],
                                   [_content[indexPath.row] valueForKey:@"razred"],
                                   [_content[indexPath.row] valueForKey:@"ucilnica"],
                                   [_content[indexPath.row] valueForKey:@"ucitelj"],
                                   [_content[indexPath.row] valueForKey:@"originalPredmet"],
                                   [_content[indexPath.row] valueForKey:@"newPredmet"],
                                   [_content[indexPath.row] valueForKey:@"opomba"]];
            break;
            
        case 2:
            cell.textLabel.text = [NSString stringWithFormat:@"Razred: %@\nUra: %@\nZamenjava Učiteljev: %@\nZamenjava Predmetov: %@\nUčilnica: %@\nOpomba: %@", [_content[indexPath.row] valueForKey:@"razred"],
                                   [_content[indexPath.row] valueForKey:@"ura"],
                                   [_content[indexPath.row] valueForKey:@"zamenjavaProf"],
                                   [_content[indexPath.row] valueForKey:@"predmet"],
                                   [_content[indexPath.row] valueForKey:@"ucilnica"],
                                   [_content[indexPath.row] valueForKey:@"opomba"]];
            break;
            
        case 3:
            cell.textLabel.text = [NSString stringWithFormat:@"Razred: %@\nUra: %@\nUčitelj: %@\nPredmet: %@\nIz učilnice: %@\nV učilnico: %@\nOpomba: %@", [_content[indexPath.row] valueForKey:@"razred"],
                                   [_content[indexPath.row] valueForKey:@"ura"],
                                   [_content[indexPath.row] valueForKey:@"ucitelj"],
                                   [_content[indexPath.row] valueForKey:@"predmet"],
                                   [_content[indexPath.row] valueForKey:@"ucilnicaFrom"],
                                   [_content[indexPath.row] valueForKey:@"ucilnicaTo"],
                                   [_content[indexPath.row] valueForKey:@"opomba"]];
            break;
            
        case 4:
            cell.textLabel.text = [NSString stringWithFormat:@"Ura: %@\nUčilnica: %@\nRezervator: %@\nOpomba: %@", [_content[indexPath.row] valueForKey:@"ura"],
                                   [_content[indexPath.row] valueForKey:@"ucilnica"],
                                   [_content[indexPath.row] valueForKey:@"rezervator"],
                                   [_content[indexPath.row] valueForKey:@"opomba"]];
            break;
            
        case 5:
            cell.textLabel.text = [NSString stringWithFormat:@"Ura: %@\nUčitelj: %@\nRazred: %@\nUčilnica: %@\nOpomba: %@", [_content[indexPath.row] valueForKey:@"ura"],
                                   [_content[indexPath.row] valueForKey:@"ucitelj"],
                                   [_content[indexPath.row] valueForKey:@"razred"],
                                   [_content[indexPath.row] valueForKey:@"ucilnica"],
                                   [_content[indexPath.row] valueForKey:@"opomba"]];
            break;
            
        default:
            break;
    }
    
    return cell;
}

@end