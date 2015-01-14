//
//  VDDProfesorPasswordViewController.m
//  GimVic
//
//  Created by Vid Drobnič on 11/24/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import "VDDProfesorPasswordViewController.h"
#import "VDDRootViewController.h"
#import "VDDMetaData.h"
#import "VDDCrypto.h"

@interface VDDProfesorPasswordViewController ()
{
    NSString *password;
}
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end


@implementation VDDProfesorPasswordViewController

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];

    password = @"";
}

#pragma mark - Button Actions

- (IBAction)okButtonPressed:(id)sender {
    password = [VDDCrypto sha256hashFor:_passwordField.text];
    if ([password isEqualToString:[VDDRootViewController sharedRootViewController].profPassword]) {
        [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"uciteljskiNacin" toObject:[NSNumber numberWithBool:YES]];
        [self performSegueWithIdentifier:@"pushToSettingsSeque" sender:self];
        return;
    }
    
    
    UIAlertController *wrongPassword = [UIAlertController alertControllerWithTitle:@"Napačno Geslo!"
                                                                           message:@"Geslo ki ste ga vpisali je napačno. Prosim poskuite znova." preferredStyle:UIAlertControllerStyleAlert];
    [wrongPassword addAction:[UIAlertAction actionWithTitle:@"Vredu"
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil]];
    
    [self presentViewController:wrongPassword animated:YES completion:nil];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"uciteljskiNacin" toObject:[NSNumber numberWithBool:NO]];
}

- (IBAction)editingDidEnd:(id)sender {
    [_passwordField resignFirstResponder];
}

@end