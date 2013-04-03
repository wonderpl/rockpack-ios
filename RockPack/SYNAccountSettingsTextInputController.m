//
//  SYNAccountSettingsTextInputController.m
//  rockpack
//
//  Created by Michael Michailidis on 20/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAccountSettingsTextInputController.h"
#import <QuartzCore/QuartzCore.h>
#import "RegexKitLite.h"
#import "UIFont+SYNFont.h"

@interface SYNAccountSettingsTextInputController ()

@property (nonatomic) CGFloat lastTextFieldY;

@end

@implementation SYNAccountSettingsTextInputController

@synthesize inputField, saveButton, errorTextField;
@synthesize appDelegate;
@synthesize lastTextFieldY;
@synthesize spinner;

-(id)initWithUserFieldType:(UserFieldType)userFieldType
{
    if(self = [super init]) {
        
        currentFieldType = userFieldType;
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    saveButton.enabled = YES;
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
    [saveButton setImage:[UIImage imageNamed:@"ButtonAccountSaveHighlighted.png"] forState:UIControlStateDisabled];
    
    [self.view addSubview:saveButton];
	
    inputField = [self createInputField];
    
    switch (currentFieldType) {
            
        case UserFieldTypeFullname:
            self.inputField.text = [NSString stringWithFormat:@"%@ %@", appDelegate.currentUser.firstName, appDelegate.currentUser.lastName];
            self.inputField.leftViewMode = UITextFieldViewModeAlways;
            self.inputField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconFullname.png"]];
            break;
            
        case UserFieldTypeUsername:
            self.inputField.text = appDelegate.currentUser.username;
            self.inputField.leftViewMode = UITextFieldViewModeAlways;
            self.inputField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconUsername.png"]];
            break;
            
        case UserFieldTypeEmail:
            self.inputField.text = appDelegate.currentUser.emailAddress;
            self.inputField.leftViewMode = UITextFieldViewModeAlways;
            self.inputField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconEmail.png"]];
            break;
            
        default:
            break;
    }
    
    
    [self.view addSubview:inputField];
    
    self.spinner.center = self.saveButton.center;
    [self.view addSubview:self.spinner];
    
    
    
    [saveButton addTarget:self action:@selector(saveButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // navigation back button
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* backButtonImage = [UIImage imageNamed:@"ButtonAccountBackDefault.png"];
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(didTapBackButton:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0.0, 0.0, backButtonImage.size.width, backButtonImage.size.height);
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    
    errorTextField = [[UITextField alloc] initWithFrame:CGRectMake(10.0, saveButton.frame.origin.y + saveButton.frame.size.height + 10.0,
                                                                   self.contentSizeForViewInPopover.width - 10.0, 30)];
    
    errorTextField.textColor = [UIColor redColor];
    errorTextField.font = [UIFont rockpackFontOfSize:18];
    errorTextField.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:errorTextField];
    
    
}

- (void) didTapBackButton:(id)sender {
    if(self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
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
    saveButton.frame = CGRectIntegral(saveButtonFrame);
    
    CGRect errorTextFrame = errorTextField.frame;
    errorTextFrame.origin.y = saveButtonFrame.origin.y + saveButtonFrame.size.height + 10.0;
    errorTextField.frame = CGRectIntegral(errorTextFrame);
    
    lastTextFieldY += newInputField.frame.size.height + 10.0;
    
    return newInputField;
}

-(void)saveButtonPressed:(UIButton*)button
{
    
    self.saveButton.hidden = YES;
    [self.spinner startAnimating];
    
    if(![self formIsValid]) {
        self.errorTextField.text = @"You Have Entered Invalid Characters";
        return;
    }
    
    
}




#pragma mark - Validating

-(BOOL)formIsValid
{
    BOOL isMatched = NO;
    
    switch (currentFieldType) {
            
        case UserFieldTypeFullname: // only letters
            isMatched = [self.inputField.text isMatchedByRegex:@"^[a-zA-Z\\.]+$"];
            break;
            
        case UserFieldTypeUsername:
            isMatched = [self.inputField.text isMatchedByRegex:@"^[a-zA-Z0-9\\._]+$"];
            break;
            
        case UserFieldTypeEmail:
            isMatched = [self.inputField.text isMatchedByRegex:@"^([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})$"];
            break;
            
        case UserFieldPassword:
            isMatched = [self.inputField.text isMatchedByRegex:@"^[a-zA-Z0-9\\._]+$"];
            break;
    }
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)updateField:(NSString*)field forValue:(NSString*)newValue withCompletionHandler:(MKNKBasicSuccessBlock)successBlock
{
    self.saveButton.enabled = NO;
    
    [self.appDelegate.oAuthNetworkEngine changeUserField:field
                                                 forUser:self.appDelegate.currentUser
                                            withNewValue:newValue
                                       completionHandler:^ {
                                           
                                           [self.spinner stopAnimating];
                                           self.saveButton.hidden = NO;
                                           self.saveButton.enabled = YES;
                                           
                                           successBlock();
                                           
                                           [[NSNotificationCenter defaultCenter] postNotificationName:kUserDataChanged
                                                                                               object:self
                                                                                             userInfo:@{@"user":appDelegate.currentUser}];
                                           
                                           
                                           
                                       } errorHandler:^(id errorInfo) {
                                           
                                           
                                           
                                           if(!errorInfo || ![errorInfo isKindOfClass:[NSDictionary class]])
                                               return;
                                           
                                           NSString* message = [errorInfo objectForKey:@"message"];
                                           if(message) {
                                               if([message isKindOfClass:[NSArray class]]) {
                                                   self.errorTextField.text = (NSString*)[((NSArray*)message) objectAtIndex:0];
                                               } else if([message isKindOfClass:[NSString class]]) {
                                                   self.errorTextField.text = message;
                                               }
                                               
                                           }
                                           
                                           
                                           
                                       }];
    
    
    
}
@end
