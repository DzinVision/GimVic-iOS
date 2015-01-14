//
//  VDDNadomescanjaCell.h
//  GimVic
//
//  Created by Vid Drobnič on 09/14/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VDDNadomescanjaCell : UITableViewCell

#pragma mark - Variables

@property (weak, nonatomic) IBOutlet UILabel *odsoten;
@property (weak, nonatomic) IBOutlet UILabel *nadomesca;
@property (weak, nonatomic) IBOutlet UILabel *ucilnica;
@property (weak, nonatomic) IBOutlet UILabel *predmet;
@property (weak, nonatomic) IBOutlet UILabel *opomba;
@property (weak, nonatomic) IBOutlet UILabel *ura;
@property (weak, nonatomic) IBOutlet UILabel *razred;

@end