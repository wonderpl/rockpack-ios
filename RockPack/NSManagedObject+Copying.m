//
//  NSManagedObject+Copying.m
//  rockpack
//
//  Created by Nick Banks on 27/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "NSManagedObject+Copying.h"

#pragma mark - NSManagedObject Copying (Shallow & Deep)

@implementation NSManagedObject (AYNCopying)

// Deep copy
- (id) copyDeep
{
    return [self copyDeepWithZone: NSDefaultMallocZone()];
}


// Shallow copy, not inserted into any
- (id) copyDeepNoInsert
{
    return [self copyDeepWithZone: NSDefaultMallocZone()
   insertIntoManagedObjectContext: nil];
}



- (id) copyDeepWithZone: (NSZone *) zone
{
    // Use the MOC of the original NSManagedObject
	NSManagedObjectContext *context = [self managedObjectContext];
    
    return [self copyDeepWithZone: zone
   insertIntoManagedObjectContext: context];
}

- (id) copyDeepWithZone: (NSZone *) zone
       insertIntoManagedObjectContext: (NSManagedObjectContext *) context
{
	NSMutableDictionary *ownedIDs = [[self ownedIDs] mutableCopy];
    
	id copied = [self copyShallowWithZone: zone]; // -copyWithZone: copies the attributes for us
    
	for (NSManagedObjectID *key in [ownedIDs allKeys])
    {
        // deep copy relationships
		id copiedObject = [[context objectWithID: key]
                           copyShallowWithZone: zone];
        
		[ownedIDs setObject: copiedObject
                     forKey: key];
        
		[copiedObject release];
	}
    
	[self setRelationshipsToObjectsByIDs: ownedIDs];
    
	for (NSManagedObjectID *key in [ownedIDs allKeys])
    {
		[[ownedIDs objectForKey: key] setRelationshipsToObjectsByIDs: ownedIDs];
	}
    
	return copied;
}


// Shallow copy, inserted into the same MOC as the original object
- (id) copyShallow
{
    return [self copyShallowWithZone: NSDefaultMallocZone()];
}


// Shallow copy, not inserted into any
- (id) copyShallowNoInsert
{
    return [self copyShallowWithZone: NSDefaultMallocZone()
      insertIntoManagedObjectContext: nil];
}



- (id) copyShallowWithZone: (NSZone *) zone
{
    // Use the MOC of the original NSManagedObject
	NSManagedObjectContext *context = [self managedObjectContext];
    
    return [self copyShallowWithZone: zone insertIntoManagedObjectContext: context];
}

- (id) copyShallowWithZone: (NSZone *) zone
       insertIntoManagedObjectContext: (NSManagedObjectContext *) context
{
	id copied = [[[self class] allocWithZone: zone] initWithEntity: [self entity]
                                    insertIntoManagedObjectContext: context];
    
	for (NSString *key in [[[self entity] attributesByName] allKeys])
    {
		[copied setValue: [self valueForKey: key]
                  forKey: key];
	}
    
	for (NSString *key in [[[self entity] relationshipsByName] allKeys])
    {
		[copied setValue: [self valueForKey: key]
                  forKey: key];
	}
    
	return copied;
}


- (void) setRelationshipsToObjectsByIDs: (id) objects
{
	id newReference = nil;
	NSDictionary *relationships = [[self entity] relationshipsByName];
	for (NSString *key in [relationships allKeys])
    {
		if([[relationships objectForKey: key] isToMany])
        {
			id references = [NSMutableSet set];
			for (id reference in [self valueForKey: key])
            {
				if ((newReference = [objects objectForKey: [reference objectID]]))
                {
					[references addObject: newReference];
				}
                else
                {
					[references addObject: reference];
				}
			}
            
			[self setValue: references forKey: key];
		}
        else
        {
			if ((newReference = [objects objectForKey: [[self valueForKey: key] objectID]]))
            {
				[self setValue: newReference
                        forKey: key];
			}
		}
	}
}


- (NSDictionary *) ownedIDs
{
	NSDictionary *relationships = [[self entity] relationshipsByName];
	NSMutableDictionary *ownedIDs = [NSMutableDictionary dictionary];
    
	for (NSString *key in [relationships allKeys])
    {
		id relationship = [relationships objectForKey: key];
        
		if ([relationship deleteRule] == NSCascadeDeleteRule)
        {
            // ownership
			if ([relationship isToMany])
            {
				for (id child in [self valueForKey: key])
                {
					[ownedIDs setObject: child
                                 forKey: [child objectID]];
                    
					[ownedIDs addEntriesFromDictionary: [child ownedIDs]];
				}
			}
            else
            {
				id reference = [self valueForKey: key];
				[ownedIDs setObject: reference
                             forKey: [reference objectID]];
			}
		}
	}
    
	return ownedIDs;
}

@end

