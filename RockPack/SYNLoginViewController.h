//
//  SYNLoginViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 11/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    kLoginScreenStateNull = 0,
    kLoginScreenStateInitial,
    kLoginScreenStateLogin,
    kLoginScreenStateRegister,
} kLoginScreenState;

typedef enum {
    kFacebookStateNull = 0,
    kFacebookStateLogging,
    kFacebookStateRegistering,
} kFacebookState;

@interface SYNLoginViewController : UIViewController

@property (nonatomic) kLoginScreenState state;
@property (nonatomic) kFacebookState facebookState;

@end
