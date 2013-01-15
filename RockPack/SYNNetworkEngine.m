//
//  SYNNetworkEngine.m
//  rockpack
//
//  Created by Nick Banks on 10/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNNetworkEngine.h"
#import "AppConstants.h"

@interface SYNNetworkEngine ()

@property (nonatomic, strong) NSString *localeString;

@end

@implementation SYNNetworkEngine

- (id) initWithDefaultSettings
{
    
    if ((self = [super initWithHostName: kAPIHostName
                     customHeaderFields: @{@"x-client-identifier" : @"Rockpack iPad client"}]))
    {
        // Set our local string (i.e. en_GB, en_US or fr_FR)
        self.localeString =   [NSLocale.autoupdatingCurrentLocale objectForKey: NSLocaleIdentifier];
    }

    return self;
}


- (void) JSONObjectForPath: (NSString *) path
           completionBlock: (JSONResponseBlock) completionBlock
                errorBlock: (MKNKErrorBlock) errorBlock
{
    // Append additional parameters
//    path = [NSString stringWithFormat: @"%@?%@", path, self.localeString];
    
    NSDictionary *headerFields = @{@"grant_type" : @"password",
                                   @"username" : @"ios",
                                   @"password" : @"password"};
    
    MKNetworkOperation *networkOperation = [self operationWithPath: path];
    
    [networkOperation addCompletionHandler: ^(MKNetworkOperation *completedOperation)
    {
        [completedOperation responseJSONWithCompletionHandler: ^(id jsonObject)
        {
          completionBlock(jsonObject);
        }];
    }
    errorHandler: ^(MKNetworkOperation *errorOp, NSError* error)
    {
        errorBlock(error);
    }];
    
    [self enqueueOperation: networkOperation];
}


- (void) JSONObjectForRecentlyAddedVideoInSubscribedChannelsForUser: (NSString *) userId
                                                    completionBlock: (JSONResponseBlock) completionBlock
                                                         errorBlock: (MKNKErrorBlock) errorBlock
{
    NSString *path = [NSString stringWithFormat: kAPIRecentlyAddedVideoInSubscribedChannelsForUser, userId];
                      
    [self JSONObjectForPath: path
            completionBlock: completionBlock
                 errorBlock: errorBlock];
}

//- (void) JSONObjectForRecentlyAddedVideoInSubscribedChannelsForUser: (NSString *) userId
//                                                    completionBlock: (JSONResponseBlock) completionBlock
//                                                         errorBlock: (MKNKErrorBlock) errorBlock
//{
//    NSString *path = [NSString stringWithFormat: kAPIRecentlyAddedVideoInSubscribedChannelsForUser, userId];
//    
//    [self JSONObjectForPath: path
//            completionBlock: completionBlock
//                 errorBlock: errorBlock];
//}

@end
