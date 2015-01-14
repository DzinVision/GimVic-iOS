//
//  VDDMenjavaUrCell.h
//  GimVic
//
//  Created by Vid Drobnič on 09/22/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VDDMenjavaUrCell : UITableViewCell

#pragma mark - Variables

@property (weak, nonatomic) IBOutlet UILabel *profFrom;
@property (weak, nonatomic) IBOutlet UILabel *profTo;
@property (weak, nonatomic) IBOutlet UILabel *predmetFrom;
@property (weak, nonatomic) IBOutlet UILabel *predmetTo;
@property (weak, nonatomic) IBOutlet UILabel *ucilnica;
@property (weak, nonatomic) IBOutlet UILabel *ura;
@property (weak, nonatomic) IBOutlet UILabel *razred;
@property (weak, nonatomic) IBOutlet UILabel *opomba;

@end