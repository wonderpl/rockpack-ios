//
//  SYNSubscriptionsManager.m
//  rockpack
//
//  Created by Michael Michailidis on 23/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNChannelManager.h"
#import "SYNAppDelegate.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNNetworkEngine.h"
#import "AppConstants.h"


@interface SYNChannelManager()

@property (nonatomic, weak) SYNAppDelegate* appDelegate;

@end

@implementation SYNChannelManager

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(channelUpdateRequest:)
                                                     name:kChannelUpdateRequest
                                                   object:nil];
        
        
        
    }
    return self;
}


+(id)manager
{
    return [[self alloc] init];
}

#pragma mark - Notification Handlers

-(void)channelSubscribeRequest:(NSNotification*)notification
{
    Channel* channelToSubscribe = (Channel*)[[notification userInfo] objectForKey:kChannel];
    if(!channelToSubscribe)
        return;
    
    [self toggleSubscriptionToChannel:channelToSubscribe];
}

-(void)channelUpdateRequest:(NSNotification*)notification
{
    Channel* channelToUpdate = (Channel*)[[notification userInfo] objectForKey:kChannel];
    if(!channelToUpdate)
        return;
    
    [self updateChannel:channelToUpdate];
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

-(void)updateChannel:(Channel*)channel
{
    if (channel.resourceURL != nil && ![channel.resourceURL isEqualToString: @""])
    {
        if ([channel.resourceURL hasPrefix: @"https"])
        {
            [appDelegate.oAuthNetworkEngine updateChannel: channel.resourceURL
                                        completionHandler: ^(NSDictionary *responseDictionary) {
                                            // Save the position for back-patching in later
                                            NSNumber *savedPosition = channel.position;
                                            
                                            [channel setAttributesFromDictionary: responseDictionary
                                                                          withId: channel.uniqueId
                                                       usingManagedObjectContext: appDelegate.mainManagedObjectContext
                                                             ignoringObjectTypes: kIgnoreNothing
                                                                       andViewId: kChannelDetailsViewId];
                                            
                                            // Back-patch a few things that may have been overwritten
                                            channel.position = savedPosition;
                                            channel.viewId = kChannelsViewId;
                                            
                                            
                                            
                                        } errorHandler: ^(NSDictionary* errorDictionary) {
                                                 DebugLog(@"Update action failed");
                                             }];
            
        }
        else
        {
            [appDelegate.networkEngine updateChannel: channel.resourceURL
                                   completionHandler: ^(NSDictionary *responseDictionary) {
                                       // Save the position for back-patching in later
                                       NSNumber *savedPosition = channel.position;
                                       
                                       [channel setAttributesFromDictionary: responseDictionary
                                                                     withId: channel.uniqueId
                                                  usingManagedObjectContext: appDelegate.mainManagedObjectContext
                                                        ignoringObjectTypes: kIgnoreNothing
                                                                  andViewId: kChannelDetailsViewId];
                                       
                                       // Back-patch a few things that may have been overwritten
                                       channel.position = savedPosition;
                                       channel.viewId = kChannelsViewId;
                                       
                                       if([channel.managedObjectContext hasChanges])
                                       {
                                           NSError* error;
                                           [channel.managedObjectContext save:&error];
                                           
                                       }
                                       
                                        } errorHandler: ^(NSDictionary* errorDictionary) {
                                            DebugLog(@"Update action failed");
                                        }];
        }
    }
}





@end
