//
//  SYNAbstractNetworkEngine.m
//  rockpack
//
//  Created by Nick Banks on 18/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAbstractNetworkEngine.h"
#import "SYNAppDelegate.h"
#import "SYNNetworkOperationJsonObjectParse.h"

@implementation SYNAbstractNetworkEngine

- (id) initWithDefaultSettings
{
    
    if ((self = [super initWithHostName: self.hostName
                     customHeaderFields: @{@"x-client-identifier" : @"Rockpack iPad client"}]))
    {
        // Set our local string (i.e. en_GB, en_US or fr_FR)
        self.localeString = [(NSString*)CFBridgingRelease(CFLocaleCreateCanonicalLanguageIdentifierFromString(NULL, (CFStringRef)[NSLocale.autoupdatingCurrentLocale objectForKey: NSLocaleIdentifier])) lowercaseString];
        
        SYNAppDelegate* appDelegate = UIApplication.sharedApplication.delegate;
        
        self.registry = appDelegate.mainRegistry;
        
        self.searchRegistry = appDelegate.searchRegistry;
        
        self.userInfoRegistry = appDelegate.userRegistry;
        
        // This engine is about requesting JSON objects and uses the appropriate operation type
        [self registerOperationSubclass: [SYNNetworkOperationJsonObject class]];
        
        
        // We should register here for locale changes
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(localeDidChange)
                                                     name: NSCurrentLocaleDidChangeNotification
                                                   object: nil];
    }
    
    return self;
}


- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: NSCurrentLocaleDidChangeNotification
                                                  object: nil];
}

// If the locale changes, then we need to reset the CoreData DB
- (void) localeDidChange
{
    //SYNAppDelegate* appDelegate = UIApplication.sharedApplication.delegate;
    //    [appDelegate resetCoreDataStack];
}

- (NSString *) hostName
{
    AssertOrLog(@"Should not be calling abstract host name method");
    return nil;
}
@end
