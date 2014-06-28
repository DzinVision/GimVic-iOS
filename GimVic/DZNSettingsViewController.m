//
//  DZNSettingsViewController.m
//  GimVic
//
//  Created by Vid Drobnič on 20/05/14.
//  Copyright (c) 2014 Vid Drobnic. All rights reserved.
//

#import "DZNSettingsViewController.h"
#import "DZNRefresh.h"

@interface DZNSettingsViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end


@implementation DZNSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(save:)];
    [self.view addGestureRecognizer:tap];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSString *filter = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/filter", documentsPath]
                                                 encoding:NSUTF8StringEncoding
                                                    error:nil];
    
    _textField.text = filter;
    
    _textField.delegate = self;
}

- (IBAction)save:(id)sender {
    [_textField resignFirstResponder];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSString *filterInput = _textField.text;
    [filterInput writeToFile:[NSString stringWithFormat:@"%@/filter", documentsPath]
                  atomically:YES
                    encoding:NSUTF8StringEncoding
                       error:nil];
    DZNRefresh *refresh = [[DZNRefresh alloc] init];
    [refresh sortContent];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self save:textField];
    return YES;
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
