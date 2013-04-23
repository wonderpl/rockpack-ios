//
//  SYNAbstractViewController.m
//  rockpack
//
//  Created by Nick Banks on 27/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//
//  Abstract view controller to provide functionality common to all Rockpack view controllers
//
//  To keep the code as DRY as possible, we put as much common stuff in here as possible

#import "AppConstants.h"
#import "AudioToolbox/AudioToolbox.h"
#import "ChannelOwner.h"
#import "NSObject+Blocks.h"
#import "SYNAbstractViewController.h"
#import "SYNAppDelegate.h"
#import "SYNContainerViewController.h"
#import "SYNChannelDetailViewController.h"
#import "SYNChannelsDetailsCreationViewController.h"
#import "SYNMasterViewController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNVideoQueueCell.h"
#import "SYNVideoThumbnailWideCell.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+ImageProcessing.h"
#import "SYNNetworkErrorView.h"
#import "Video.h"
#import "VideoInstance.h"
#import "Channel.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNAbstractViewController ()  <UITextFieldDelegate>

@property (getter = isVideoQueueVisible) BOOL videoQueueVisible;
@property (nonatomic, assign) BOOL shouldPlaySound;
@property (nonatomic, strong) IBOutlet UIImageView *channelOverlayView;
@property (nonatomic, strong) IBOutlet UITextField *channelNameTextField;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, strong) UIPopoverController *activityPopoverController;
@property (nonatomic, strong) SYNNetworkErrorView* errorView;

@property (nonatomic, strong) UIView *dropZoneView;


@end


@implementation SYNAbstractViewController


@synthesize fetchedResultsController = fetchedResultsController;
@synthesize selectedIndex = _selectedIndex;

@synthesize tabViewController;

#pragma mark - Custom accessor methods

- (id) init
{
    DebugLog(@"WARNING: init called on Abstract View Controller, call initWithViewId instead");
    return [self initWithViewId: @"NULL"];
}

- (id) initWithViewId: (NSString*) vid
{
    if ((self = [super init]))
    {
        viewId = vid;
    }
    
    return self;
}


#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate]; 
}

- (void) viewCameToScrollFront
{
    
}

- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{
    startAnimationDelay = 0.0;
    [self reloadCollectionViews];
    
}


-(void) reloadCollectionViews
{
    //AssertOrLog (@"Abstract class called 'reloadCollectionViews'");
}






#pragma mark - Animation support

// Special animation of pushing new view controller onto UINavigationController's stack
- (void) animatedPushViewController: (UIViewController *) vc
{
    self.view.alpha = 1.0f;
    vc.view.alpha = 0.0f;
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^ {
                         // Contract thumbnail view
                         self.view.alpha = 0.0f;
                         vc.view.alpha = 1.0f;
                     }
                     completion: nil];
    
    [self.navigationController pushViewController:vc animated: NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNoteBackButtonShow object:self];
}


- (void) animatedPopViewController
{
    UIViewController *parentVC = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2];
    parentVC.view.alpha = 0.0f;
    
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
         
         self.view.alpha = 0.0f;
         parentVC.view.alpha = 1.0f;
         
     } completion: ^(BOOL finished) {
         
     }];
    
    [self.navigationController popViewControllerAnimated:NO];
    
    // Hide back button
    [[NSNotificationCenter defaultCenter] postNotificationName:kNoteBackButtonHide object:self];
}


- (void) toggleChannelSubscribeAtIndex: (NSIndexPath *) indexPath
{
    Channel *channel = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    if (channel.subscribedByUserValue == YES)
    {
        // Currently highlighted, so decrement
        channel.subscribedByUserValue = NO;
        channel.subscribersCountValue -= 1;
        
        // Update the star/unstar status on the server
        [appDelegate.oAuthNetworkEngine channelUnsubscribeForUserId: appDelegate.currentOAuth2Credentials.userId
                                                          channelId: channel.uniqueId
                                                  completionHandler: ^(NSDictionary *responseDictionary) {
                                                      DebugLog(@"Unsubscribe action successful");
                                                  }
                                                       errorHandler: ^(NSDictionary* errorDictionary) {
                                                           DebugLog(@"Unsubscribe action failed");
                                                       }];
    }
    else
    {
        // Currently highlighted, so increment
        channel.subscribedByUserValue = TRUE;
        channel.subscribersCountValue += 1;
        
        // Update the star/unstar status on the server
        [appDelegate.oAuthNetworkEngine channelSubscribeForUserId: appDelegate.currentOAuth2Credentials.userId
                                                       channelURL: channel.resourceURL
                                                completionHandler: ^(NSDictionary *responseDictionary) {
                                                        DebugLog(@"Subscribe action successful");
                                                   } errorHandler: ^(NSDictionary* errorDictionary) {
                                                       DebugLog(@"Subscribe action failed");
                                                   }];
    }
    
    [appDelegate saveContext:YES];
}





// This can be overridden if updating star may cause the videoFetchedResults
- (BOOL) shouldUpdateStarStatus
{
    return TRUE;
}


// This is intended to be subclassed where other video assets (i.e. a Large video view) have information that is dependent on Video attributes
- (void) updateOtherOnscreenVideoAssetsForIndexPath: (NSIndexPath *) indexPath
{
    // By default, do nothing
}


- (void) userTouchedVideoAddItButton: (UIButton *) addItButton
{
   
    [addItButton setSelected:YES];
    
    UIView *v = addItButton.superview.superview;
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: v.center];
    VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kVideoQueueAdd
                                                        object: self
                                                      userInfo: @{@"VideoInstance" : videoInstance}];
}


- (IBAction) userTouchedVideoShareItButton: (UIButton *) addItButton
{
    
    
    
}


- (void) displayVideoViewerFromView: (UIButton *) videoViewButton
{
//    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: [sender locationInView: self.videoThumbnailCollectionView]];
    UIView *v = videoViewButton.superview.superview;
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: v.center];

    [self displayVideoViewerWithSelectedIndexPath: indexPath];
}


- (void) displayVideoViewerWithSelectedIndexPath: (NSIndexPath *) selectedIndexPath
{
    SYNMasterViewController *masterViewController = (SYNMasterViewController*)appDelegate.masterViewController;
    
    [masterViewController addVideoOverlayToViewController: self
                             withFetchedResultsController: self.fetchedResultsController
                                             andIndexPath: selectedIndexPath];
}

- (void) displayCategoryChooser
{
    SYNMasterViewController *masterViewController = (SYNMasterViewController*)appDelegate.masterViewController;
    
    [masterViewController addCategoryChooserOverlayToViewController: self];
}


#pragma mark - UICollectionView Data Source Stubb

- (NSInteger) collectionView: (UICollectionView *) cv numberOfItemsInSection: (NSInteger) section {
    return 0;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) cv cellForItemAtIndexPath: (NSIndexPath *) indexPath {
    
    UICollectionViewCell *cell = nil;
    // to be implemented by subview
    return cell;
}


- (BOOL) collectionView: (UICollectionView *) cv didSelectItemAtIndexPathAbstract: (NSIndexPath *) indexPath {
    return NO;
}

-(void)refresh
{
    // to implement in subclass
}


#pragma mark - Channel Creation Methods

- (void) createChannel:(Channel*)channel
{
    SYNChannelsDetailsCreationViewController *channelCreationVC = [[SYNChannelsDetailsCreationViewController alloc] initWithChannel: channel];
    
    [self animatedPushViewController: channelCreationVC];
}

- (void) addToChannel:(Channel*)channel
{
//    SYNChannelsAddVideosViewController *channelCreationVC = [[SYNChannelsAddVideosViewController alloc] initWithChannel: channel];
//    
//    [self animatedPushViewController: channelCreationVC];
}

// User touched the channel thumbnail in a video cell
- (IBAction) userTouchedChannelButton: (UIButton *) channelButton
{
    // Get to cell it self (from button subview)
    UIView *v = channelButton.superview.superview.superview;
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: v.center];
    
    // Bail if we don't have an index path
    if (indexPath)
    {
        VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
        
        [self viewChannelDetails: videoInstance.channel];
    }
}


- (void) viewChannelDetails: (Channel *) channel
{
    SYNChannelDetailViewController *channelVC = [[SYNChannelDetailViewController alloc] initWithChannel: channel];
    
    [self animatedPushViewController: channelVC];
}


- (IBAction) userTouchedProfileButton: (UIButton *) profileButton
{
    // Get to cell it self (from button subview)
    UIView *v = profileButton.superview.superview.superview;
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: v.center];
    
    // Bail if we don't have an index path
    if (indexPath)
    {
        VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
        
        [self viewProfileDetails: videoInstance.channel.channelOwner];
    }
}

- (void) viewProfileDetails: (ChannelOwner *) channelOwner
{

    [[NSNotificationCenter defaultCenter] postNotificationName:kShowUserChannels object:self userInfo:@{@"ChannelOwner":channelOwner}];
}





- (BOOL) hasTabBar
{
    return TRUE;
}


#pragma mark - Video Queue Methods

- (BOOL) isVideoQueueVisibleOnStart;
{
    return FALSE;
}



- (void) highlightVideoQueue: (BOOL) showHighlight
{
    
}




#pragma mark - Trace

-(NSString*) description
{
    return [NSString stringWithFormat:@"ViewController: %@", viewId];
}


#pragma mark - Tab View Methods

- (void) highlightTab: (int) tabIndex
{
    
}


-(void)setTabViewController:(SYNTabViewController *)newTabViewController
{
    tabViewController = newTabViewController;
    tabViewController.delegate = self;
    [self.view addSubview:tabViewController.tabView];
    
    tabExpanded = NO;
}

#pragma mark - TabViewDelegate

-(void)handleMainTap:(UITapGestureRecognizer *)recogniser
{
    // to be implemented by child
}


-(void)handleSecondaryTap:(UITapGestureRecognizer *)recogniser
{
    // to be implemented by child
}


-(void)handleNewTabSelectionWithId:(NSString*)selectionId
{
    // to be implemented by child
}

-(BOOL)showSubcategories
{
    return YES;
}

-(BOOL)needsAddButton
{
    return NO;
}

#pragma mark - Social network sharing

- (void) shareURL: (NSURL *) shareURL
      withMessage: (NSString *) shareString
         fromRect: (CGRect) rect
  arrowDirections: (UIPopoverArrowDirection) arrowDirections
{
    NSArray *activityItems = @[shareString, shareURL];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems: activityItems
                                                                                         applicationActivities: nil];
    
    activityViewController.excludedActivityTypes = @[UIActivityTypeAssignToContact,
                                                     UIActivityTypePrint,
                                                     UIActivityTypeCopyToPasteboard,
                                                     UIActivityTypeSaveToCameraRoll];
    
    // The activity controller needs to be presented from a popup on iPad, but normally on iPhone
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.activityPopoverController = [[UIPopoverController alloc] initWithContentViewController: activityViewController];
        
        [self.activityPopoverController presentPopoverFromRect: rect
                                                        inView: self.view
                                      permittedArrowDirections: arrowDirections
                                                      animated: YES];
    }
    else
    {
        [self presentViewController: activityViewController
                           animated: YES
                         completion: nil];
    }
}


#pragma mark - Purchase

- (void) initiatePurchaseAtURL: (NSURL *) purchaseURL
{
    if ([[UIApplication sharedApplication] canOpenURL: purchaseURL])
	{
		[[UIApplication sharedApplication] openURL: purchaseURL];
	}
}


@end
