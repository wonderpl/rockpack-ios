//
//  SYNDataProxy.m
//  rockpack
//
//  Created by Michael Michailidis on 25/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAbstractDataProxy.h"

@implementation SYNAbstractDataProxy

@synthesize ownerViewId;


@synthesize cacheName;
@synthesize predicate;
@synthesize descriptors;
@synthesize sectionKeyPath;
@synthesize managedObjectContext;

@synthesize proxyName;


-(id)init
{
    if (self = [super init]) {
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    }
    return self;
}



+(id)proxy
{
    return [[self alloc] init];
}



-(NSString*)proxyName
{
    return  NSStringFromClass([self class]);
}

-(NSString*)dataType
{
    return nil;
}


-(void)start
{
    if(!ownerViewId) {
        DebugLog(@"No owner view id passed to proxy '%@'", self.proxyName);
        return;
    }
    
    if(!dataType) {
        DebugLog(@"No data type for proxy '%@'", self.proxyName);
        return;
    }
    
    [self createFetchedResultsController];
}

#pragma mark - FetchedResultsController

-(void)createFetchedResultsController
{
    
    NSError *error = nil;
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.entity = [NSEntityDescription entityForName: self.dataType
                                      inManagedObjectContext: self.managedObjectContext];
    
    fetchRequest.predicate = self.predicate;
    fetchRequest.sortDescriptors = self.descriptors;
    
    fetchedRequestController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                   managedObjectContext: self.managedObjectContext
                                                                     sectionNameKeyPath: self.sectionKeyPath
                                                                              cacheName: self.cacheName];
    fetchedRequestController.delegate = self;
    
    ZAssert([fetchedRequestController performFetch: &error], @"FetchRequestController Failed in Proxy: %@\n%@", [error localizedDescription], [error userInfo]);
    
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *) collectionView: (UICollectionView *) cv cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    // Implement in subclass
    return nil;
    
}

- (NSInteger) collectionView: (UICollectionView *) cv numberOfItemsInSection: (NSInteger) section
{
    // implement in subclass
    return 0;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    // implement in subclass
    return 0;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    // implement in subclass
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // implement in subclass
}


#pragma mark - Request Specifics






-(NSPredicate*)predicate
{
    // standard predicate for most requests, override in subclass
    NSString* predicateFormatedString = [NSString stringWithFormat:@"viewId == \"%@\"", ownerViewId];
    return [NSPredicate predicateWithFormat:predicateFormatedString];
}

-(NSArray*)descriptors
{
    // standard descriptor for most requests, override in subclass
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"position" ascending: YES];
    return @[sortDescriptor];
}

-(NSString*)sectionKeyPath
{
    return nil;
}




-(NSString*)cacheName
{
    return nil;
}


-(NSManagedObjectContext*)managedObjectContext
{
    return appDelegate.mainManagedObjectContext;
}

@end
