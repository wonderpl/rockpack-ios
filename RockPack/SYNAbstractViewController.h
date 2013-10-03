//
//  SYNAbstractViewController.h
//  rockpack
//
//  Created by Nick Banks on 27/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//
//  Abstract view controller to provide functionality common to all Rockpack view controllers


#import "MKNetworkOperation.h"
#import "SYNAppDelegate.h"
#import "SYNArcMenuView.h"
#import "SYNChannelFooterMoreView.h"
#import "SYNNetworkEngine.h"
#import "SYNOnBoardingPopoverQueueController.h"
#import "SYNOnBoardingPopoverView.h"
#import "SYNTabViewController.h"
#import "SYNTabViewDelegate.h"
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

typedef void (^SYNShareCompletionBlock)(void);

@class VideoInstance, Channel, ChannelOwner, Genre, SubGenre;

@interface SYNAbstractViewController : UIViewController <NSFetchedResultsControllerDelegate,
                                                         UICollectionViewDataSource,
                                                         UICollectionViewDelegate,
                                                         SYNTabViewDelegate,
                                                         SYNArcMenuViewDelegate>
{
@protected
    SYNAppDelegate *appDelegate;
    BOOL tabExpanded;
    SYNTabViewController *tabViewController;
    NSString *viewId;
    NSFetchedResultsController *fetchedResultsController;
    NSString *abstractTitle;
}

@property (nonatomic) BOOL isAnimating;
@property (nonatomic) BOOL isLocked;
@property (nonatomic) BOOL arcMenuIsChannelCell;
@property (nonatomic) BOOL arcMenuIsFakeCell;
@property (nonatomic) NSInteger dataItemsAvailable;
@property (nonatomic) NSRange dataRequestRange;
@property (nonatomic, assign) BOOL inDrag;
@property (nonatomic, assign) CGPoint initialDragCenter;
@property (nonatomic, assign) NSInteger arcMenuComponentIndex;
@property (nonatomic, assign, getter = isLoadingMoreContent) BOOL loadingMoreContent;
@property (nonatomic, readonly) NSString *viewId;
@property (nonatomic, strong)  NSIndexPath *arcMenuIndexPath;
@property (nonatomic, strong) IBOutlet UICollectionView *videoThumbnailCollectionView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSIndexPath *draggedIndexPath;
@property (nonatomic, strong) SYNArcMenuView *arcMenu;
@property (nonatomic, strong) SYNChannelFooterMoreView *footerView;
@property (nonatomic, strong) SYNTabViewController *tabViewController;
@property (nonatomic, strong) UIImageView *draggedView;
@property (nonatomic, weak) MKNetworkOperation *runningNetworkOperation;
@property (readonly) BOOL alwaysDisplaysSearchBox;
@property (readonly) NSManagedObjectContext *mainManagedObjectContext;
@property (readonly, getter = isVideoQueueVisible) BOOL videoQueueVisible;

- (void) performAction: (NSString *) action withObject: (id) object;

- (void) handleNewTabSelectionWithId: (NSString *) selectionId;
- (void) handleNewTabSelectionWithGenre: (Genre *) name;

- (void) videoOverlayDidDissapear;
- (void) displayVideoViewerFromView: (UIButton *) videoViewButton;

- (NSIndexPath *) indexPathFromVideoInstanceButton: (UIButton *) button;

- (void) reloadCollectionViews;

- (BOOL) collectionView: (UICollectionView *) cv didSelectItemAtIndexPathAbstract: (NSIndexPath *) indexPath;

- (void) displayVideoViewerWithVideoInstanceArray: (NSArray *) videoInstanceArray
                                 andSelectedIndex: (int) selectedIndex
                                           center: (CGPoint) center;
- (void) refresh;

- (id) initWithViewId: (NSString *) vid;
- (void) viewDidScrollToFront;
- (void) viewDidScrollToBack;

- (void) resetDataRequestRange;

- (void) incrementRangeForNextRequest;
- (BOOL) moreItemsToLoad;

- (void) headerTapped;

- (IBAction) toggleStarAtIndexPath: (NSIndexPath *) indexPath;

// Share
- (void) requestShareLinkWithObjectType: (NSString *) objectType
                               objectId: (NSString *) objectId;

- (void) shareVideoInstance: (VideoInstance *) videoInstance;

- (void) shareChannel: (Channel *) channel
              isOwner: (NSNumber *) isOwner
           usingImage: (UIImage *) image;

- (void) addVideoAtIndexPath: (NSIndexPath *) indexPath
               withOperation: (NSString *) operation;

- (void) shareVideoAtIndexPath: (NSIndexPath *) indexPath;

- (void) shareChannelAtIndexPath: (NSIndexPath *) indexPath
               andComponentIndex: (NSInteger) componentIndex;

// Purchase

- (void) initiatePurchaseAtURL: (NSURL *) purchaseURL;

- (void) applicationWillEnterForeground: (UIApplication *) application;

- (CGSize) footerSize;

- (NavigationButtonsAppearance) navigationAppearance;

- (void) arcMenuSelectedCell: (UICollectionViewCell *) selectedCell
           andComponentIndex: (NSInteger) componentIndex;

- (void) arcMenuUpdateState: (UIGestureRecognizer *) recognizer;

- (void) arcMenuUpdateState: (UIGestureRecognizer *) recognizer
         forCellAtIndexPath: (NSIndexPath *) cellIndexPath
         withComponentIndex: (NSInteger) componentIndex
                  menuItems: (NSArray *) menuItems
                    menuArc: (float) menuArc
             menuStartAngle: (float) menuStartAngle;

- (BOOL) needsHeaderButton ;

-(void)checkForOnBoarding ;
@end
