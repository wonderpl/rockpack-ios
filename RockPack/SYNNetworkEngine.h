//
//  SYNNetworkEngine.h
//  rockpack
//
//  Created by Nick Banks on 10/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "MKNetworkEngine.h"

typedef void (^JSONResponseBlock)(id jsonObject);

@interface SYNNetworkEngine : MKNetworkEngine

-(id) initWithDefaultSettings;

- (void) updateHomeScreen;
- (void) updateChannelScreen;

@end
