//
//  SYNAbstractUpdater.h
//  rockpack
//
//  Created by Nick Banks on 09/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SYNAbstractUpdater;

typedef void (^SYNUpdaterResponseBlock)(SYNAbstractUpdater* completedOperation, NSError* error, BOOL wasCancelled);

@interface SYNAbstractUpdater : NSOperation

#pragma mark -
#pragma mark Public Properties

@property (nonatomic, assign) int currentBatchSize;
@property (nonatomic, assign) int indexOffset;

#pragma mark -
#pragma mark Public Methods

- (id) initWithCompletionBlock: (SYNUpdaterResponseBlock) completionBlock
                 uniqueViewId: (NSString *) uniqueViewId;

- (void) updateObjectList: (NSString *) entityName;

- (NSString *) queryURL;


- (void) createManagedObjectsFromDictionary: (NSDictionary *) responseDictionary
                               shouldDelete: (BOOL) shouldDelete;

@end
