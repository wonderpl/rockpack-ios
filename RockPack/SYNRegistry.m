//
//  SYNRegistry.m
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNRegistry.h"
#import "SYNAppDelegate.h"

@implementation SYNRegistry


-(id)init
{
    if (self = [super init])
    {
        appDelegate = UIApplication.sharedApplication.delegate;
        importManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSConfinementConcurrencyType];
        importManagedObjectContext.parentContext = appDelegate.mainManagedObjectContext;
        
        // Changes are only propagated from child to parent. Therefore we need to listen for changes to the parent to ensure the import context is up to date.
        // Most of the time the context save should be a result of the import managed object context saving, so impact will be minimal.
        // However, logging out changes the main context directly and we need to sync then.
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshImportContext:) name:NSManagedObjectContextDidSaveNotification object:appDelegate.mainManagedObjectContext];
    }
    return self;
}

+(id)registry
{
    return [[self alloc] init];
}

-(id)initWithManagedObjectContext:(NSManagedObjectContext*)moc
{
    if (self = [self init])
    {
        
        if(moc)
        {
            importManagedObjectContext.parentContext = moc;
        }
        
        
    }
    
    return self;
}



#pragma mark - Import Context Management

-(BOOL)saveImportContext
{
    NSError* error;
    
    if([importManagedObjectContext save:&error])
        return YES;
    
    // else...
    NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
    if ([detailedErrors count] > 0)
        for(NSError* detailedError in detailedErrors)
            DebugLog(@"Import MOC Save Error (Detailed): %@", [detailedError userInfo]);
    
    
    return NO;
}

-(BOOL)clearImportContextFromEntityName:(NSString*)entityName
{
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:importManagedObjectContext];
    [fetchRequest setEntity:entityDescription];
    
    NSError* error = nil;
    NSArray * result = [importManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(error != nil)
        return NO;
    
    for (id basket in result)
        [importManagedObjectContext deleteObject:basket];
    
    
    return YES;
    
    
}

-(void)refreshImportContext:(NSNotification*)notification
{
    NSManagedObjectContext* savedContext = [notification object];
    if(savedContext == appDelegate.mainManagedObjectContext && [NSThread isMainThread])
    {
        [importManagedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    }
}

@end
