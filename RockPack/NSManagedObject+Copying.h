//
//  NSManagedObject+Copying.h
//  rockpack
//
//  Created by Nick Banks on 27/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//
//  Based on https://gist.github.com/162745
//
//  This makes some assumptions about your code, for example that you’ve got ownership rules set up properly.
//  If a relationship to another entity uses the cascade deletion rule, it’s considered to be owned by the receiver, and thus will be copied by -deepCopyWithZone:.


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface NSManagedObject (SYNCopying)

- (void) setRelationshipsToObjectsByIDs:(id)objects;

- (id) copyShallow;
- (id) copyShallowNoInsert;
- (id) copyShallowWithZone: (NSZone *) zone;
- (id) copyShallowWithZone: (NSZone *) zone
insertIntoManagedObjectContext: (NSManagedObjectContext *) context;

- (id) copyDeep;
- (id) copyDeepNoInsert;
- (id) copyDeepWithZone: (NSZone *) zone;
- (id) copyDeepWithZone: (NSZone *) zone
insertIntoManagedObjectContext: (NSManagedObjectContext *) context;

- (NSDictionary * )ownedIDs;

@end
