//
//  SYNSessionTokenCachingStrategy.h
//  rockpack
//
//  Created by Nick Banks on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

@interface SYNSessionTokenCachingStrategy : FBSessionTokenCachingStrategy

- (id) initWithToken: (NSString *) token
      andPermissions: (NSArray *) permissions;

@end
