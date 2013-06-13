//
//  SYNChannelManager.m
//  rockpack
//
//  Created by Michael Michailidis on 23/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNChannelManager.h"
#import "SYNAppDelegate.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNNetworkEngine.h"
#import "AppConstants.h"
#import "VideoInstance.h"
#import "MKNetworkOperation.h"

@interface SYNChannelManager()

@property (nonatomic, weak) SYNAppDelegate* appDelegate;
@property (nonatomic, weak) MKNetworkOperation* channelUpdateOperation;
@property (nonatomic, weak) MKNetworkOperation* channelOwnerUpdateOperation;

@end

@implementation SYNChannelManager

@synthesize appDelegate;

+ (id) manager
{
    return [[self alloc] init];
}


-(id) init
{
    if ((self = [super init]))
    {
        self.appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(channelSubscribeRequest:)
                                                     name: kChannelSubscribeRequest
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(channelUpdateRequest:)
                                                     name: kChannelUpdateRequest
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(channelOwnerUpdateRequest:)
                                                     name: kChannelOwnerUpdateRequest
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(channelDeleteRequest:)
                                                     name: kChannelDeleteRequest
                                                   object: nil]; 
    }
    
    return self;
}


#pragma mark - Notification Handlers

- (void) channelSubscribeRequest: (NSNotification*) notification
{
    Channel* channelToSubscribe = (Channel*)[[notification userInfo] objectForKey: kChannel];
    
    if (!channelToSubscribe)
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


// update another user's profile channels //

- (void) channelOwnerUpdateRequest: (NSNotification*) notification
{
    ChannelOwner* channelOwner = (ChannelOwner*)[[notification userInfo] objectForKey: kChannelOwner];
    if(!channelOwner)
        return;
    
    [self updateChannelsForChannelOwner:channelOwner];
}


- (void) channelUpdateRequest: (NSNotification*) notification
{
    Channel* channelToUpdate = (Channel*)[[notification userInfo] objectForKey: kChannel];
    
    if (!channelToUpdate)
    {
        if(self.channelUpdateOperation)
            [self.channelUpdateOperation cancel];
        
        return;
    }
        
    
    // If the channel to be updated is not yet created then update it based on the videoQueue objects, else make a network call
    Channel* currentlyCreatingChannel = appDelegate.videoQueue.currentlyCreatingChannel;
    if([channelToUpdate.uniqueId isEqualToString:currentlyCreatingChannel.uniqueId])
    {
        [channelToUpdate.videoInstancesSet enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [((VideoInstance*)obj).managedObjectContext deleteObject:obj];
        }];
        
        for (VideoInstance* vi in currentlyCreatingChannel.videoInstances)
        {
            VideoInstance* copyOfVideoInstance = [VideoInstance instanceFromVideoInstance:vi
                                                                usingManagedObjectContext:channelToUpdate.managedObjectContext
                                                                      ignoringObjectTypes:kIgnoreChannelObjects];
            
            [channelToUpdate.videoInstancesSet addObject:copyOfVideoInstance];
        }
        
        NSError* error;
        [channelToUpdate.managedObjectContext save:&error];
        
        return;
    }
    else
    {
        [self updateChannel:channelToUpdate withForceRefresh:channelToUpdate.hasChangedSubscribeValue];
    }
    
    
    
}


- (void) channelDeleteRequest: (NSNotification*) notification
{
    Channel* channelToUpdate = (Channel*)[[notification userInfo] objectForKey: kChannel];
    if (!channelToUpdate)
        return;
    
    [self deleteChannel:channelToUpdate];
}


#pragma mark - Implementation Methods

- (void) subscribeToChannel: (Channel*) channel
{
    [appDelegate.oAuthNetworkEngine channelSubscribeForUserId: appDelegate.currentOAuth2Credentials.userId
                                                   channelURL: channel.resourceURL
                                            completionHandler: ^(NSDictionary *responseDictionary) {
                                                
                                                // This notifies the ChannelDetails through KVO

                                                channel.hasChangedSubscribeValue = YES;
                                                channel.subscribedByUserValue = YES;
                                                channel.subscribersCountValue += 1;

                                                // the channel that got updated was a copy inside the ChannelDetails, so we must copy it to user
                                                IgnoringObjects copyFlags = kIgnoreVideoInstanceObjects;
                                                
                                                Channel* subscription = [Channel instanceFromChannel:channel
                                                                                           andViewId:kProfileViewId
                                                                           usingManagedObjectContext:appDelegate.currentUser.managedObjectContext
                                                                                 ignoringObjectTypes:copyFlags];
                                                
                                            

                                                subscription.hasChangedSubscribeValue = YES;

                                                [appDelegate.currentUser addSubscriptionsObject:subscription];

                                                // might be in search context
                                                NSError* error;
                                                [channel.managedObjectContext save:&error];
                                                if(error)
                                                {
                                                    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateFailed object:self];

                                                }
                                                else
                                                {
                                                    [appDelegate saveContext:YES];
                                                }
                                                
                                                
                                                
                                                
                                            } errorHandler: ^(NSDictionary* errorDictionary) {
                                                
                                                [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateFailed object:self];
                                                
                                                
                                            }];
    
    
    
    
}
-(void)unsubscribeFromChannel:(Channel*)channel
{
    
    
    [appDelegate.oAuthNetworkEngine channelUnsubscribeForUserId: appDelegate.currentOAuth2Credentials.userId
                                                      channelId: channel.uniqueId
                                              completionHandler: ^(NSDictionary *responseDictionary) {
                                                  
                                                  
                                                  // This notifies the ChannelDetails through KVO
                                                  channel.hasChangedSubscribeValue = YES;
                                                  channel.subscribedByUserValue = NO;
                                                  channel.subscribersCountValue -= 1;
                                                  
                                                  // the channel that got updated was a copy inside the ChannelDetails, so we must find the original and update it.
                                                  for (Channel* subscription in appDelegate.currentUser.subscriptions)
                                                  {
                                                      if([subscription.uniqueId isEqualToString:channel.uniqueId])
                                                      {
                                                          
                                                          [appDelegate.currentUser removeSubscriptionsObject:subscription];
                                                          
                                                          break;
                                                      }
                                                  }
                                                  
                                                  NSError* error;
                                                  [channel.managedObjectContext save:&error];
                                                  if(error)
                                                  {
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateFailed object:self];
                                                  }
                                                  else
                                                  {
                                                      [appDelegate saveContext:YES];
                                                  }
                                                  
                                                                       
                                                  
                                                } errorHandler: ^(NSDictionary* errorDictionary) {
                                                    
                                                    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateFailed object:self];
                                                    
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
        if (![channel.managedObjectContext save: &error])
        {
            AssertOrLog(@"Channels Details Failed: %@\n%@", [error localizedDescription], [error userInfo]);
        }
    };
    
    // define success block //
    
    MKNKUserErrorBlock errorBlock = ^(NSDictionary* errorDictionary) {
        DebugLog(@"Update action failed");
        
    };
    
    if (refresh == YES || [channel.resourceURL hasPrefix: @"https"]) // https does not cache so it is fresh
    {
        
        
        self.channelUpdateOperation = [appDelegate.oAuthNetworkEngine updateChannel: channel.resourceURL
                                                                  completionHandler: successBlock
                                                                       errorHandler: errorBlock];
        
    }
    else
    {
        
        
        self.channelUpdateOperation = [appDelegate.networkEngine updateChannel: channel.resourceURL
                                                             completionHandler: successBlock
                                                                  errorHandler: errorBlock];
    }
}

// From Profile Page only

-(void)updateChannelsForChannelOwner:(ChannelOwner*)channelOwner
{
    
    MKNKUserErrorBlock errorBlock = ^(id error) {
        
    };
    
    
    if([channelOwner.uniqueId isEqualToString:appDelegate.currentUser.uniqueId]) // the user uses the oAuthEngine to avoid caching
    {
        [appDelegate.oAuthNetworkEngine userDataForUser:((User*)channelOwner) onCompletion:^(id dictionary) {
            
            [channelOwner setAttributesFromDictionary: dictionary
                                  ignoringObjectTypes: kIgnoreVideoInstanceObjects | kIgnoreChannelOwnerObject];
            
            [appDelegate.oAuthNetworkEngine userSubscriptionsForUser:((User*)channelOwner) onCompletion:^(id dictionary) {
                
                // this will remove the old subscriptions
                [channelOwner setSubscriptionsDictionary:dictionary];
                
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
                                                                                                           
            [channelOwner setSubscriptionsDictionary:dictionary];
                                                           
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




@end
