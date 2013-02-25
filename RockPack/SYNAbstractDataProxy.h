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

typedef enum {
    kDataProxyTypeUndefined = -1,
    kDataProxyTypeChannel = 0,
    kDataProxyTypeVideos = 1
} kDataProxyType;

@interface SYNAbstractDataProxy : NSObject <NSFetchedResultsControllerDelegate, UICollectionViewDataSource> {
@protected
    kDataProxyType type;
    NSFetchedResultsController* fetchedRequestController;
    SYNAppDelegate* appDelegate;
    
}

-(id)initWithType:(kDataProxyType)dataProxyType;
+(id)proxy;
+(id)proxyWithType:(kDataProxyType)dataProxyType;

-(void)start;

@property (nonatomic, readonly) kDataProxyType type;



@property (nonatomic, weak) NSString* ownerViewId;

@property (nonatomic, readonly) NSString* proxyName;

@property (nonatomic, readonly) NSString* entityName;
@property (nonatomic, readonly) NSString* cacheName;
@property (nonatomic, readonly) NSString* sectionKeyPath;
@property (nonatomic, readonly) NSPredicate* predicate;
@property (nonatomic, readonly) NSArray* descriptors;

@property (nonatomic, readonly) NSManagedObjectContext* managedObjectContext;

@end
