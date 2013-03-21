//
//  SYNAccountSettingsTextInputController.m
//  rockpack
//
//  Created by Michael Michailidis on 20/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAccountSettingsTextInputController.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNAccountSettingsTextInputController ()

@property (nonatomic) CGFloat lastTextFieldY;

@end

@implementation SYNAccountSettingsTextInputController

@synthesize inputField, saveButton;
@synthesize appDelegate;
@synthesize lastTextFieldY;

-(id)initWithUserFieldType:(UserFieldType)userFieldType
{
    if(self = [super init]) {
        
        currentFieldType = userFieldType;
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contentSizeForViewInPopover = CGSizeMake(380, 476);
    
    self.view.backgroundColor = [UIColor clearColor];
    
    lastTextFieldY = 10.0;
    
    CGRect buttonRect = CGRectMake(10.0, 10.0, self.contentSizeForViewInPopover.width - 10.0, 40.0);
    saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveButton.frame = buttonRect;
    [saveButton setImage:[UIImage imageNamed:@"ButtonAccountSaveDefault.png"] forState:UIControlStateNormal];
    [saveButton setImage:[UIImage imageNamed:@"ButtonAccountSaveHighlighted.png"] forState:UIControlStateHighlighted];
    [self.view addSubview:saveButton];
	
    inputField = [self createInputField];
    
    switch (currentFieldType) {
            
        case UserFieldTypeFullname:
            self.inputField.leftViewMode = UITextFieldViewModeAlways;
            self.inputField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconFullname.png"]];
            break;
            
        case UserFieldTypeUsername:
            self.inputField.leftViewMode = UITextFieldViewModeAlways;
            self.inputField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconUsername.png"]];
            break;
            
        case UserFieldTypeEmail:
            self.inputField.leftViewMode = UITextFieldViewModeAlways;
            self.inputField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconEmail.png"]];
            break;
            
        default:
            break;
    }
    
    
    [self.view addSubview:inputField];
    
    
    
    [saveButton addTarget:self action:@selector(saveButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

-(SYNPaddedUITextField*)createInputField
{
    
    
    
    
    SYNPaddedUITextField* newInputField = [[SYNPaddedUITextField alloc] initWithFrame:CGRectMake(10.0,
                                                                                                 lastTextFieldY,
                                                                                                 self.contentSizeForViewInPopover.width - 10.0,
                                                                                                 40.0)];
    
    
                           
                           
    newInputField.backgroundColor = [UIColor whiteColor];
    newInputField.layer.cornerRadius = 5.0f;
    
    CGRect saveButtonFrame = saveButton.frame;
    saveButtonFrame.origin.y = newInputField.frame.origin.y + newInputField.frame.size.height + 10.0;
    saveButton.frame = saveButtonFrame;
    
    lastTextFieldY += newInputField.frame.size.height + 10.0;
    
    return newInputField;
}

-(void)saveButtonPressed:(UIButton*)button
{
    
    
    if(![self formIsValid]) {
        // show error;
    }
    
    NSArray* componentsOfInput = nil;
    
    switch (currentFieldType) {
            
        case UserFieldTypeFullname:
            
            componentsOfInput = [inputField.text componentsSeparatedByString:@" "];
            // have already checked for validity
            appDelegate.currentUser.firstName = componentsOfInput[0];
            appDelegate.currentUser.lastName = componentsOfInput[componentsOfInput.count - 1];
            
            break;
            
        case UserFieldTypeUsername:
            appDelegate.currentUser.username = inputField.text;
            break;
            
        case UserFieldTypeEmail:
            appDelegate.currentUser.emailAddress = inputField.text;
            break;
            
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(BOOL)formIsValid
{
    switch (currentFieldType) {
            
        case UserFieldTypeFullname:
            
            break;
            
        case UserFieldTypeUsername:
            
            break;
            
        case UserFieldTypeEmail:
            
            break;
            
    }
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
