//
//  VDDMenjavaUcilnicCell.h
//  GimVic
//
//  Created by Vid Drobnič on 09/26/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VDDMenjavaUcilnicCell : UITableViewCell

#pragma mark - Variables

@property (weak, nonatomic) IBOutlet UILabel *ucilnicaFrom;
@property (weak, nonatomic) IBOutlet UILabel *ucilnicaTo;
@property (weak, nonatomic) IBOutlet UILabel *predmet;
@property (weak, nonatomic) IBOutlet UILabel *ucitelj;
@property (weak, nonatomic) IBOutlet UILabel *razred;
@property (weak, nonatomic) IBOutlet UILabel *opomba;
@property (weak, nonatomic) IBOutlet UILabel *ura;

@end