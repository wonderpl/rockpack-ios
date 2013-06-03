//
//  SYNLoginBaseViewController.h
//  rockpack
//
//  Created by Mats Trovik on 14/05/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "GAITrackedViewController.h"
#import "Reachability.h"
#import "SYNAppDelegate.h"
#import "SYNImagePickerController.h"
#import "SYNNetworkErrorView.h"
#import "SYNNetworkOperationJsonObject.h"
#import "SYNOAuth2Credential.h"


#define kLoginTermsUrl @"http://www.rockpack.com/tos"
#define kLoginPrivacyUrl @"http://rockpack.com/privacy"

typedef enum {
    kLoginScreenStateNull = 0,
    kLoginScreenStateInitial,
    kLoginScreenStateLogin,
    kLoginScreenStateRegister,
    kLoginScreenStatePasswordRetrieve,
    kLoginScreenStateRegisterStepTwo
} kLoginScreenState;


@interface SYNLoginBaseViewController : GAITrackedViewController

@property (nonatomic, assign) kLoginScreenState state;
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, strong) SYNImagePickerController* imagePicker;
@property (nonatomic, strong) SYNNetworkErrorView* networkErrorView;
@property (nonatomic,assign) SYNAppDelegate* appDelegate;


- (BOOL) checkAndSaveRegisteredUser: (SYNOAuth2Credential*) credential;

- (void) loginForUsername: (NSString*) username
              forPassword: (NSString*) password
        completionHandler: (MKNKUserSuccessBlock) completionBlock
             errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) doRequestPasswordResetForUsername: (NSString*) username
                         completionHandler: (MKNKJSONCompleteBlock) completionBlock
                              errorHandler: (MKNKErrorBlock) errorBlock;

- (void) registerUserWithData: (NSDictionary*) userData
            completionHandler: (MKNKUserSuccessBlock) completionBlock
                 errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) uploadAvatarImage: (UIImage *) image
         completionHandler: (MKNKUserSuccessBlock) completionBlock
              errorHandler: (MKNKUserErrorBlock) errorBlock;

-(void) loginThroughFacebookWithCompletionHandler:(MKNKJSONCompleteBlock) completionBlock
                                     errorHandler: (MKNKUserErrorBlock) errorBlock;


- (void) setUpInitialState;

- (BOOL) isNetworkAccessibleOtherwiseShowErrorAlert;

- (void) doFacebookLoginAnimation;

@end
