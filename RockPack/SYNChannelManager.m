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
                                                channel.subscribedByUserValue = YES;
                                                channel.subscribersCountValue++;
                                                
                                                // the channel that got updated was a copy inside the ChannelDetails, so we must copy it to user
                                                
                                                Channel* subscription = [Channel instanceFromChannel:channel
                                                                                           andViewId:kProfileViewId
                                                                           usingManagedObjectContext:appDelegate.currentUser.managedObjectContext
                                                                                 ignoringObjectTypes:kIgnoreChannelOwnerObject];
                                                
                                                [appDelegate.currentUser.subscriptionsSet addObject:subscription];
                                                subscription.hasChangedSubscribeValue = YES;
                                                subscription.subscribedByUserValue = YES;
                                                subscription.subscribersCountValue++;
                                                
                                                // might be in search context
                                                NSError* error;
                                                [channel.managedObjectContext save:&error];
                                                
                                                [appDelegate saveContext:YES];
                                                
                                                
                                            } errorHandler: ^(NSDictionary* errorDictionary) {
                                                
                                                // so that the observer will pick up the change and stop the activity indicator
                                                channel.subscribedByUserValue = channel.subscribedByUserValue;
                                                channel.hasChangedSubscribeValue = NO;
                                                
                                                
                                            }];
    
    
    
    
}
-(void)unsubscribeFromChannel:(Channel*)channel
{
    
    
    [appDelegate.oAuthNetworkEngine channelUnsubscribeForUserId: appDelegate.currentOAuth2Credentials.userId
                                                      channelId: channel.uniqueId
                                              completionHandler: ^(NSDictionary *responseDictionary) {
                                                  
                                                  
                                                  
                                                  channel.hasChangedSubscribeValue = YES;
                                                  
                                                  // the channel that got updated was a copy inside the ChannelDetails, so we must find the original and update it.
                                                  for (Channel* subscription in appDelegate.currentUser.subscriptions)
                                                  {
                                                      if([subscription.uniqueId isEqualToString:channel.uniqueId])
                                                      {
                                                          [appDelegate.currentUser.subscriptionsSet removeObject:subscription];
                                                          subscription.subscribedByUserValue = NO;
                                                          subscription.subscribersCountValue--;
                                                          break;
                                                      }
                                                  }
                                                  
                                                  
                                                  channel.subscribedByUserValue = NO;
                                                  channel.subscribersCountValue--;
                                                  
                                                  
                                                  [appDelegate saveContext:YES];
                                                                       
                                                  
                                                } errorHandler: ^(NSDictionary* errorDictionary) {
                                                    
                                                    // so that the observer will pick up the change and stop the activity indicator
                                                    channel.subscribedByUserValue = channel.subscribedByUserValue;
                                                    channel.hasChangedSubscribeValue = NO;
                                                    
                                                }];
    
    
}

-(void)deleteChannel:(Channel*)channel
{
    [appDelegate.oAuthNetworkEngine deleteChannelForUserId:appDelegate.currentUser.uniqueId
                                                 channelId:channel.uniqueId
                                         completionHandler:^(id response) {
                                             
                                             // this is done through the profile view so no need to copy the channel over.
                                             
                                             [appDelegate.currentUser.channelsSet removeObject:channel];
                                             
                                             [appDelegate saveContext:YES];
                                             
                
                                         } errorHandler:^(id error) {
                                             
        
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
        
        // the channel that got updated was a copy inside the ChannelDetails, so we must find the original and update it.
        for (Channel* userChannel in appDelegate.currentUser.channels)
        {
            if([userChannel.uniqueId isEqualToString:channel.uniqueId])
            {
                [userChannel setAttributesFromDictionary: channelDictionary
                                     ignoringObjectTypes: kIgnoreChannelOwnerObject];
                
                break;
            }
        }
        
        
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
    
    MKNKUserErrorBlock errorBlock = ^(id error) {
        
    };
    
    
    if([channelOwner isMemberOfClass:[User class]]) // the user uses the oAuthEngine to avoid caching
    {
        [appDelegate.oAuthNetworkEngine userDataForUser:((User*)channelOwner) onCompletion:^(id dictionary) {
            
            [channelOwner setAttributesFromDictionary: dictionary
                                  ignoringObjectTypes: kIgnoreVideoInstanceObjects | kIgnoreChannelOwnerObject];
            
            [appDelegate.oAuthNetworkEngine userSubscriptionsForUser:((User*)channelOwner) onCompletion:^(id dictionary) {
                
                
                [channelOwner addSubscriptionsDictionary:dictionary];
                
                NSError *error = nil;
                [channelOwner.managedObjectContext save: &error];
                if(error)
                {
                    NSString* errorString = [NSString stringWithFormat:@"%@ %@", [error localizedDescription], [error userInfo]];
                    DebugLog(@"%@", errorString);
                    errorBlock(@{@"saving_error":errorString});
                }
               
                
            } onError:errorBlock];
            
            
        } onError:errorBlock];
        
    }
    else // common channel owners user the public API
    {
        [appDelegate.networkEngine channelOwnerDataForChannelOwner:channelOwner onComplete:^(id dictionary) {
            
            [channelOwner setAttributesFromDictionary: dictionary
                                  ignoringObjectTypes: kIgnoreVideoInstanceObjects | kIgnoreChannelOwnerObject];
                                                            
            [appDelegate.networkEngine channelOwnerSubscriptionsForOwner:channelOwner
                                                                forRange:NSMakeRange(0, 48)
                                                       completionHandler:^(id dictionary) {
                                                                                                           
            [channelOwner addSubscriptionsDictionary:dictionary];
                                                           
                    NSError *error = nil;
                    [channelOwner.managedObjectContext save: &error];
                    if(error)
                    {
                        NSString* errorString = [NSString stringWithFormat:@"%@ %@", [error localizedDescription], [error userInfo]];
                        DebugLog(@"%@", errorString);
                        errorBlock(@{@"saving_error":errorString});
                    }
                                                                                                           
                                                                                                           
            } errorHandler:errorBlock];
                                                            
        } onError:errorBlock];
    
    }
    
    
    
    
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
