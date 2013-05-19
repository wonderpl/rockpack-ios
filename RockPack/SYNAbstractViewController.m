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
#import "SYNDeviceManager.h"
#import "SYNMasterViewController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNProfileRootViewController.h"
#import "SYNPopoverBackgroundView.h"
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

@property (strong, readonly, nonatomic) NSArray *activities;
@property (strong, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) OWActivityView *activityView;
@property (weak, nonatomic) UIPopoverController *presentingPopoverController;
@property (weak, nonatomic) UIViewController *presentingController;

@end


@implementation SYNAbstractViewController


@synthesize fetchedResultsController = fetchedResultsController;
@synthesize selectedIndex = _selectedIndex;

@synthesize tabViewController;
@synthesize addButton;

#pragma mark - Custom accessor methods

- (id) init
{
//    DebugLog (@"WARNING: init called on Abstract View Controller, call initWithViewId instead");
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearedLocationBoundData)
                                                 name:kClearedLocationBoundData
                                               object:nil];
    
    
    if(self.needsAddButton)
    {
        self.addButton = [SYNAddButtonControl button];
        CGRect addButtonFrame = self.addButton.frame;
        addButtonFrame.origin.x = 884.0f;
        addButtonFrame.origin.y = 80.0f;
        self.addButton.frame = addButtonFrame;
        [self.view addSubview:addButton];
    }
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}



-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
    NSInteger viewControllersCount = self.navigationController.viewControllers.count;
    
    if(viewControllersCount < 2) // we must have at least two to pop one
        return;
    
    
    UIViewController *parentVC = self.navigationController.viewControllers[viewControllersCount - 2];
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


- (void) videoAddButtonTapped: (UIButton *) _addButton
{
    NSString* noteName;
    
    if (!_addButton.selected || [[SYNDeviceManager sharedInstance] isIPhone]) // There is only ever one video in the queue on iPhone. Always fire the add action.
    {
        noteName = kVideoQueueAdd;
    }
    else
    {
        noteName = kVideoQueueRemove;
    }
    
    UIView *v = _addButton.superview.superview;
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: v.center];
    VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: noteName
                                                        object: self
                                                      userInfo: @{@"VideoInstance" : videoInstance}];
    
    _addButton.selected = !_addButton.selected;

}


- (NSIndexPath *) indexPathFromVideoInstanceButton: (UIButton *) button
{
    UIView* target = button;
    while (target && ![target isKindOfClass:[UICollectionViewCell class]])
    {
        target = [target superview];
    }
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: target.center];
    
    return indexPath;
}

- (IBAction) userTouchedVideoShareButton: (UIButton *) videoShareButton
{
    NSIndexPath *indexPath = [self indexPathFromVideoInstanceButton: videoShareButton];
    VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    [self shareVideoInstance: videoInstance
                      inView: self.view
                    fromRect: videoShareButton.frame
             arrowDirections: UIPopoverArrowDirectionDown];
}


- (void) displayVideoViewerFromView: (UIButton *) videoViewButton
{
    NSIndexPath *indexPath = [self indexPathFromVideoInstanceButton: videoViewButton];
    
    id selectedVideo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSArray* videoArray =  self.fetchedResultsController.fetchedObjects;
    [self displayVideoViewerWithVideoInstanceArray: videoArray
                                  andSelectedIndex: [videoArray indexOfObject:selectedVideo]];
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
    SYNProfileRootViewController *profileVC = [[SYNProfileRootViewController alloc] initWithViewId:@""];
    
    profileVC.user = channelOwner;
    
    [self animatedPushViewController: profileVC];
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

- (void) handleNewTabSelectionWithGenre: (Genre*) name
{
    // to be implemented by child
    DebugLog(@"WARNING: Abstract method called");
}

-(void)clearedLocationBoundData
{
    // to be implemented by child
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

- (void) shareVideoInstance: (VideoInstance *) videoInstance
                     inView: (UIView *) inView
                   fromRect: (CGRect) rect
            arrowDirections: (UIPopoverArrowDirection) arrowDirections
{
    [self shareObjectType: @"video_instance"
                 objectId: videoInstance.uniqueId
                   inView: inView
                 fromRect: rect
          arrowDirections: arrowDirections];
}


- (void) shareChannel: (Channel *) channel
               inView: (UIView *) inView
             fromRect: (CGRect) rect
      arrowDirections: (UIPopoverArrowDirection) arrowDirections
{
    [self shareObjectType: @"channel"
                 objectId: channel.uniqueId
                   inView: inView
                 fromRect: rect
          arrowDirections: arrowDirections];
}


- (void) shareObjectType: (NSString *) objectType
                objectId: (NSString *) objectId
                  inView: (UIView *) inView
                fromRect: (CGRect) rect
         arrowDirections: (UIPopoverArrowDirection) arrowDirections
{
    // Update the star/unstar status on the server
    [appDelegate.oAuthNetworkEngine shareLinkWithObjectType: objectType
                                                   objectId: objectId
                                          completionHandler: ^(NSDictionary *responseDictionary) {
                                              DebugLog(@"Share link successful");
                                              
                                              UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
                                              CGRect keyWindowRect = [keyWindow bounds];
                                              UIGraphicsBeginImageContextWithOptions(keyWindowRect.size, YES, 0.0f);
                                              CGContextRef context = UIGraphicsGetCurrentContext();
                                              [keyWindow.layer renderInContext: context];
                                              UIImage *capturedScreenImage = UIGraphicsGetImageFromCurrentImageContext();
                                              UIGraphicsEndImageContext();
                                              
                                              UIInterfaceOrientation orientation = [[SYNDeviceManager sharedInstance] orientation];
                                              
                                              switch (orientation)
                                              {
                                                  case UIDeviceOrientationPortrait:
                                                      orientation = UIImageOrientationUp;
                                                      break;
                                                      
                                                  case UIDeviceOrientationPortraitUpsideDown:
                                                      orientation = UIImageOrientationDown;
                                                      break;
                                                      
                                                  case UIDeviceOrientationLandscapeLeft:
                                                      orientation = UIImageOrientationLeft;
                                                      break;
                                                      
                                                  case UIDeviceOrientationLandscapeRight:
                                                      orientation = UIImageOrientationRight;
                                                      break;

                                                  default:
                                                      orientation = UIImageOrientationRight;
                                                      DebugLog(@"Unknown orientation");
                                                      break;
                                              }
                                              
                                              UIImage *fixedOrientationImage = [UIImage imageWithCGImage: capturedScreenImage.CGImage
                                                                                                   scale: capturedScreenImage.scale
                                                                                             orientation: orientation];
                                              capturedScreenImage = fixedOrientationImage;
                                              
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
                                              
                                              NSString *resourceURLString = responseDictionary[@"resource_url"];
                                              NSString *message = responseDictionary[@"message"];
                                              
                                              if (resourceURLString == nil || [message isKindOfClass: [NSNull class]] || [resourceURLString isEqualToString: @""])
                                              {
                                                  resourceURLString = @"http://www.rockpack.com";
                                              }
                                              
                                              if (message == nil || [message isKindOfClass: [NSNull class]])
                                              {
                                                  message = @"";
                                              }
                                              
                                              NSURL *resourceURL = [NSURL URLWithString: resourceURLString];
                                              
                                              activityViewController.userInfo = @{@"text": message,
                                                                                  @"url": resourceURL,
                                                                                  @"image" : capturedScreenImage};
                                              
                                              // The activity controller needs to be presented from a popup on iPad, but normally on iPhone
                                              if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                                              {
                                                  self.activityPopoverController = [[UIPopoverController alloc] initWithContentViewController: activityViewController];
                                                  self.activityPopoverController.popoverBackgroundViewClass = [SYNPopoverBackgroundView class];
                                                  
                                                  activityViewController.presentingPopoverController = _activityPopoverController;
                                                  
                                                  [self.activityPopoverController presentPopoverFromRect: rect
                                                                                                  inView: inView
                                                                                permittedArrowDirections: arrowDirections
                                                                                                animated: YES];
                                              }
                                              else
                                              {
//                                                  [self presentViewController: activityViewController
//                                                                     animated: YES
//                                                                   completion: nil];
                                                  
                                                  [activityViewController presentFromRootViewController];
                                              }
                                          }
                                               errorHandler: ^(NSDictionary* errorDictionary) {
                                                   DebugLog(@"Share link failed");
                                               }];

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
