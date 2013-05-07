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
#import "SYNTabViewDelegate.h"
#import "SYNTabViewController.h"
#import "SYNAppDelegate.h"
#import "GAITrackedViewController.h"

//#import "Channel.h"
#import "SYNNetworkEngine.h"


@class VideoInstance, Channel, ChannelOwner;

@interface SYNAbstractViewController : GAITrackedViewController <NSFetchedResultsControllerDelegate,
                                                                 UICollectionViewDataSource,
                                                                 UICollectionViewDelegate,
                                                                 SYNTabViewDelegate>
{
@protected
    SYNAppDelegate* appDelegate;
    BOOL tabExpanded;
    SYNTabViewController* tabViewController;
    NSString* viewId;
    NSFetchedResultsController* fetchedResultsController;
    CGFloat startAnimationDelay;
}


@property (nonatomic, assign) BOOL inDrag;
@property (nonatomic, assign) CGPoint initialDragCenter;
@property (nonatomic, strong) IBOutlet UICollectionView *videoThumbnailCollectionView;
@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, strong) NSIndexPath *draggedIndexPath;
@property (nonatomic, strong) SYNTabViewController* tabViewController;
@property (nonatomic, strong) UIImageView *draggedView;
@property (readonly) NSManagedObjectContext *mainManagedObjectContext;
@property (readonly, getter = isVideoQueueVisible) BOOL videoQueueVisible;

- (void) handleNewTabSelectionWithId: (NSString*) selectionId;
- (void) handleNewTabSelectionWithName: (NSString*) name;


- (void) reloadCollectionViews;

// Animation support

// Push new view controller onto UINavigationController stack using a custom animation
// Fade old VC out, fade new VC in (as opposed to regular push animation)
- (void) animatedPushViewController: (UIViewController *) vc;
- (IBAction) animatedPopViewController;

- (BOOL) collectionView: (UICollectionView *) cv didSelectItemAtIndexPathAbstract: (NSIndexPath *) indexPath;

- (void) displayVideoViewerWithVideoInstanceArray: (NSArray *) videoInstanceArray
                                 andSelectedIndex: (int) selectedIndex;

- (void) viewChannelDetails: (Channel *) channel;
- (void) viewProfileDetails: (ChannelOwner *) channelOwner;
- (void) refresh;


- (id) initWithViewId: (NSString*) vid;
- (void) viewCameToScrollFront;
- (BOOL) needsAddButton;

// Share
- (void) shareVideoInstance: (VideoInstance *) videoInstance
                     inView: (UIView *) inView
                   fromRect: (CGRect) rect
            arrowDirections: (UIPopoverArrowDirection) arrowDirections;

- (void) shareChannel: (Channel *) channel
               inView: (UIView *) inView
             fromRect: (CGRect) rect
      arrowDirections: (UIPopoverArrowDirection) arrowDirections;

// Purchase

- (void) initiatePurchaseAtURL: (NSURL *) purchaseURL;

@end
