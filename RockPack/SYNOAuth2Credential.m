//
//  SYNOAuth2Credential.m
//  oauth2demo-iOS
//
//  Created by Nick Banks on 22/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNOAuth2Credential.h"
#import "SSKeychain.h"

@interface SYNOAuth2Credential ()

// Now give access to the private vars
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *refreshToken;
@property (nonatomic, copy) NSString *tokenType;
@property (nonatomic, copy) NSDate *expirationDate;

@end

@implementation SYNOAuth2Credential

#pragma mark - Class Methods

+ (id) credentialWithAccessToken: (NSString *) accessToken
                   refreshToken: (NSString *) refreshToken
                      tokenType: (NSString *) tokenType
                      expiresIn: (NSString *) expiresIn
{
    return [[self alloc] initWithAccessToken: accessToken
                                refreshToken: refreshToken
                                   tokenType: tokenType
                                   expiresIn: expiresIn];
}

+ (id) credentialFromKeychainForService: (NSString *) service
                                account: (NSString *) account
{
    NSData *data = [SSKeychain passwordDataForService: service
                                              account: account];
    
    return data ? [NSKeyedUnarchiver unarchiveObjectWithData: data] : nil;
}


#pragma mark - Initialization

- (id) initWithAccessToken: (NSString *) accessToken
              refreshToken: (NSString *) refreshToken
                 tokenType: (NSString *) tokenType
                 expiresIn: (NSString *) expiresIn
{
    if ((self = [super init]))
    {
        self.accessToken = accessToken;
        self.refreshToken = refreshToken;
        self.tokenType = tokenType;

        // We need to do a bit of wizzardry on the expiration date, as we don't actually get sent the data
        // so we must calculate it (as we don't want to do this every time the 'hasExpired' method is called
        // as that might be expensive (in terms of CPU)
        
        if (expiresIn != nil)
        {
            NSTimeInterval timeIntervalSeconds = (double) [expiresIn doubleValue];
            
            // Just to be on the safe side, assume that the token expires shortly before it actually does.
            timeIntervalSeconds -= kOAuthTokenExpiryMargin;
            
            self.expirationDate = [NSDate dateWithTimeIntervalSinceNow: timeIntervalSeconds];
        }
    }
    
    return self;
}


- (id) initWithAccessToken: (NSString *) accessToken
              refreshToken: (NSString *) refreshToken
                 tokenType: (NSString *) tokenType
            expirationDate: (NSDate *) expirationDate
{
    if ((self = [super init]))
    {
        self.accessToken = accessToken;
        self.refreshToken = refreshToken;
        self.tokenType = tokenType;
        self.expirationDate = expirationDate;
    }
    
    return self;
}


#pragma mark -
#pragma mark Public Methods

- (BOOL) hasExpired
{
    return [self.expirationDate compare: [NSDate date]] == NSOrderedAscending;
}

- (void) saveToKeychainForService: (NSString *) service
                         account: (NSString *) account
{
    NSData *credentialData = [NSKeyedArchiver archivedDataWithRootObject: self];
    
    [SSKeychain setPasswordData: credentialData
                     forService: service
                        account: account];
}

- (void) removeFromKeychainForService: (NSString *) service
                              account: (NSString *) account
{
    [SSKeychain deletePasswordForService: service
                                 account: account];
}

#pragma mark - For debugging only

- (NSString *) description
{
    return [NSString stringWithFormat: @"<%@ accessToken:\"%@\" refreshToken:\"%@\" tokenType:\"%@\" expirationDate:\"%@\">", [self class], self.accessToken, self.refreshToken, self.tokenType, self.expirationDate];
}


#pragma mark - NSCoding protocol

- (id) initWithCoder: (NSCoder *) decoder
{
    if ((self = [super init]))
    {
        self.accessToken = [decoder decodeObjectForKey: @"accessToken"];
        self.refreshToken = [decoder decodeObjectForKey: @"refreshToken"];
        self.tokenType = [decoder decodeObjectForKey: @"tokenType"];
        self.expirationDate = [decoder decodeObjectForKey: @"expirationDate"];
    }
    
    return self;
}


- (void) encodeWithCoder: (NSCoder *) encoder
{
    [encoder encodeObject: self.accessToken
                   forKey: @"accessToken"];
    
    [encoder encodeObject: self.refreshToken
                   forKey: @"refreshToken"];
    
    [encoder encodeObject: self.tokenType
                   forKey: @"tokenType"];
    
    [encoder encodeObject: self.expirationDate
                   forKey: @"expirationDate"];
}


#pragma mark - NSCopying protocol

- (id) copyWithZone: (NSZone *) zone
{
    SYNOAuth2Credential *credential = [[SYNOAuth2Credential allocWithZone: zone] initWithAccessToken: self.accessToken
                                                                                        refreshToken: self.refreshToken
                                                                                           tokenType: self.tokenType
                                                                                      expirationDate: self.expirationDate];
    // Copy the one that the init function doesn't initialise
    credential.expirationDate = self.expirationDate;
    
    return credential;
}

@end
