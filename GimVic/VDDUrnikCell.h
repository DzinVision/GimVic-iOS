//
//  VDDUrnikCell.h
//  GimVic
//
//  Created by Vid Drobnič on 11/09/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VDDUrnikCell : UITableViewCell

#pragma mark - Variables

@property (weak, nonatomic) IBOutlet UILabel *ura;
@property (weak, nonatomic) IBOutlet UILabel *predmet;
@property (weak, nonatomic) IBOutlet UILabel *ucitelj;
@property (weak, nonatomic) IBOutlet UILabel *ucilnica;

@end