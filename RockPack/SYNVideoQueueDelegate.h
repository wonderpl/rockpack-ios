//
//  SYNVideoQueueDelegate.h
//  rockpack
//
//  Created by Michael Michailidis on 25/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SYNVideoQueueDelegate <NSObject>

-(void)createChannelFromVideoQueue;
-(void)clearVideoQueue;

@end
