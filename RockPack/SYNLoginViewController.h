//
//  SYNLoginViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 11/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "GKImagePicker.h"

typedef enum {
    kLoginScreenStateNull = 0,
    kLoginScreenStateInitial,
    kLoginScreenStateLogin,
    kLoginScreenStateRegister
} kLoginScreenState;



@interface SYNLoginViewController : UIViewController <UIPopoverControllerDelegate, GKImagePickerDelegate>

@property (nonatomic) kLoginScreenState state;
@property (nonatomic) BOOL facebookLoginIsInProcess;

-(void)showAutologinWithCredentials:(SYNOAuth2Credential*)credentials;

-(void)setUpInitialState;

@end
