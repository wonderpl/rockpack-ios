//
//  SYNVideoQueue.h
//  rockpack
//
//  Created by Michael Michailidis on 22/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Channel.h"

@interface SYNVideoQueue : NSObject

@property (nonatomic, strong) Channel* currentlyCreatingChannel;

+(id)queue;

-(BOOL)videoInstanceIsAddedToChannel:(VideoInstance*)videoInstance;

@end
