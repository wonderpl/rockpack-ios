//
//  SYNFacebookManager.m
//  rockpack
//
//  Created by Nick Banks on 12/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNFacebookManager.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Friend.h"

typedef enum
{
    kFacebookPermissionTypeRead = 0,
    kFacebookPermissionTypePublish = 1
} PermissionType;


@interface SYNFacebookManager ()

@property (nonatomic, strong) NSArray *readPermissions;
@property (nonatomic, strong) NSArray *publishPermissions;

@property (atomic,assign) int outstandingLoginRequests;

@end


@implementation SYNFacebookManager

// Singleton
+ (id) sharedFBManager
{
    static dispatch_once_t onceQueue;
    static SYNFacebookManager *fBManager = nil;
    
    dispatch_once(&onceQueue, ^{fBManager = [[self alloc] init]; });
    return fBManager;
}

// Set up our permissions arrays (one for read, one for publish)

- (id) init
{
    if ((self = [super init]))
    {
        // Read and publish permissions must be requested separately in iOS 6,
        // so set appropriate permissions here
        self.readPermissions = @[@"email"];
        
        self.publishPermissions = @[@"publish_actions"];
    }
    
    return self;
}

// Log into Facebook (with read permissions)
// This is done is a couple of stages...
//
// 1. Check to see if we have an open session, and if not open one
// 2. Check to see if we have extended read permissions to allow us to get the user's email address
// 3. Once we have an email address, then call the suceess block, otherwise if anything else goes wrong
//    call the failure block

- (void) loginOnSuccess: (FacebookLoginSuccessBlock) successBlock
              onFailure: (FacebookLoginFailureBlock) failureBlock
{
    self.outstandingLoginRequests++;
    [self openSessionWithPermissionType: kFacebookPermissionTypeRead
                              onSuccess: ^{
                                  
                                  [FBRequestConnection startForMeWithCompletionHandler: ^(FBRequestConnection *connection,
                                                                                          NSDictionary < FBGraphUser > *userInfo,
                                                                                          NSError *error) {
                                      if (error) {
                                          // Graph query failed, so parse NSError userInfo to get description
                                          NSString *errorMessage = [self parsedErrorMessage: error];
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              self.outstandingLoginRequests--;
                                              if(self.outstandingLoginRequests<=0)
                                              {
                                                  //Only report error if the very last login attempt failed.
                                                  failureBlock(errorMessage);
                                              }
                                          });
                                      } else {
                                          
                                          
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              self.outstandingLoginRequests--;
                                              successBlock(userInfo);
                                          });
                                      }
                                  }];
                                  
                              }
                              onFailure: ^(NSString *errorMessage) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      self.outstandingLoginRequests--;
                                      if(self.outstandingLoginRequests<=0)
                                      {
                                          //Only report error if the very last login attempt failed.
                                          failureBlock(errorMessage);
                                          
                                      }
                                  });
                              }];
}

// Logout

- (void) logoutOnSuccess: (FacebookLogoutSuccessBlock) successBlock
               onFailure: (FacebookLogoutFailureBlock) failureBlock
{
    if (FBSession.activeSession.isOpen)
    {
        [FBSession.activeSession closeAndClearTokenInformation];
        dispatch_async(dispatch_get_main_queue(), ^{
            successBlock();
        });
    }
    else
    {
        // If we get here, then some sort of error has occurred
        dispatch_async(dispatch_get_main_queue(), ^{
            failureBlock(@"Session already open");
        });
    }
}

- (void) openSessionFromExistingToken: (NSString*)token
                            onSuccess: (FacebookOpenSessionSuccessBlock) successBlock
                            onFailure: (FacebookOpenSessionFailureBlock) failureBlock
{
    FBSession* session = [[FBSession alloc] initWithPermissions:self.publishPermissions];
    FBAccessTokenData* tokenData = [FBAccessTokenData createTokenFromString:token
                                                                permissions:self.publishPermissions
                                                             expirationDate:nil
                                                                  loginType:FBSessionLoginTypeNone
                                                                refreshDate:nil];
    
    [session openFromAccessTokenData:tokenData completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        if(!error)
        {
            if(session.isOpen)
            {
                [FBSession setActiveSession:session];
            }
            successBlock();
        }
        else
        {
            failureBlock([error description]);
        }
        
        
        
       NSLog(@"session = %@, status = %i, error = %@", session, status, error);
        
        
    }];
    
    
}

// Helper method to open a session if required
- (void) openSessionWithPermissionType: (PermissionType) permissionType
                             onSuccess: (FacebookOpenSessionSuccessBlock) successBlock
                             onFailure: (FacebookOpenSessionFailureBlock) failureBlock
{
    // Is the Facebook session already open, so execute our success block
    if ([FBSession.activeSession isOpen])
    {
        // Session is open, so we already have read permissions
        // Check to see if the caller requires extended publish permissions and we actually have any
        if (permissionType == kFacebookPermissionTypePublish  && self.publishPermissions.count > 0)
        {
            // Check to see that the publish permissions have been set by checking to see if the first publish permission has been set
            // if so, then all the other publish permissions will have been set
            if ([FBSession.activeSession.permissions indexOfObject: (self.publishPermissions)[0]] == NSNotFound)
            {
                
                // No, we don't already have extended publish permissions
                [FBSession.activeSession requestNewPublishPermissions: self.publishPermissions
                                                      defaultAudience: FBSessionDefaultAudienceEveryone
                                                    completionHandler: ^(FBSession *session, NSError *error)
                 {
                     // Permissission denied
                     if (error)
                     {
                         NSString *errorMessage = kFacebookPermissionDenied;
                         
                         DebugLog(@"** Reauthorize: Permission denied");
                         // Something went wrong or the user refused permission to access email address
                         dispatch_async(dispatch_get_main_queue(), ^{
                             failureBlock(errorMessage);
                         });
                     }
                     else
                     {
                         DebugLog(@"** Reauthorize: Suceeded");
                         // OK, the user has now granted required extended permissions
                         dispatch_async(dispatch_get_main_queue(), ^{
                             successBlock();
                         });
                     }
                 }];
            }
            else
            {
                DebugLog(@"** openSession: Permissions already granted");
                // We have already been granted the required extended permissions
                dispatch_async(dispatch_get_main_queue(), ^{
                    successBlock();
                });
            }
        }
        else
        {
            DebugLog(@"** openSession: Only read permissions requested");
            // Only read permissions were requested (which will already have been granted on openActiveSessionWithReadPermissions)
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock();
            });
        }
    }
    else
    {
        // Session not yet open, so open it with read permissions
        // We need to be very careful here as the completionHandler will be called
        // EVERY time the session state changes (not just on successful opening of
        // an active session
        
        __block BOOL hasExecuted = NO; // Keep track of whether the completion handler has been called.
        
        [FBSession openActiveSessionWithReadPermissions: self.readPermissions
                                           allowLoginUI: YES
                                      completionHandler: ^(FBSession *session,
                                                           FBSessionState status,
                                                           NSError *error) {
                                          
                                          NSString *errorMessage = nil;
                                          
                                          NSLog(@"%@", [session.accessTokenData dictionary]);
                                          
                                          //We only expect this completion handler to be called once. The FBSession seems to store it
                                          //and it gets called again on logout. the hasExecuted boolean flag prevents the block from being called unless it has been
                                          //recreated again during another login attempt.
                                          if(hasExecuted)
                                          {
                                              return;
                                          }
                                          else
                                          {
                                              hasExecuted = YES;
                                          }
                                          // Check to see if the user cancelled the log in
                                          if (status == FBSessionStateClosedLoginFailed)
                                          {
                                              DebugLog(@"++ openSession: Login cancelled");
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  failureBlock(kFacebookLoginCancelled);
                                              });
                                          }
                                          else
                                          {
                                              if (error)
                                              {
                                                  // Something went wrong, so parse NSError userInfo to get description
                                                  errorMessage = [self parsedErrorMessage: error];
                                                  DebugLog(@"++ openSession: Error:%@", errorMessage);
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      failureBlock(errorMessage);
                                                  });
                                              }
                                              else
                                              {
                                                  if (session.isOpen)
                                                  {
                                                      if (status == FBSessionStateOpen)
                                                      {
                                                          DebugLog(@"++ openSession: Calling recursive");
                                                          // Now here's the clever bit,
                                                          // Now we have an open session, call ourselves recursively
                                                          [self openSessionWithPermissionType: permissionType
                                                                                    onSuccess: successBlock
                                                                                    onFailure: failureBlock];
                                                      }
                                                      else
                                                      {
                                                          DebugLog(@"++ openSession: Other session state, not calling recursive");
                                                      }
                                                  }
                                                  else
                                                  {
                                                      DebugLog(@"++ openSession: Unknown error");
                                                      // For some reason, the session is not open
                                                      dispatch_async(dispatch_get_main_queue(), ^ {
                                                          failureBlock(kFacebookUnknownError);
                                                      });
                                                  }
                                              }
                                          }
                                      }];
    }
}


#pragma mark - Posting to Wall

- (void) postMessageToWall:(NSString*)message
                 onSuccess: (FacebookPostSuccessBlock) successBlock
                 onFailure: (FacebookPostFailureBlock) failureBlock
{
    
    if( ![FBSession.activeSession isOpen] || [[[FBSession activeSession] permissions]indexOfObject:@"publish_actions"] == NSNotFound)
    {
        // reopen session
        
        [self openSessionWithPermissionType: kFacebookPermissionTypeRead | kFacebookPermissionTypePublish
                                  onSuccess: ^{
                                      [self postMessageToWall: message
                                                    onSuccess: successBlock
                                                    onFailure: failureBlock];
                                  }
                                  onFailure: ^(NSString* errorMessage) {
                                      
                                  }];
        
        return;
        
    }
    
    NSDictionary* postParams = @{@"caption" : @"First Post",
                                 @"message" : message,
                                 @"description" : message};
    
    [FBRequestConnection startWithGraphPath: @"me/feed"
                                 parameters: postParams
                                 HTTPMethod: @"POST"
                          completionHandler: ^(FBRequestConnection *connection, id result, NSError *error) {
                              if (error)
                              {
                                  failureBlock(error);
                                  return;
                              }
                              
                              successBlock();
                          }];
}



// Helper method to extract a user readable string from an NSError returned by a Facebook API call
- (NSString *) parsedErrorMessage: (NSError *) facebookError
{
    NSDictionary *outerDict = (NSMutableDictionary *) [facebookError userInfo];
    NSDictionary *parsedJSONResponseKey = [outerDict isKindOfClass: [NSDictionary class]] ? outerDict[@"com.facebook.sdk:ParsedJSONResponseKey"] : nil;
    NSDictionary *body = [parsedJSONResponseKey isKindOfClass: [NSDictionary class]] ? parsedJSONResponseKey[@"body"] : nil;
    NSDictionary *error = [body isKindOfClass: [NSDictionary class]] ? body[@"error"] : nil;
    NSString *message = error[@"message"];
    
    NSString *errorMessage = @"Unknown error";
    
    if (message)
    {
        // Remove the pesky error code from the front (if it's there)
        NSRange range = [message rangeOfString: message];
        
        // RegEx to detect '(nnn) '
        message = [message stringByReplacingOccurrencesOfString: @"\\(#[0-9]+\\)\\s"
                                                     withString: @""
                                                        options: NSRegularExpressionSearch
                                                          range: range];
        errorMessage = message;
    }
    
    return [NSString stringWithFormat: NSLocalizedString(@"Facebook\n\n%@", nil), errorMessage];
}

- (void) sendAppRequestToFriend:(Friend*)friend
                      onSuccess:(FacebookPostSuccessBlock) successBlock
                      onFailure:(FacebookPostFailureBlock) failureBlock
{
    if(!friend || !self.hasOpenSession)
        return;
    
    NSDictionary* params = nil;
    if(friend.externalUID && ![friend.externalUID isEqualToString:@""])
        params = @{@"to":friend.externalUID};
    else
        params = nil;
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:@"Join me on Rockpack for iPhone & iPad"
                                                    title:@"Invite Friend"
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      
                                                      
                                                      if (error) {
                                                          // Case A: Error launching the dialog or sending request.
                                                          NSLog(@"Error sending request.");
                                                          failureBlock(error);
                                                          
                                                          
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // Case B: User clicked the "x" icon
                                                              NSLog(@"User canceled request.");
                                                          } else {
                                                              NSLog(@"Request Sent.");
                                                              successBlock();
                                                          }
                                                      }}];
}

-(BOOL)hasOpenSession
{
    return [[FBSession activeSession] isOpen];
}

@end
