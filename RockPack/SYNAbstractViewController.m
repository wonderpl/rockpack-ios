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
#import "Channel.h"
#import "ChannelOwner.h"
#import "NSObject+Blocks.h"
#import "OWActivityViewController.h"
#import "SYNAbstractViewController.h"
#import "SYNAppDelegate.h"
#import "SYNChannelDetailViewController.h"
#import "SYNContainerViewController.h"
#import "SYNMasterViewController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNVideoThumbnailWideCell.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+ImageProcessing.h"
#import "Video.h"
#import "VideoInstance.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNAbstractViewController ()  <UITextFieldDelegate>

@property (getter = isVideoQueueVisible) BOOL videoQueueVisible;
@property (nonatomic, assign) BOOL shouldPlaySound;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, strong) IBOutlet UIImageView *channelOverlayView;
@property (nonatomic, strong) IBOutlet UITextField *channelNameTextField;
@property (nonatomic, strong) UIPopoverController *activityPopoverController;
@property (nonatomic, strong) UIView *dropZoneView;

@end


@implementation SYNAbstractViewController


@synthesize fetchedResultsController = fetchedResultsController;
@synthesize selectedIndex = _selectedIndex;

@synthesize tabViewController;

#pragma mark - Custom accessor methods

- (id) init
{
    DebugLog (@"WARNING: init called on Abstract View Controller, call initWithViewId instead");
    return [self initWithViewId: @"UnintializedViewId"];
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
    
    
    if(self.needsAddButton)
    {
        UIButton* addToChannelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UIImage* buttonImageInactive = [UIImage imageNamed:@"ButtonAddToChannelInactive"];
        UIImage* buttonImageActive = [UIImage imageNamed:@"ButtonAddToChannelActive"];
        UIImage* buttonImageHighlighted = [UIImage imageNamed:@"ButtonAddToChannelInactiveHighlighted"];
        
        
        addToChannelButton.frame = CGRectMake(884.0, 80.0, buttonImageInactive.size.width, buttonImageInactive.size.height);
        [addToChannelButton setImage:buttonImageInactive forState:UIControlStateNormal];
        
        [addToChannelButton setImage:buttonImageActive forState:UIControlStateSelected];
        [addToChannelButton setImage:buttonImageHighlighted forState:UIControlStateHighlighted];
        
        [addToChannelButton addTarget:self action:@selector(addToChannelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:addToChannelButton];
        
    }
}

-(void)addToChannelButtonPressed:(UIButton*)button
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNoteAddToChannelRequest object:self];
}

- (void) viewCameToScrollFront
{
    DebugLog (@"came to front");
}


- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{
    startAnimationDelay = 0.0;
    [self reloadCollectionViews];
    
}


- (void) reloadCollectionViews
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
    
    [self.navigationController pushViewController: vc
                                         animated: NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteBackButtonShow
                                                        object: self];
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


- (void) videoAddButtonTapped: (UIButton *) addButton
{
    NSString* noteName;
    
    if (!addButton.selected)
    {
        noteName = kVideoQueueAdd;
        
    }
    else
    {
        noteName = kVideoQueueRemove;
    }
    
    UIView *v = addButton.superview.superview;
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: v.center];
    VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: noteName
                                                        object: self
                                                      userInfo: @{@"VideoInstance" : videoInstance}];
    
    addButton.selected = !addButton.selected;
}


- (NSIndexPath *) indexPathFromVideoInstanceButton: (UIButton *) button
{
    UIView *v = button.superview.superview;
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: v.center];
    
    return indexPath;
}

- (IBAction) userTouchedVideoShareButton: (UIButton *) videoShareButton
{
    NSIndexPath *indexPath = [self indexPathFromVideoInstanceButton: videoShareButton];
    
    // TODO: Put in video URL herer
    [self shareURL: [NSURL URLWithString: @"http://localhost"]
       withMessage: @""
          andImage: [UIImage imageNamed: @"Icon.png"]
          fromRect: videoShareButton.frame
   arrowDirections: UIPopoverArrowDirectionDown];
}


- (void) displayVideoViewerFromView: (UIButton *) videoViewButton
{
    NSIndexPath *indexPath = [self indexPathFromVideoInstanceButton: videoViewButton];

    [self displayVideoViewerWithVideoInstanceArray: self.fetchedResultsController.fetchedObjects
                                  andSelectedIndex: indexPath.item];
}


- (void) displayVideoViewerWithVideoInstanceArray: (NSArray *) videoInstanceArray
                                 andSelectedIndex: (int) selectedIndex
{
    SYNMasterViewController *masterViewController = (SYNMasterViewController*)appDelegate.masterViewController;
    
    // We don't want to be able to present more than one video viewer at a time, so disable interaction with the videoThumbnailView here
    // and then re-enable it once the overlay view has been dismissed
    self.videoThumbnailCollectionView.userInteractionEnabled = NO;
    
    [masterViewController addVideoOverlayToViewController: self
                                   withVideoInstanceArray: videoInstanceArray
                                         andSelectedIndex: selectedIndex
                                                onDismiss: ^{
                                                    self.videoThumbnailCollectionView.userInteractionEnabled = YES;
                                                }];
}




#pragma mark - UICollectionView Data Source Stubs

// To be implemented by subclasses
- (NSInteger) collectionView: (UICollectionView *) cv
      numberOfItemsInSection: (NSInteger) section
{
    AssertOrLog(@"Shouldn't be calling abstract class method");
    return 0;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    AssertOrLog(@"Shouldn't be calling abstract class method");
    return nil;
}


- (BOOL) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPathAbstract: (NSIndexPath *) indexPath
{
    AssertOrLog(@"Shouldn't be calling abstract class method");
    return NO;
}


- (void) refresh
{
    AssertOrLog(@"Shouldn't be calling abstract class method");
}


// User touched the channel thumbnail in a video cell
- (IBAction) channelButtonTapped: (UIButton *) channelButton
{
    NSIndexPath *indexPath = [self indexPathFromVideoInstanceButton: channelButton];
    
    // Bail if we don't have an index path
    if (indexPath)
    {
        VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
        
        [self viewChannelDetails: videoInstance.channel];
    }
}


- (void) viewChannelDetails: (Channel *) channel
{
    SYNChannelDetailViewController *channelVC = [[SYNChannelDetailViewController alloc] initWithChannel: channel
                                                                                              usingMode: kChannelDetailsModeDisplay];
    
    [self animatedPushViewController: channelVC];
}


- (IBAction) profileButtonTapped: (UIButton *) profileButton
{
    NSIndexPath *indexPath = [self indexPathFromVideoInstanceButton: profileButton];
    
    // Bail if we don't have an index path
    if (indexPath)
    {
        VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
        
        [self viewProfileDetails: videoInstance.channel.channelOwner];
    }
}


- (void) viewProfileDetails: (ChannelOwner *) channelOwner
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kShowUserChannels
                                                        object: self
                                                      userInfo :@{@"ChannelOwner" : channelOwner}];
}


#pragma mark - Trace

- (NSString*) description
{
    return [NSString stringWithFormat: @"ViewController: %@", viewId];
}


#pragma mark - Tab View Methods

- (void) setTabViewController: (SYNTabViewController *) newTabViewController
{
    tabViewController = newTabViewController;
    tabViewController.delegate = self;
    [self.view addSubview: tabViewController.tabView];
    
    tabExpanded = NO;
}

#pragma mark - TabViewDelegate

- (void) handleMainTap: (UITapGestureRecognizer *) recogniser
{
    // to be implemented by child
    DebugLog(@"WARNING: Abstract method called");
}


- (void) handleSecondaryTap: (UITapGestureRecognizer *) recogniser
{
    // to be implemented by child
    DebugLog(@"WARNING: Abstract method called");
}


- (void) handleNewTabSelectionWithId: (NSString*) selectionId
{
    // to be implemented by child
    DebugLog(@"WARNING: Abstract method called");
}

- (BOOL) showSubcategories
{
    return YES;
}

- (BOOL) needsAddButton
{
    return NO;
}

#pragma mark - Social network sharing

- (void) shareURL: (NSURL *) shareURL
      withMessage: (NSString *) shareString
         andImage: (UIImage *) shareImage
         fromRect: (CGRect) rect
  arrowDirections: (UIPopoverArrowDirection) arrowDirections
{
//    if (_activityPopoverController && _activityPopoverController.isPopoverVisible)
//    {
//        [_activityPopoverController dismissPopoverAnimated: YES];
//        _activityPopoverController =  nil;
//        return;
//    }
    
    // Prepare activities
    OWFacebookActivity *facebookActivity = [[OWFacebookActivity alloc] init];
    OWTwitterActivity *twitterActivity = [[OWTwitterActivity alloc] init];
    OWMessageActivity *messageActivity = [[OWMessageActivity alloc] init];
    OWMailActivity *mailActivity = [[OWMailActivity alloc] init];
    
    // Compile activities into an array, we will pass that array to
    // OWActivityViewController on the next step

    NSArray *activities = @[facebookActivity, twitterActivity, messageActivity, mailActivity];

    // Create OWActivityViewController controller and assign data source
    //
    OWActivityViewController *activityViewController = [[OWActivityViewController alloc] initWithViewController: self
                                                                                                     activities: activities];
    
    activityViewController.userInfo = @{
                                        @"text": shareString,
                                        @"url": shareURL};
    
    // The activity controller needs to be presented from a popup on iPad, but normally on iPhone
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.activityPopoverController = [[UIPopoverController alloc] initWithContentViewController: activityViewController];
        
        activityViewController.presentingPopoverController = _activityPopoverController;
        
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
