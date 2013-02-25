//
//  SYNDataProxy.h
//  rockpack
//
//  Created by Michael Michailidis on 25/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "SYNAppDelegate.h"

#define kDataProxyTypeAbstract @"Abstract"

#define kDataProxyTypeChannel @"Channel"
#define kDataProxyTypeVideos @"VideoInstance"


@interface SYNAbstractDataProxy : NSObject <NSFetchedResultsControllerDelegate, UICollectionViewDataSource> {
@protected
    NSString* dataType;
    NSFetchedResultsController* fetchedRequestController;
    SYNAppDelegate* appDelegate;
    
}

+(id)proxy;

-(void)start;

@property (nonatomic, readonly) NSString* dataType;

@property (nonatomic, weak) NSString* ownerViewId;

@property (nonatomic, readonly) NSString* proxyName;


@property (nonatomic, readonly) NSString* cacheName;
@property (nonatomic, readonly) NSString* sectionKeyPath;
@property (nonatomic, readonly) NSPredicate* predicate;
@property (nonatomic, readonly) NSArray* descriptors;

@property (nonatomic, readonly) NSManagedObjectContext* managedObjectContext;

@end
