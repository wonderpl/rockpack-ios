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
    kLoginScreenStateFacebookLogin
} kLoginScreenState;

@interface SYNLoginViewController : UIViewController

@property (nonatomic) kLoginScreenState state;

@end
