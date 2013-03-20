//
//  SYNAccountSettingsTextInputController.m
//  rockpack
//
//  Created by Michael Michailidis on 20/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAccountSettingsTextInputController.h"
#import "SYNAppDelegate.h"

@interface SYNAccountSettingsTextInputController ()

@property (nonatomic, strong) UITextField* inputField;
@property (nonatomic, strong) UIButton* saveButton;
@property (nonatomic, strong) SYNAppDelegate* appDelegate;

@end

@implementation SYNAccountSettingsTextInputController

@synthesize inputField, saveButton;
@synthesize appDelegate;

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
	
    inputField = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 80.0)];
    inputField.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:inputField];
    
    CGRect buttonRect = CGRectMake(0.0, 100.0, 300.0, 50.0);
    saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    saveButton.frame = buttonRect;
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [self.view addSubview:saveButton];
    
    [saveButton addTarget:self action:@selector(saveButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
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
