//
//  SYNRegistry.h
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SYNAppDelegate;

typedef void(^SYNRegistryCompletionBlock)(BOOL success);

typedef BOOL(^SYNRegistryActionBlock)(void);

@interface SYNRegistry : NSObject {
    @protected __weak SYNAppDelegate *appDelegate;
    @protected NSManagedObjectContext* importManagedObjectContext;
}


- (id) initWithManagedObjectContext: (NSManagedObjectContext*) moc;
+ (id) registryWithImportContext:(NSManagedObjectContext*)moc;

- (BOOL) saveImportContext;
- (BOOL) clearImportContextFromEntityName: (NSString*) entityName;


-(void)performInBackground:(SYNRegistryActionBlock)actionBlock completionBlock:(SYNRegistryCompletionBlock)completionBlock;

@end
