//
//  SYNRegistry.m
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNRegistry.h"
#import "SYNAppDelegate.h"

@implementation SYNRegistry

+ (id) registryWithParentContext:(NSManagedObjectContext*)moc
{
    return [[self alloc] initWithParentManagedObjectContext:moc];
}


- (id) init
{
    if (self = [super init])
    {
        appDelegate = UIApplication.sharedApplication.delegate;
    }
    
    return self;
}


- (id) initWithParentManagedObjectContext: (NSManagedObjectContext*) moc
{
    if (self = [self init])
    {
        if (moc)
        {
            NSManagedObjectContext* workerContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
            workerContext.parentContext = moc;
            importManagedObjectContext = workerContext;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContext:) name:NSManagedObjectContextDidSaveNotification object:moc];
        }
    }
    
    return self;
}

-(void)updateContext:(NSNotification*)note
{
    if([note object] == importManagedObjectContext.parentContext )
    {
        [importManagedObjectContext performBlock:^{
            [importManagedObjectContext mergeChangesFromContextDidSaveNotification:note];
        }];
    }
}

- (id) initWithManagedObjectContext: (NSManagedObjectContext*) moc
{
    {
        if (self = [self init])
        {
            if (moc)
            {
                importManagedObjectContext=moc;
            }
        }
        
        return self;
    }
}

+ (id) registryWithManagedContext:(NSManagedObjectContext*)moc
{
    return [[self alloc] initWithManagedObjectContext:moc];
}


#pragma mark - Import Context Management

- (BOOL) saveImportContext
{
    NSError* error;
    if ([importManagedObjectContext save: &error])
    {
        return YES;
    }
    else
    {
        // Something went wrong, so print as much debug info as we can
        NSArray* detailedErrors = [error userInfo][NSDetailedErrorsKey];
        {
            if ([detailedErrors count] > 0)
            {
                for(NSError* detailedError in detailedErrors)
                {
                    DebugLog(@"Import MOC Save Error (Detailed): %@", [detailedError userInfo]);
                }
            }
        }
    }
    
    return NO;
}


- (BOOL) clearImportContextFromEntityName: (NSString*) entityName
{
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName: entityName
                                                         inManagedObjectContext: importManagedObjectContext];
    [fetchRequest setEntity: entityDescription];
    
    fetchRequest.includesPropertyValues = NO;
    
    NSError *error = nil;
    NSArray *result = [importManagedObjectContext executeFetchRequest: fetchRequest
                                                                 error: &error];
    
    // Bail, if our fetch request failed
    if (error)
    {
        AssertOrLog(@"clearImportContextFromEntityName: Fetch request failed");
        return NO;
    }
    
    for (id basket in result)
    {
        [importManagedObjectContext deleteObject: basket];
    }
    
    BOOL saveResult = [self saveImportContext];
    
    if (!saveResult)
    {
        AssertOrLog(@"clearImportContextFromEntityName: Save failed");
        return NO;
    }
    
    [self saveImportContext];
    
    return YES;  
}

-(void)performInBackground:(SYNRegistryActionBlock)actionBlock completionBlock:(SYNRegistryCompletionBlock)completionBlock
{
    [importManagedObjectContext performBlock:^{
       BOOL result = actionBlock(importManagedObjectContext);
        [self completeTransaction:result completionBlock:completionBlock];
    }];
}

-(void)completeTransaction:(BOOL)success completionBlock:(SYNRegistryCompletionBlock)block
{
    if(block)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(success);
        });
    }
}

@end
