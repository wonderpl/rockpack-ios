//
//  SYNLoginBaseViewController.h
//  rockpack
//
//  Created by Mats Trovik on 14/05/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "GAITrackedViewController.h"
#import "Reachability.h"
#import "SYNAppDelegate.h"
#import "SYNImagePickerController.h"
#import "SYNNetworkErrorView.h"
#import "SYNNetworkOperationJsonObject.h"

#import "SYNLoginOnBoardingController.h"
#import "SYNOAuth2Credential.h"


#define kLoginTermsUrl @"http://rockpack.com/tos"
#define kLoginPrivacyUrl @"http://rockpack.com/privacy"

typedef enum {
    kLoginScreenStateNull = 0,
    kLoginScreenStateInitial,
    kLoginScreenStateLogin,
    kLoginScreenStateRegister,
    kLoginScreenStatePasswordRetrieve,
    kLoginScreenStateRegisterStepTwo
} kLoginScreenState;


@interface SYNLoginBaseViewController : GAITrackedViewController <UIScrollViewDelegate>

@property (nonatomic, assign) kLoginScreenState state;
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, strong) SYNImagePickerController* imagePicker;
@property (nonatomic, strong) SYNNetworkErrorView* networkErrorView;
@property (nonatomic,assign) SYNAppDelegate* appDelegate;
@property (nonatomic) NSInteger currentOnBoardingPage;
@property (nonatomic, strong) IBOutlet UIImageView* loginBackgroundImage;

@property (nonatomic, strong) SYNLoginOnBoardingController* onBoardingController;

- (BOOL) checkAndSaveRegisteredUser: (SYNOAuth2Credential*) credential;

- (void) loginForUsername: (NSString*) username
              forPassword: (NSString*) password
        completionHandler: (MKNKUserSuccessBlock) completionBlock
             errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) doRequestPasswordResetForUsername: (NSString*) username
                         completionHandler: (MKNKJSONCompleteBlock) completionBlock
                              errorHandler: (MKNKErrorBlock) errorBlock;

- (void) doRequestUsernameAvailabilityForUsername: (NSString*) username
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

-(void)reEnableLoginControls;

- (BOOL) isNetworkAccessibleOtherwiseShowErrorAlert;

- (void) doFacebookLoginAnimation;

// Form validation

-(BOOL) registrationFormPartOneIsValidForUserName:(UITextField*)userNameInputField;

- (BOOL) registrationFormIsValidForEmail:(UITextField*)emailInputField userName:(UITextField*)userNameInputField password:(UITextField*)passwordInputField dd:(UITextField*)ddInputField mm:(UITextField*)mmInputField yyyy:(UITextField*)yyyyInputField;

-(BOOL)dateValidForDd:(UITextField*)ddInputField mm:(UITextField*)mmInputField yyyy:(UITextField*)yyyyInputField;

- (BOOL) loginFormIsValidForUsername:(UITextField*)userNameInputField password:(UITextField*)passwordInputField;

- (BOOL) resetPasswordFormIsValidForUsername:(UITextField*)userNameInputField;

- (void) placeErrorLabel: (NSString*) errorText
              nextToView: (UIView*) view;

-(NSString*)zeroPadIfOneCharacter:(NSString*)inputString;

// Additional reachability enablig for resume from background scenario
-(void)checkReachability;

@end
