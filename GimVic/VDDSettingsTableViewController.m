//
//  VDDSettingsTableViewController.m
//  GimVic
//
//  Created by Vid Drobnič on 11/27/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import "VDDSettingsTableViewController.h"
#import "VDDMetaData.h"
#import "VDDRootViewController.h"
#import "VDDTutorialViewController.h"
#import "VDDCrypto.h"

@interface VDDSettingsTableViewController ()

#pragma mark - Variable Creation

{
    BOOL isUcitelj;
}
@property (weak, nonatomic) IBOutlet UITableViewCell *filterCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *uciteljModeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *redoIntroCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *aboutCell;

@property (weak, nonatomic) IBOutlet UISwitch *uciteljModeSwitch;

@end


@implementation VDDSettingsTableViewController

#pragma mark - Variable Synthesizing

@synthesize filterCell, uciteljModeCell, redoIntroCell, aboutCell, uciteljModeSwitch;

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:filterCell.frame];
    selectedBackgroundView.backgroundColor = [UIColor colorWithRed:200/255.0 green:230/255.0 blue:201/255.0 alpha:1.0];
    
    filterCell.selectedBackgroundView = selectedBackgroundView;
    uciteljModeCell.selectedBackgroundView = selectedBackgroundView;
    redoIntroCell.selectedBackgroundView = selectedBackgroundView;
    aboutCell.selectedBackgroundView = selectedBackgroundView;
    
    uciteljModeCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    NSNumber *isUciteljNumber = (NSNumber *)[[VDDMetaData sharedMetaData] metaDataObjectForKey:@"uciteljskiNacin"];
    isUcitelj = [isUciteljNumber boolValue];
    
    [uciteljModeSwitch setOn:isUcitelj animated:NO];
}

#pragma mark - Ucitelj Mode

- (IBAction)uciteljModeChanged:(id)sender {
    if (isUcitelj) {
        isUcitelj = NO;
        [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"uciteljskiNacin" toObject:[NSNumber numberWithBool:NO]];
        [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"filter" toObject:@""];
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Geslo"
                                                                   message:@"Za Učiteljski način potrebujete vpisati geslo, ki ste ga prejeli na začetku leta."
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.secureTextEntry = YES;
        textField.placeholder = @"Geslo";
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"Nastavi"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action){
                                                UITextField *passwordTextField = alert.textFields[0];
                                                NSString *password = [VDDCrypto sha256hashFor:passwordTextField.text];
                                                if ([password isEqualToString:[VDDRootViewController sharedRootViewController].profPassword]) {
                                                    isUcitelj = YES;
                                                    [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"uciteljskiNacin"
                                                                                                       toObject:[NSNumber numberWithBool:YES]];
                                                } else {
                                                    UIAlertController *incorrectPasswordAlert =
                                                    [UIAlertController alertControllerWithTitle:@"Napačno Geslo!"
                                                                                        message:@"Geslo, ki ste ga vpisali je napačno, poskusite znova."
                                                                                 preferredStyle:UIAlertControllerStyleAlert];
                                                    
                                                    [incorrectPasswordAlert addAction:[UIAlertAction actionWithTitle:@"Vredu"
                                                                                                               style:UIAlertActionStyleDefault
                                                                                                             handler:nil]];
                                                    [self presentViewController:incorrectPasswordAlert animated:YES completion:nil];
                                                    [uciteljModeSwitch setOn:NO animated:YES];
                                                }
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Prekliči"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction *handler){
                                                [uciteljModeSwitch setOn:NO animated:YES];
                                            }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        if (isUcitelj) [self performSegueWithIdentifier:@"showProfFilter" sender:self];
        else [self performSegueWithIdentifier:@"showDijakiFilter" sender:self];
    }
    if (indexPath.row == 2) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        VDDTutorialViewController *tutorialVC = [[VDDTutorialViewController alloc] init];
        tutorialVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:tutorialVC animated:YES completion:nil];
    }
}

@end