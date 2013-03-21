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
    
    saveButton.center = CGPointMake(saveButton.center.x, saveButton.center.y + lastTextFieldY);
    
    lastTextFieldY += newInputField.frame.size.height + 10.0;
    
    return newInputField;
}

-(void)saveButtonPressed:(UIButton*)button
{
    switch (currentFieldType) {
            
        case UserFieldTypeFirstName:
            appDelegate.currentUser.firstName = inputField.text;
            break;
            
        case UserFieldTypeLastName:
            appDelegate.currentUser.lastName = inputField.text;
            break;
            
        case UserFieldTypeEmail:
            appDelegate.currentUser.emailAddress = inputField.text;
            break;
            
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
