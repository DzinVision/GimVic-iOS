//
//  VDDUrnikCell.m
//  GimVic
//
//  Created by Vid Drobnič on 11/09/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import "VDDUrnikCell.h"

@implementation VDDUrnikCell

#pragma mark - Initialization

- (void)awakeFromNib {
    _predmet.numberOfLines = 1;
    _predmet.minimumScaleFactor = -0.8;
    _predmet.adjustsFontSizeToFitWidth = YES;
    
    _ura.numberOfLines = 1;
    _ura.minimumScaleFactor = -0.8;
    _ura.adjustsFontSizeToFitWidth = YES;
    
    _ucitelj.numberOfLines = 1;
    _ucitelj.minimumScaleFactor = -0.8;
    _ucitelj.adjustsFontSizeToFitWidth = YES;
    
    _ucilnica.numberOfLines = 1;
    _ucilnica.minimumScaleFactor = -0.8;
    _ucilnica.adjustsFontSizeToFitWidth = YES;
}

@end