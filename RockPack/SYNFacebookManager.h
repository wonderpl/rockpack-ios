//
//  SYNFacebookManager.h
//  rockpack
//
//  Created by Nick Banks on 12/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FBGraphUser;
@class Friend;

// Localizable error messages

#define kFacebookLoginCancelled     NSLocalizedString(@"Log in cancelled, or permission denied.  Check Facebook settings", nil)
#define kFacebookPermissionDenied   NSLocalizedString(@"Permission denied", nil)
#define kFacebookUnknownError       NSLocalizedString(@"Unknown error, nil", nil)

// Block typedefs

typedef void (^FacebookOpenSessionSuccessBlock)(void);
typedef void (^FacebookOpenSessionFailureBlock)(NSString *errorMessage);

typedef void (^FacebookLoginSuccessBlock)(NSDictionary<FBGraphUser> *userInfo);
typedef void (^FacebookLoginFailureBlock)(NSString *errorMessage);

typedef void (^FacebookLogoutSuccessBlock)(void);
typedef void (^FacebookLogoutFailureBlock)(NSString *errorMessage);

typedef void (^FacebookPostSuccessBlock)(void);
typedef void (^FacebookPostFailureBlock)(NSError *error);

@interface SYNFacebookManager : NSObject

+ (id) sharedFBManager;

- (void) loginOnSuccess: (FacebookLoginSuccessBlock) successBlock
              onFailure: (FacebookLoginFailureBlock) failureBlock;

- (void) logoutOnSuccess: (FacebookLogoutSuccessBlock) successBlock
               onFailure: (FacebookLogoutFailureBlock) failureBlock;

- (void) postMessageToWall: (NSString*)message
                 onSuccess: (FacebookPostSuccessBlock) successBlock
                 onFailure: (FacebookPostFailureBlock) failureBlock;

-(BOOL) hasOpenSession;

- (void) sendAppRequestToFriend:(Friend*)friend
                        onSuccess:(FacebookPostSuccessBlock) successBlock
                        onFailure:(FacebookPostFailureBlock) failureBlock;

@end
