//
//  SYNAbstractViewController.h
//  rockpack
//
//  Created by Nick Banks on 27/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//
//  Abstract view controller to provide functionality common to all Rockpack view controllers


#import "SYNAddButtonControl.h"
#import "SYNAppDelegate.h"
#import "SYNNetworkEngine.h"
#import "SYNTabViewController.h"
#import "SYNTabViewDelegate.h"
#import "SYNChannelFooterMoreView.h"
#import "MKNetworkOperation.h"
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

typedef void (^SYNShareCompletionBlock)(void);

@class VideoInstance, Channel, ChannelOwner, Genre, SubGenre;

@interface SYNAbstractViewController : UIViewController <NSFetchedResultsControllerDelegate,
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
    NSString* abstractTitle;
}



@property (nonatomic) BOOL isAnimating;
@property (nonatomic) BOOL isLocked;
@property (nonatomic, assign) BOOL inDrag;
@property (nonatomic, assign) CGPoint initialDragCenter;
@property (nonatomic, readonly) NSString* viewId;
@property (nonatomic, strong) IBOutlet UICollectionView *videoThumbnailCollectionView;
@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, strong) NSIndexPath *draggedIndexPath;
@property (nonatomic, strong) SYNTabViewController* tabViewController;
@property (nonatomic, strong) UIImageView *draggedView;
@property (readonly) NSManagedObjectContext *mainManagedObjectContext;
@property (nonatomic, weak) MKNetworkOperation* runningNetworkOperation;
@property (readonly, getter = isVideoQueueVisible) BOOL videoQueueVisible;

// date related ivars

@property (nonatomic) NSRange dataRequestRange;
@property (nonatomic) NSInteger dataItemsAvailable;

@property (nonatomic, strong) SYNAddButtonControl* addButton;


@property (nonatomic, strong) SYNChannelFooterMoreView* footerView;

- (void) handleNewTabSelectionWithId: (NSString*) selectionId;
- (void) handleNewTabSelectionWithGenre: (Genre*) name;


- (void) reloadCollectionViews;

// Animation support

// Push new view controller onto UINavigationController stack using a custom animation
// Fade old VC out, fade new VC in (as opposed to regular push animation)
- (void) animatedPushViewController: (UIViewController *) vc;
- (IBAction) animatedPopViewController;
- (void) animatedPopToRootViewController;

- (BOOL) collectionView: (UICollectionView *) cv didSelectItemAtIndexPathAbstract: (NSIndexPath *) indexPath;

- (void) displayVideoViewerWithVideoInstanceArray: (NSArray *) videoInstanceArray
                                 andSelectedIndex: (int) selectedIndex;


- (void) viewProfileDetails: (ChannelOwner *) channelOwner;
- (void) refresh;


- (id) initWithViewId: (NSString*) vid;
- (void) viewDidScrollToFront;
- (BOOL) needsAddButton;
- (BOOL) toleratesSearchBar;

- (void) incrementRangeForNextRequest;

// Share
- (void) shareVideoInstance: (VideoInstance *) videoInstance
                     inView: (UIView *) inView
                   fromRect: (CGRect) rect
            arrowDirections: (UIPopoverArrowDirection) arrowDirections
          activityIndicator: (UIActivityIndicatorView *) activityIndicatorView
                 onComplete: (SYNShareCompletionBlock) completionBlock;

- (void) shareChannel: (Channel *) channel
               inView: (UIView *) inView
             fromRect: (CGRect) rect
      arrowDirections: (UIPopoverArrowDirection) arrowDirections
    activityIndicator: (UIActivityIndicatorView *) activityIndicatorView
           onComplete: (SYNShareCompletionBlock) completionBlock;

// Purchase

- (void) initiatePurchaseAtURL: (NSURL *) purchaseURL;

- (CGSize) footerSize;

@end
