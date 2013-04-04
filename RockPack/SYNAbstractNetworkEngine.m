//
//  SYNAbstractNetworkEngine.m
//  rockpack
//
//  Created by Nick Banks on 18/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAbstractNetworkEngine.h"
#import "SYNAppDelegate.h"
#import "SYNNetworkOperationJsonObjectParse.h"
#import "SYNAppDelegate.h"
#import "User.h"

@implementation SYNAbstractNetworkEngine
@synthesize hostName;

- (id) initWithDefaultSettings
{
    
    if ((self = [super initWithHostName: self.hostName
                     customHeaderFields: @{@"x-client-identifier" : @"Rockpack iPad client"}]))
    {
        
        SYNAppDelegate* appDelegate = UIApplication.sharedApplication.delegate;
        
        
        
        
        // Cache registries
        self.registry = appDelegate.mainRegistry;
        self.searchRegistry = appDelegate.searchRegistry;
        
        // This engine is about requesting JSON objects and uses the appropriate operation type
        [self registerOperationSubclass: [SYNNetworkOperationJsonObject class]];
        
        
        // We should register here for locale changes
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(localeDidChange)
                                                     name: NSCurrentLocaleDidChangeNotification
                                                   object: nil];
    }
    
    return self;
}




- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: NSCurrentLocaleDidChangeNotification
                                                  object: nil];
}

-(NSString*)localeString
{
    
    SYNAppDelegate* appDelegate = UIApplication.sharedApplication.delegate;
    
    // Set our local string (i.e. en_GB, en_US or fr_FR)
    NSString* localeFromDevice = [(NSString*)CFBridgingRelease(CFLocaleCreateCanonicalLanguageIdentifierFromString(NULL, (CFStringRef)[NSLocale.autoupdatingCurrentLocale objectForKey: NSLocaleIdentifier])) lowercaseString];
    
    if(appDelegate.currentUser) {
        return appDelegate.currentUser.locale;
    } else {
        return localeFromDevice;
    }
    
    
}

// If the locale changes, then we need to reset the CoreData DB
- (void) localeDidChange
{
    //SYNAppDelegate* appDelegate = UIApplication.sharedApplication.delegate;
    //    [appDelegate resetCoreDataStack];
}

- (NSString *) hostName
{
    AssertOrLog(@"Should not be calling abstract host name method");
    return nil;
}

#pragma mark - Common functionality

// This code block is common to all of the signup/signin methods
- (void) addCommonHandlerToNetworkOperation:  (SYNNetworkOperationJsonObject *) networkOperation
                          completionHandler: (MKNKUserSuccessBlock) completionBlock
                               errorHandler: (MKNKUserErrorBlock) errorBlock
{
    // First, copy the network operation so that if authentication fails we can try again
    SYNNetworkOperationJsonObject *retryNetworkOperation = [networkOperation mutableCopy];
    
    // Set the callback logic for our standard network operation 
    [networkOperation addJSONCompletionHandler: ^(id response)
     {
         // Check to see if our response is a NSDictionary and if it has an error hash
         if ([response isKindOfClass: [NSDictionary class]] && ((NSDictionary *)response[@"error"] != nil))
         {
             DebugLog(@"API Call failed: %@", response);
             
             // Now check to see if we need to refresh the token
             NSDictionary *responseDictionary = (NSDictionary *) response;
             NSString *reason = responseDictionary[@"error"];
             if ([reason isEqualToString: @"expired_token"] == FALSE)
             {
                 // Normal (?) error, we don't need to try refreshing the token
                 errorBlock(response);
             }
             else
             {
                 // OK, out OAuth2 token has expired, so refresh and try again
                 DebugLog (@"Token expired");
                 
                 [self refreshOAuthTokenWithCompletionHandler: ^(id response)
                  {
                      DebugLog (@"Refreshed");
                      // Now we have a new authentication token, we need to try the network operation again
                      // Set the callback logic for the network operation re-issued if the authentication token has expired and been renewed
                      [retryNetworkOperation addJSONCompletionHandler: ^(id response)
                       {
                           // Check to see if our response is a NSDictionary and if it has an error hash
                           if ([response isKindOfClass: [NSDictionary class]] && ((NSDictionary *)response[@"error"] != nil))
                           {
                               DebugLog(@"API Call failed: %@", response);
                               
                               // Now check to see if we need to refresh the token
                               NSDictionary *responseDictionary = (NSDictionary *) response;
                               NSString *reason = responseDictionary[@"error"];
                               if ([reason isEqualToString: @"expired_token"] == FALSE)
                               {
                                   // Normal (?) error, we don't need to try refreshing the token
                                   errorBlock(response);
                               }
                               else
                               {
                                   // The OAuth2 token is still invalid, even after a refresh - so bail
                                   DebugLog (@"refreshed token not valid");
                                   errorBlock(response);
                               }
                               
                           }
                           else
                           {
                               // OK, all seems to have gone well, return the object
                               completionBlock(response);
                           }
                       }
                       errorHandler: ^(id response)
                       {
                           if ([response isKindOfClass: [NSError class]])
                           {
                               NSError *responseErrror = (NSError *) response;
                               NSDictionary* customErrorDictionary = @{@"network_error" : [NSString stringWithFormat: @"%@, Server responded with %i", responseErrror.domain, responseErrror.code]};
                               DebugLog(@"API Call failed: %@", customErrorDictionary);
                               errorBlock(customErrorDictionary);
                           }
                           else if ([response isKindOfClass: [NSDictionary class]] && ((NSDictionary *)response[@"error"] != nil))
                           {
                               DebugLog(@"API Call failed: %@", response);
                               errorBlock(response);
                           }
                           else
                           {
                               // No idea what has been passed back, so try to do the least worst thing...
                               errorBlock(nil);
                           }
                       }];
                      
                      [self enqueueSignedOperation: retryNetworkOperation];
                  }
                  errorHandler:  ^(id response)
                  {
                      DebugLog (@"Failed to Refresh");
                      errorBlock(response);
                  }];
             }
             
         }
         else
         {
             // TODO: Remove test code
             // Simulate failure, buy refreshing token and sending API call again
             // OK, all seems to have gone well, return the object
             completionBlock(response);
         }
     }
     errorHandler: ^(id response)
     {
         if ([response isKindOfClass: [NSError class]])
         {
             NSError *responseErrror = (NSError *) response;
             NSDictionary* customErrorDictionary = @{@"network_error" : [NSString stringWithFormat: @"%@, Server responded with %i", responseErrror.domain, responseErrror.code]};
             DebugLog(@"API Call failed: %@", customErrorDictionary);
             errorBlock(customErrorDictionary);
         }
         else if ([response isKindOfClass: [NSDictionary class]] && ((NSDictionary *)response[@"error"] != nil))
         {
             DebugLog(@"API Call failed: %@", response);
             errorBlock(response);
         }
         else
         {
             // No idea what has been passed back, so try to do the least worst thing...
             errorBlock(nil);
         }
     }];
}

- (void) enqueueSignedOperation: (MKNetworkOperation *) request
{
    NSLog (@"Called abstract function - unexpected");
}

- (IBAction) refreshOAuthTokenWithCompletionHandler: (MKNKUserErrorBlock) completionBlock
                                       errorHandler: (MKNKUserSuccessBlock) errorBlock
{
    NSLog (@"Called abstract function - unexpected");
}


- (NSDictionary *) paramsAndLocaleForStart: (int) start
                                      size: (int) size
{
    NSDictionary *params = nil;
    
    if (size == 0)
    {
        params = @{@"locale" : self.localeString};
    }
    else
    {
        params = @{@"locale" : self.localeString, @"start" : @(start), @"size" : @(size)};
    }

    return params;
}

- (NSDictionary *) paramsForStart: (int) start
                             size: (int) size
{
    NSDictionary *params = nil;
    
    if (size > 0)
    {
        params = @{@"start" : @(start), @"size" : @(size)};
    }
    
    return params;
}



#pragma mark - Utility Methods

-(NSDictionary*)getLocalParam
{
    return [NSDictionary dictionaryWithObject:self.localeString forKey:@"locale"];
}

-(NSDictionary*)getLocalParamWithParams:(NSDictionary*)parameters
{
    
    NSMutableDictionary* dictionaryWithLocale = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [dictionaryWithLocale addEntriesFromDictionary:[self getLocalParam]];
    return dictionaryWithLocale;
}

@end
