//
//  VDDOpombaUrnikCell.h
//  GimVic
//
//  Created by Vid Drobnič on 11/22/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VDDOpombaUrnikCell : UITableViewCell

#pragma mark - Variables

@property (weak, nonatomic) IBOutlet UILabel *ura;
@property (weak, nonatomic) IBOutlet UILabel *predmet;
@property (weak, nonatomic) IBOutlet UILabel *ucitelj;
@property (weak, nonatomic) IBOutlet UILabel *ucilnica;
@property (weak, nonatomic) IBOutlet UILabel *opomba;

@end