//
//  SYNSubscriptionsManager.h
//  rockpack
//
//  Created by Michael Michailidis on 23/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Channel.h"

@interface SYNSubscriptionsManager : NSObject


-(void)subscribeToChannel:(Channel*)channel;
-(void)unsubscribeFromChannel:(Channel*)channel;
-(void)toggleSubscriptionToChannel:(Channel*)channel;

+(id)manager;

@end
