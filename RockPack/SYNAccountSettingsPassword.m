//
//  SYNAccountSettingsPassword.m
//  rockpack
//
//  Created by Michael Michailidis on 21/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAccountSettingsPassword.h"

@interface SYNAccountSettingsPassword ()

@property (nonatomic, strong) UITextField* passwordField;
@property (nonatomic, strong) UITextField* passwordConfirmField;

@end

@implementation SYNAccountSettingsPassword

@synthesize passwordConfirmField, passwordField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.inputField.text = @"";
    self.inputField.placeholder = @"Old Password";
    
    passwordField = [self createInputField];
    passwordField.placeholder = @"New Password";
    passwordField.secureTextEntry = YES;
    [self.view addSubview:passwordField];
    
    passwordConfirmField = [self createInputField];
    passwordConfirmField.secureTextEntry = YES;
    passwordConfirmField.placeholder = @"Confirm Password";
    [self.view addSubview:passwordConfirmField];
	
}


-(void)saveButtonPressed:(UIButton*)button
{
    
    [super saveButtonPressed:button];
    
    if(![self formIsValid]) {
        self.errorTextField.text = @"You Have Entered Invalid Characters";
        return;
    }
    
    if(![passwordField.text isEqualToString:passwordConfirmField.text]) {
        self.errorTextField.text = @"Passwords do not match";
        return;
        
    }
    
    [self updateField:@"password" forValue:self.inputField.text withCompletionHandler:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
