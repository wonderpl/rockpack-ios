//
//  SYNLoginViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 11/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//


#import "GAITrackedViewController.h"
#import "GKImagePicker.h"
#import <UIKit/UIKit.h>

typedef enum {
    kLoginScreenStateNull = 0,
    kLoginScreenStateInitial,
    kLoginScreenStateLogin,
    kLoginScreenStateRegister,
    kLoginScreenStatePasswordRetrieve
} kLoginScreenState;



@interface SYNLoginViewController : GAITrackedViewController <UIPopoverControllerDelegate, GKImagePickerDelegate>

@property (nonatomic) kLoginScreenState state;
@property (nonatomic) BOOL facebookLoginIsInProcess;

-(void)showAutologinWithCredentials:(SYNOAuth2Credential*)credentials;

-(void)setUpInitialState;



-(IBAction)registerPressed:(id)sender;
-(IBAction)signUp:(id)sender;
-(IBAction)faceButtonImagePressed:(UIButton*)sender;
-(IBAction)forgottenPasswordPressed:(id)sender;
-(IBAction)registerNewUser:(id)sender;
-(IBAction)goToLoginForm:(id)sender;
-(IBAction)signInWithFacebook:(id)sender;
-(IBAction)sendEmailButtonPressed:(id)sender;
- (IBAction) doLogin: (id) sender;

@end
