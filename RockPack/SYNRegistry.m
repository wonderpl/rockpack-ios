//
//  SYNRegistry.m
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNRegistry.h"

@implementation SYNRegistry


-(id)init
{
    if (self = [super init])
    {
        appDelegate = UIApplication.sharedApplication.delegate;
        importManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSConfinementConcurrencyType];
        importManagedObjectContext.parentContext = appDelegate.mainManagedObjectContext;
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

@end
