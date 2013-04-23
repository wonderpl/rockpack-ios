//
//  SYNSubscriptionsManager.m
//  rockpack
//
//  Created by Michael Michailidis on 23/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSubscriptionsManager.h"
#import "SYNAppDelegate.h"
#import "SYNOAuthNetworkEngine.h"
#import "AppConstants.h"


@interface SYNSubscriptionsManager()

@property (nonatomic, weak) SYNAppDelegate* appDelegate;

@end

@implementation SYNSubscriptionsManager

@synthesize appDelegate;


-(id)init
{
    if (self = [super init])
    {
        
        self.appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(channelSubscribeRequest:)
                                                     name:kChannelSubscribeRequest
                                                   object:nil];
        
        
        
    }
    return self;
}


+(id)manager
{
    return [[self alloc] init];
}

-(void)channelSubscribeRequest:(NSNotification*)notification
{
    Channel* channelToSubscribe = (Channel*)[[notification userInfo] objectForKey:kChannel];
    if(!channelToSubscribe)
        return;
    
    [self toggleSubscriptionToChannel:channelToSubscribe];
}

-(void)toggleSubscriptionToChannel:(Channel*)channel
{
    
    if (channel.subscribedByUserValue == YES)
    {
        [self unsubscribeFromChannel:channel];
    }
    else
    {
        [self subscribeToChannel:channel];
    }
    
    
    
    
    
}
-(void)subscribeToChannel:(Channel*)channel
{
    
    
    [appDelegate.oAuthNetworkEngine channelSubscribeForUserId: appDelegate.currentOAuth2Credentials.userId
                                                   channelURL: channel.resourceURL
                                            completionHandler: ^(NSDictionary *responseDictionary) {
                                                
                                                
                                                DebugLog(@"Subscribe action successful");
                                                
                                                channel.subscribedByUserValue = TRUE;
                                                channel.subscribersCountValue += 1;
                                                
                                                [channel addSubscribersObject:appDelegate.currentUser];
                                                
                                                [appDelegate saveContext:YES];
                                                
                                            } errorHandler: ^(NSDictionary* errorDictionary) {
                                                
                                                
                                                DebugLog(@"Subscribe action failed");
                                            }];
    
    
    
    
}
-(void)unsubscribeFromChannel:(Channel*)channel
{
    
    
    [appDelegate.oAuthNetworkEngine channelUnsubscribeForUserId: appDelegate.currentOAuth2Credentials.userId
                                                      channelId: channel.uniqueId
                                              completionHandler: ^(NSDictionary *responseDictionary) {
                                                  
                                                  DebugLog(@"Unsubscribe action successful");
                                                  
                                                  channel.subscribedByUserValue = NO;
                                                  channel.subscribersCountValue -= 1;
                                                  
                                                  [channel removeSubscribersObject:appDelegate.currentUser];
                                                  
                                                  [appDelegate saveContext:YES];
                                                  
                                                } errorHandler: ^(NSDictionary* errorDictionary) {
                                                    
                                                       DebugLog(@"Unsubscribe action failed");
                                                    
                                                    
                                                }];
    
    
}


@end
