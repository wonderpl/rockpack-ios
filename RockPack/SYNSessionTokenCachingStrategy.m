//
//  SYNSessionTokenCachingStrategy.m
//  rockpack
//
//  Created by Nick Banks on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSessionTokenCachingStrategy.h"
#import <FacebookSDK/FBSessionTokenCachingStrategy.h>

@interface SYNSessionTokenCachingStrategy ()

@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSArray *permissions;


@end

@implementation SYNSessionTokenCachingStrategy

#pragma mark - Initialization methods
/*
 * Init method.
 */
- (id) initWithToken: (NSString *) token
      andPermissions: (NSArray *) permissions
{
    if ((self = [super init]))
    {
        _token = token;
        _permissions = permissions;

    }
    
    return self;
}


#pragma FBTokenCachingStrategy override methods

/*
 * Override method called to cache token.
 */
- (void) cacheFBAccessTokenData: (FBAccessTokenData *)accessToken
{
    AssertOrLog(@"Only for login, shouldn't be used");
}

/*
 * Override method to fetch token.
 */
- (FBAccessTokenData *)fetchFBAccessTokenData 
{
    NSMutableDictionary *tokenInformationDictionary = [NSMutableDictionary new];
    
    // Expiration date
    tokenInformationDictionary[@"com.facebook.sdk:TokenInformationExpirationDateKey"] = [NSDate dateWithTimeIntervalSinceNow: 3600];;
    
    // Refresh date
    tokenInformationDictionary[@"com.facebook.sdk:TokenInformationRefreshDateKey"] = [NSDate date];
    
    // Token key
    tokenInformationDictionary[@"com.facebook.sdk:TokenInformationTokenKey"] = self.token;
    
    // Permissions
    tokenInformationDictionary[@"com.facebook.sdk:TokenInformationPermissionsKey"] = self.permissions;
    
    // Login key
    tokenInformationDictionary[@"com.facebook.sdk:TokenInformationLoginTypeLoginKey"] = @0;

    return [FBAccessTokenData createTokenFromDictionary: tokenInformationDictionary];
}

/*
 * Override method to clear token.
 */
- (void) clearToken
{
    NSLog(@"Token clear called");
}


@end
