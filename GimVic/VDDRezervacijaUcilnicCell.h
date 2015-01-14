//
//  VDDRezervacijaUcilnicCell.h
//  GimVic
//
//  Created by Vid Drobnič on 09/29/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VDDRezervacijaUcilnicCell : UITableViewCell

#pragma mark - Variables

@property (weak, nonatomic) IBOutlet UILabel *ucilnica;
@property (weak, nonatomic) IBOutlet UILabel *rezervator;
@property (weak, nonatomic) IBOutlet UILabel *ura;
@property (weak, nonatomic) IBOutlet UILabel *opomba;

@end