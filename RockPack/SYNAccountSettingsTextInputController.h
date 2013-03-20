//
//  SYNAccountSettingsTextInputController.h
//  rockpack
//
//  Created by Michael Michailidis on 20/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    
    UserFieldTypeFirstName = 0,
    UserFieldTypeLastName,
    UserFieldTypeEmail
    
} UserFieldType;

@interface SYNAccountSettingsTextInputController : UIViewController {
    UserFieldType currentFieldType;
}
-(id)initWithUserFieldType:(UserFieldType)userFieldType;
@end
