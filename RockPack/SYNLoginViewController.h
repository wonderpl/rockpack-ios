//
//  SYNLoginViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 11/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//


#import "GKImagePicker.h"
#import <UIKit/UIKit.h>
#import "SYNOAuth2Credential.h"
#import "SYNAppDelegate.h"
#import "SYNLoginBaseViewController.h"


@interface SYNLoginViewController : SYNLoginBaseViewController

@property (nonatomic) BOOL facebookLoginIsInProcess;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* activityIndicator;

@property (nonatomic, strong) IBOutlet UIButton* passwordForgottenButton;

@property (nonatomic, strong) IBOutlet UIImage* avatarImage;

-(void)showAutologinWithCredentials:(SYNOAuth2Credential*)credentials;

- (void) showImagePicker: (UIImagePickerControllerSourceType) sourceType;



@end
