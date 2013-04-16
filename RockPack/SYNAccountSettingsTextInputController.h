//
//  SYNAccountSettingsTextInputController.h
//  rockpack
//
//  Created by Michael Michailidis on 20/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "GAITrackedViewController.h"
#import "SYNAppDelegate.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNPaddedUITextField.h"
#import <UIKit/UIKit.h>

typedef enum
{
    UserFieldTypeFullname = 0,
    UserFieldTypeUsername,
    UserFieldTypeEmail,
    UserFieldPassword
} UserFieldType;

@interface SYNAccountSettingsTextInputController : GAITrackedViewController
{
    UserFieldType currentFieldType;
}

@property (nonatomic, strong) SYNPaddedUITextField *inputField;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UITextField *errorTextField;
@property (nonatomic, strong) SYNAppDelegate *appDelegate;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;


- (id) initWithUserFieldType: (UserFieldType) userFieldType;

- (void) updateField: (NSString *) field
            forValue: (NSString *) newValue
            withCompletionHandler: (MKNKBasicSuccessBlock) successBlock;

- (SYNPaddedUITextField *) createInputField;
- (void) saveButtonPressed: (UIButton *) button;

- (BOOL) formIsValid;

@end
