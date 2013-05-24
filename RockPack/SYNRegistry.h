//
//  SYNRegistry.h
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SYNAppDelegate;

@interface SYNRegistry : NSObject {
    @protected __weak SYNAppDelegate *appDelegate;
    @protected NSManagedObjectContext* importManagedObjectContext;
}


- (id) initWithManagedObjectContext: (NSManagedObjectContext*) moc;
+ (id) registry;

- (BOOL) saveImportContext;
- (BOOL) clearImportContextFromEntityName: (NSString*) entityName;

@end
