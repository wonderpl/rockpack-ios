//
//  SYNChannelManager.m
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(channelOwnerUpdateRequest:)
                                                     name:kChannelOwnerUpdateRequest
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(channelDeleteRequest:)
                                                     name:kChannelDeleteRequest
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
    
    // toggle subscription from/to channel //
    if (channelToSubscribe.subscribedByUserValue == YES)
    {
        [self unsubscribeFromChannel:channelToSubscribe];
    }
    else
    {
        [self subscribeToChannel:channelToSubscribe];
    }
}

// update another user's profuile channels //

-(void)channelOwnerUpdateRequest:(NSNotification*)notification
{
    ChannelOwner* channelOwner = (ChannelOwner*)[[notification userInfo] objectForKey:kChannelOwner];
    if(!channelOwner)
        return;
    
    [self updateChannelsForChannelOwner:channelOwner];
}

-(void)channelUpdateRequest:(NSNotification*)notification
{
    Channel* channelToUpdate = (Channel*)[[notification userInfo] objectForKey:kChannel];
    
    if(!channelToUpdate)
        return;
    
    [self updateChannel:channelToUpdate withForceRefresh:channelToUpdate.hasChangedSubscribeValue];
}

-(void)channelDeleteRequest:(NSNotification*)notification
{
    Channel* channelToUpdate = (Channel*)[[notification userInfo] objectForKey:kChannel];
    if(!channelToUpdate)
        return;
    
    [self deleteChannel:channelToUpdate];
}


#pragma mark - Implementation Methods

-(void)subscribeToChannel:(Channel*)channel
{
    
    
    [appDelegate.oAuthNetworkEngine channelSubscribeForUserId: appDelegate.currentOAuth2Credentials.userId
                                                   channelURL: channel.resourceURL
                                            completionHandler: ^(NSDictionary *responseDictionary) {
                                                
                                                
                                                
                                                channel.hasChangedSubscribeValue = YES;
                                                
                                                [appDelegate.currentUser addSubscriptionsObject:channel];
                                                
                                                if(channel.managedObjectContext == appDelegate.mainManagedObjectContext)
                                                {
                                                    [appDelegate saveContext:YES];
                                                }
                                                else if (channel.managedObjectContext == appDelegate.searchManagedObjectContext)
                                                {
                                                    [appDelegate saveSearchContext];
                                                }
                                                
                                                
                                            } errorHandler: ^(NSDictionary* errorDictionary) {
                                                
                                                // so that the observer will pick up the change and stop the activity indicator
                                                channel.subscribedByUserValue = channel.subscribedByUserValue;
                                            
                                                
                                                
                                            }];
    
    
    
    
}
-(void)unsubscribeFromChannel:(Channel*)channel
{
    
    
    [appDelegate.oAuthNetworkEngine channelUnsubscribeForUserId: appDelegate.currentOAuth2Credentials.userId
                                                      channelId: channel.uniqueId
                                              completionHandler: ^(NSDictionary *responseDictionary) {
                                                  
                                                  
                                                  channel.hasChangedSubscribeValue = YES;
                                                  
                                                  [appDelegate.currentUser removeSubscriptionsObject:channel];
                                                  
                                                  
                                                  if(channel.managedObjectContext == appDelegate.mainManagedObjectContext)
                                                  {
                                                      [appDelegate saveContext:YES];
                                                  }
                                                  else if (channel.managedObjectContext == appDelegate.searchManagedObjectContext)
                                                  {
                                                      [appDelegate saveSearchContext];
                                                  }
                                                  
                                                } errorHandler: ^(NSDictionary* errorDictionary) {
                                                    
                                                    // so that the observer will pick up the change and stop the activity indicator
                                                    channel.subscribedByUserValue = channel.subscribedByUserValue;
                                                    
                                                    
                                                }];
    
    
}

-(void)deleteChannel:(Channel*)channel
{
    [appDelegate.oAuthNetworkEngine deleteChannelForUserId:appDelegate.currentUser.uniqueId
                                                 channelId:channel.uniqueId
                                         completionHandler:^(id response) {
                                             
                                             NSMutableOrderedSet *channelsSet = [NSMutableOrderedSet orderedSetWithOrderedSet:appDelegate.currentUser.channels];
                                             
                                             
                                             [channelsSet removeObject:channel];
                                             
                                             [appDelegate.currentUser setChannels:channelsSet];
                                             
                                             [appDelegate saveContext:YES];
                                             
                                             DebugLog(@"Delete channel succeed");
                
                                         } errorHandler:^(id error) {
                                             
                                             DebugLog(@"Delete channel NOT succeed");
        
                                         }];
}

#pragma mark - Updating

-(void)updateChannel:(Channel*)channel withForceRefresh:(BOOL)refresh
{
    if (!channel.resourceURL || [channel.resourceURL isEqualToString: @""])
        return;
    
    
    
    // define success block //
    
    MKNKUserSuccessBlock successBlock = ^(NSDictionary *channelDictionary) {
        
        
        NSNumber *savedPosition = channel.position;
        
        [channel setAttributesFromDictionary: channelDictionary
                         ignoringObjectTypes: kIgnoreChannelOwnerObject];
        
        
        channel.position = savedPosition;
        
        
        NSError *error = nil;
        ZAssert([channel.managedObjectContext save: &error], @"Error saving Search moc: %@\n%@",
                [error localizedDescription], [error userInfo]);
        
    };
    
    // define success block //
    
    MKNKUserErrorBlock errorBlock = ^(NSDictionary* errorDictionary) {
        DebugLog(@"Update action failed");
        
    };
    
    if (refresh == YES || [channel.resourceURL hasPrefix: @"https"]) // https does not cache so it is fresh
    {
        [appDelegate.oAuthNetworkEngine updateChannel: channel.resourceURL
                                    completionHandler: successBlock
                                         errorHandler: errorBlock];
        
    }
    else
    {
        [appDelegate.networkEngine updateChannel: channel.resourceURL
                               completionHandler: successBlock
                                    errorHandler: errorBlock];
    }
}

// From Profile Page only

-(void)updateChannelsForChannelOwner:(ChannelOwner*)channelOwner
{
    
    MKNKUserSuccessBlock successBlock = ^(NSDictionary *channelOwnerDictionary) {
        
        
        
        [channelOwner setAttributesFromDictionary: channelOwnerDictionary
                              ignoringObjectTypes: kIgnoreVideoInstanceObjects];
        
        
        NSError *error = nil;
        ZAssert([channelOwner.managedObjectContext save: &error], @"Error saving Search moc: %@\n%@",
                [error localizedDescription], [error userInfo]);
        
    };
    
    [appDelegate.networkEngine channelOwnerDataForChannelOwner:channelOwner
                                                    onComplete:successBlock onError:^(id error) {
        
                                                    }];
}

-(BOOL)isSubscribedByCurrentUser:(Channel*)channel
{
    BOOL* isSubscribed = NULL;
    [appDelegate.currentUser.subscriptions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if( [((Channel*)obj).uniqueId isEqualToString:channel.uniqueId] ) {
            *isSubscribed = YES;
            *stop = YES;
        }
    }];
    return isSubscribed;
}


@end
