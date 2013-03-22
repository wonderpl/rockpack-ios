//
//  SYNAccountSettingsTextInputController.h
//  rockpack
//
//  Created by Michael Michailidis on 20/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SYNAppDelegate.h"

#import "SYNPaddedUITextField.h"

typedef enum {
    
    UserFieldTypeFullname = 0,
    UserFieldTypeUsername,
    UserFieldTypeEmail
    
} UserFieldType;

@interface SYNAccountSettingsTextInputController : UIViewController {
    UserFieldType currentFieldType;
}

@property (nonatomic, strong) SYNPaddedUITextField* inputField;
@property (nonatomic, strong) UIButton* saveButton;
@property (nonatomic, strong) UITextField* errorTextField;
@property (nonatomic, strong) SYNAppDelegate* appDelegate;


-(id)initWithUserFieldType:(UserFieldType)userFieldType;
-(SYNPaddedUITextField*)createInputField;
@end
