//
//  SYNAbstractViewController.h
//  rockpack
//
//  Created by Nick Banks on 27/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//
//  Abstract view controller to provide functionality common to all Rockpack view controllers

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@class Video;

@interface SYNAbstractViewController : UIViewController <NSFetchedResultsControllerDelegate,
                                                         UICollectionViewDataSource,
                                                         UICollectionViewDelegate>
// Public properties
@property (readonly) NSManagedObjectContext *managedObjectContext;
@property (readonly, getter = isImageWellVisible) BOOL imageWellVisible;

// Public methods

// Core Data support

// Generalised fetchedResultsControllers
- (NSFetchedResultsController *) videoFetchedResultsController;
- (NSPredicate *) videoFetchedResultsControllerPredicate;
- (NSArray *) videoFetchedResultsControllerSortDescriptors;

- (NSFetchedResultsController *) channelFetchedResultsController;
- (NSPredicate *) channelFetchedResultsControllerPredicate;
- (NSArray *) channelFetchedResultsControllerSortDescriptors;

// Persist the current state of CoreData to the mySQL DB
- (void) saveDB;

// Animation support

// Push new view controller onto UINavigationController stack using a custom animation
// Fade old VC out, fade new VC in (as opposed to regular push animation)
- (void) animatedPushViewController: (UIViewController *) vc;
- (IBAction) animatedPopViewController;

- (void) toggleVideoRockItAtIndex: (NSIndexPath *) indexPath;
- (void) toggleChannelRockItAtIndex: (NSIndexPath *) indexPath;

- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath;

- (BOOL) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPathAbstract: (NSIndexPath *) indexPath;

// Is this tab imagewell compatible (returns false by default)
- (BOOL) hasImageWell;


// Override if the image w
- (BOOL) isImageWellVisibleOnStart;

- (NSArray *) otherViewsToResizeOnImageWellExpandOrContract;

- (void) startImageWellDismissalTimer;
- (void) showImageWell: (BOOL) animated;
- (void) hideImageWell: (BOOL) animated;


// Highlights imagewell for when drag is in operation
- (void) highlightImageWell: (BOOL) showHighlight;
- (BOOL) pointInImageWell: (CGPoint) point;

- (void) animateImageWellAdditionWithVideo: (Video *) video;

@end
