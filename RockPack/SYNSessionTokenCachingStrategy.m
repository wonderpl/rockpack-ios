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
    
    // Token key - WORKS
//    tokenInformationDictionary[@"com.facebook.sdk:TokenInformationTokenKey"] = @"CAAB3zOQVv4ABADvfwOZCRNlZARpAzNRQl5likEZBZCZAQhFlVmImZCloFMSKPisnfy7wXHtWpf9cV5GDTeQLn4HLBo131OZA0cEGRSLuhwRZBFjJeCfADaJIPE8BpZCFR3ZBirh6ZCPBjyav6kZC0c58Pz3Qbc8q7bOzKISeargsI6IvSMpZADDgHZCZAPGCciTvx6Q9gMZD";
    
    // Token key - DOESN'T WORK
//    tokenInformationDictionary[@"com.facebook.sdk:TokenInformationTokenKey"] = 
//    @"CAAB3zOQVv4ABAPKEcJwcjmGpmI3YGCjoZBoWL6FhaVt42FLjZCpsZCZCncdZANFo1jkPZAoXL3qaePP13DNjwZCTkFk855yvZBDqrawonTpqFIm1rZBTQb0kqjcuNgSgMvRND5ThWtuv2nNTQPgSH1E3ytbZCckETRa3wZD";
    
    // Token key - NEW
    tokenInformationDictionary[@"com.facebook.sdk:TokenInformationTokenKey"] =
    @"CAAB3zOQVv4ABAM0ysQpjueqhgTTcR1pQq9T435DYgnmR3uDMvYGsUousuBCZAFUsu6xxRusDUwzhuFjXWkjPkZB9vGcOCMBjZBHoa3pVRhzpy3CTScZBewE74tjshj5eZAWeZAfeE0Q9dbmH7l6NHzdFg4Tt6zvSRhdThZA0wiy1CWUj5ZA9GC2K";
    
//    // Token key
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
    AssertOrLog(@"Only for login, shouldn't be used");
}


@end
