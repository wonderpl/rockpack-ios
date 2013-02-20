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

#import "SYNAppDelegate.h"

@class VideoInstance;

@interface SYNAbstractViewController : UIViewController <NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate> {
    @protected SYNAppDelegate* appDelegate;
    @protected NSString* viewId;

}

@property (readonly) NSManagedObjectContext *mainManagedObjectContext;
@property (readonly, getter = isVideoQueueVisible) BOOL videoQueueVisible;
@property (nonatomic, strong) UIView *videoQueueView;
@property (nonatomic, strong) IBOutlet UICollectionView *videoThumbnailCollectionView;
@property (nonatomic, assign) BOOL inDrag;
@property (nonatomic, assign) CGPoint initialDragCenter;
@property (nonatomic, strong) NSIndexPath *draggedIndexPath;
@property (nonatomic, strong) UIImageView *draggedView;
// Public methods

// Core Data support

// Generalised fetchedResultsControllers
- (NSFetchedResultsController *) videoInstanceFetchedResultsController;
- (NSArray *) videoInstanceFetchedResultsControllerSortDescriptors;

- (NSFetchedResultsController *) channelFetchedResultsController;
- (NSArray *) channelFetchedResultsControllerSortDescriptors;



-(void)reloadCollectionViews;

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

// Is this tab videoQueue compatible (returns false by default)
- (BOOL) hasVideoQueue;


// Override if the image w
- (BOOL) isVideoQueueVisibleOnStart;

- (void) startVideoQueueDismissalTimer;
- (void) showVideoQueue: (BOOL) animated;
- (void) hideVideoQueue: (BOOL) animated;


// Highlights video queue for when drag is in operation
- (void) highlightVideoQueue: (BOOL) showHighlight;
- (BOOL) pointInVideoQueue: (CGPoint) point;

- (void) animateVideoAdditionToVideoQueue: (VideoInstance *) videoInstance;

- (void) displayVideoViewer: (VideoInstance *) videoInstance;
- (IBAction) dismissVideoViewer;

-(id)initWithViewId:(NSString*)vid;

@end
