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
#import "SYNMasterViewController.h"
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
#import "GAI.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNAbstractViewController ()  <UITextFieldDelegate>


@property (getter = isVideoQueueVisible) BOOL videoQueueVisible;
@property (nonatomic, assign) BOOL shouldPlaySound;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, strong) IBOutlet UIImageView *channelOverlayView;
@property (nonatomic, strong) IBOutlet UITextField *channelNameTextField;
@property (nonatomic, strong) UIPopoverController *activityPopoverController;
@property (nonatomic, strong) UIView *dropZoneView;
@property (strong, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) OWActivityView *activityView;
@property (strong, readonly, nonatomic) NSArray *activities;
@property (weak, nonatomic) UIPopoverController *presentingPopoverController;
@property (weak, nonatomic) UIViewController *presentingController;

@end


@implementation SYNAbstractViewController


@synthesize fetchedResultsController = fetchedResultsController;
@synthesize selectedIndex = _selectedIndex;

@synthesize tabViewController;
@synthesize addButton;

@synthesize viewId;

#pragma mark - Custom accessor methods

- (id) init
{
    return [self initWithViewId: @"Unknown"];
}


- (id) initWithViewId: (NSString*) vid
{
    if ((self = [super init]))
    {
        viewId = vid;
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(applicationWillEnterForeground:)
                                                     name: UIApplicationWillEnterForegroundNotification
                                                   object: nil];
    }
    
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kClearedLocationBoundData
                                                  object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIApplicationWillEnterForegroundNotification
                                                  object: nil];
}

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(clearedLocationBoundData)
                                                 name: kClearedLocationBoundData
                                               object: nil];
    
    appDelegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];

    if (self.needsAddButton && [[SYNDeviceManager sharedInstance] isIPad])
    {
        self.addButton = [SYNAddButtonControl button];
        CGRect addButtonFrame = self.addButton.frame;
        addButtonFrame.origin.x = self.view.frame.size.width - 140.0f; // 884.0f
        addButtonFrame.origin.y = 80.0f;
        self.addButton.frame = addButtonFrame;

        self.addButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        [self.view addSubview: addButton];
    }
    
    // for loading data
    
    [self resetDataRequestRange];
    
}


- (void) resetDataRequestRange
{
    self.dataRequestRange = NSMakeRange(0, STANDARD_REQUEST_LENGTH);
}

- (void) viewDidScrollToFront
{
//    DebugLog (@"%@ came to front", self.title);
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
- (void) animatedPushViewController: (SYNAbstractViewController *) controller
{
    
    [appDelegate.masterViewController pushController:controller];
}


- (void) animatedPopViewController
{
    [appDelegate.masterViewController popController];
    
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
    if(!self.videoThumbnailCollectionView) // not all sub classes will have this initialized so check to avoid errors
        return;
    
    if(_addButton.selected)
        return;
    
    
    UIView *v = _addButton.superview.superview;
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: v.center];
    VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    
    
    if(videoInstance)
    {
        id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
        
        [tracker sendEventWithCategory: @"uiAction"
                            withAction: @"videoPlusButtonClick"
                             withLabel: nil
                             withValue: nil];
        
        [appDelegate.oAuthNetworkEngine recordActivityForUserId: appDelegate.currentUser.uniqueId
                                                         action: @"select"
                                                videoInstanceId: videoInstance.uniqueId
                                              completionHandler: ^(id response) {
                                                  
                                                  
                                              } errorHandler: ^(id error) {
                                                  
                                                  DebugLog(@"Could not record videoAddButtonTapped: activity");
                                                  
                                              }];

        
        [[NSNotificationCenter defaultCenter] postNotificationName: kVideoQueueAdd
                                                            object: self
                                                          userInfo: @{@"VideoInstance" : videoInstance }];
    }
    
    
    
    
    
    [self.videoThumbnailCollectionView reloadData];
    
    
    _addButton.selected = !_addButton.selected; // switch to on/off
}


- (void) incrementRangeForNextRequest
{
    NSLog (@"Before: Loc %d, Len %d, Avail %d", self.dataRequestRange.location, self.dataRequestRange.length, self.dataItemsAvailable);
    NSInteger nextStart = self.dataRequestRange.location + self.dataRequestRange.length; // one is subtracted when the call happens for 0 indexing
    
    if (nextStart >= self.dataItemsAvailable)
    {
        NSLog (@"Bailed: Loc %d, Len %d, Avail %d", self.dataRequestRange.location, self.dataRequestRange.length, self.dataItemsAvailable);
        return;
    }

    
    self.loadingMoreContent = YES;
    
    NSInteger nextSize = (nextStart + STANDARD_REQUEST_LENGTH) >= self.dataItemsAvailable ? (self.dataItemsAvailable - nextStart) : STANDARD_REQUEST_LENGTH;
    
    self.dataRequestRange = NSMakeRange(nextStart, nextSize);
    NSLog (@"After: Loc %d, Len %d, Avail %d", self.dataRequestRange.location, self.dataRequestRange.length, self.dataItemsAvailable);
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
    
    // Stop multiple clicks by disabling button 
    videoShareButton.enabled = FALSE;
    
    [self shareVideoInstance: videoInstance
                      inView: self.view
                    fromRect: videoShareButton.frame
             arrowDirections: UIPopoverArrowDirectionDown
           activityIndicator: nil
                  onComplete: ^{
                 // Re-enable button
                 videoShareButton.enabled = TRUE;
             }];
}


- (void) displayVideoViewerFromView: (UIButton *) videoViewButton
{
    NSIndexPath *indexPath = [self indexPathFromVideoInstanceButton: videoViewButton];
    
    id selectedVideo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSArray* videoArray =  self.fetchedResultsController.fetchedObjects;
    CGPoint center;
    if(videoViewButton)
    {
        center = [self.view convertPoint:videoViewButton.center fromView:videoViewButton.superview];
    }
    else
    {
        center = self.view.center;
    }
    [self displayVideoViewerWithVideoInstanceArray: videoArray
                                  andSelectedIndex: [videoArray indexOfObject:selectedVideo] center:center];
}


- (void) displayVideoViewerWithVideoInstanceArray: (NSArray *) videoInstanceArray
                                andSelectedIndex: (int) selectedIndex center:(CGPoint)center
{
    SYNMasterViewController *masterViewController = (SYNMasterViewController*)appDelegate.masterViewController;
        
    [masterViewController addVideoOverlayToViewController: self
                                   withVideoInstanceArray: videoInstanceArray
                                         andSelectedIndex: selectedIndex fromCenter:center];
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


// User pressed the channel thumbnail in a VideoCell
- (IBAction) channelButtonTapped: (UIButton *) channelButton
{
    NSIndexPath *indexPath = [self indexPathFromVideoInstanceButton: channelButton];
    
    if (indexPath)
    {
        VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kChannelDetailsRequested
                                                            object:self
                                                          userInfo:@{kChannel:videoInstance.channel}];
    }
}

- (void) videoOverlayDidDissapear
{
    // to be implemented by child
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
    SYNProfileRootViewController *profileVC = [[SYNProfileRootViewController alloc] initWithViewId:kProfileViewId];
    
    profileVC.user = channelOwner;
    
    // if there is a profile already there just pass the new user if is different
    if(self.navigationController.viewControllers.count > 1)
    {
        SYNAbstractViewController* currentlyVisibleVC = (SYNAbstractViewController*)self.navigationController.visibleViewController;
        if([currentlyVisibleVC isKindOfClass:[SYNProfileRootViewController class]])
        {
            SYNProfileRootViewController* currentlyVisibleProfile = (SYNProfileRootViewController*)currentlyVisibleVC;
            if([currentlyVisibleProfile.user.uniqueId isEqualToString:channelOwner.uniqueId])
                return;
            
            currentlyVisibleProfile.user = channelOwner;
            
            return;
        }
    }
   
    
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
- (BOOL) showSubGenres
{
    return YES;
}

- (BOOL) needsAddButton
{
    return NO;
}

- (BOOL) toleratesSearchBar
{
    return NO;
}

-(void)setTitle:(NSString *)title
{
    abstractTitle = title;
}

-(NSString*)title
{
    if(abstractTitle && ![abstractTitle isEqualToString:@""])
        return abstractTitle;
    else
        return viewId;
}

#pragma mark - Social network sharing

- (void) shareVideoInstance: (VideoInstance *) videoInstance
                     inView: (UIView *) inView
                   fromRect: (CGRect) rect
            arrowDirections: (UIPopoverArrowDirection) arrowDirections
          activityIndicator: (UIActivityIndicatorView *) activityIndicatorView
                 onComplete: (SYNShareCompletionBlock) completionBlock
{
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker sendEventWithCategory: @"uiAction"
                        withAction: @"videoShareButtonClick"
                         withLabel: nil
                         withValue: nil];
    
    [self shareObjectType: @"video_instance"
                 objectId: videoInstance.uniqueId
                  isOwner: @FALSE
                  isVideo: @TRUE
                   inView: inView
                 fromRect: rect
          arrowDirections: arrowDirections
        activityIndicator: activityIndicatorView
               onComplete: completionBlock];
}


- (void) shareChannel: (Channel *) channel
              isOwner: (NSNumber *) isOwner
               inView: (UIView *) inView
             fromRect: (CGRect) rect
      arrowDirections: (UIPopoverArrowDirection) arrowDirections
    activityIndicator: (UIActivityIndicatorView *) activityIndicatorView
           onComplete: (SYNShareCompletionBlock) completionBlock
{
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker sendEventWithCategory: @"uiAction"
                        withAction: @"channelShareButtonClick"
                         withLabel: nil
                         withValue: nil];
    
    [self shareObjectType: @"channel"
                 objectId: channel.uniqueId
                  isOwner: isOwner
                  isVideo: @FALSE
                   inView: inView
                 fromRect: rect
          arrowDirections: arrowDirections
        activityIndicator: activityIndicatorView
               onComplete: completionBlock];
}


- (void) shareObjectType: (NSString *) objectType
                objectId: (NSString *) objectId
                 isOwner: (NSNumber *) isOwner
                 isVideo: (NSNumber *) isVideo
                  inView: (UIView *) inView
                fromRect: (CGRect) rect
         arrowDirections: (UIPopoverArrowDirection) arrowDirections
       activityIndicator: (UIActivityIndicatorView *) activityIndicatorView
              onComplete: (SYNShareCompletionBlock) completionBlock
{
    [activityIndicatorView startAnimating];
    
    // Update the star/unstar status on the server
    [appDelegate.oAuthNetworkEngine shareLinkWithObjectType: objectType
                                                   objectId: objectId
                                          completionHandler: ^(NSDictionary *responseDictionary) {
                                              [activityIndicatorView stopAnimating];
//                                              DebugLog(@"Share link successful");
                                              
                                              UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
                                              CGRect keyWindowRect = [keyWindow bounds];
                                              UIGraphicsBeginImageContextWithOptions(keyWindowRect.size, YES, 0.0f);
                                              CGContextRef context = UIGraphicsGetCurrentContext();
                                              [keyWindow.layer renderInContext: context];
                                              UIImage *capturedScreenImage = UIGraphicsGetImageFromCurrentImageContext();
                                              UIGraphicsEndImageContext();
                                              
                                              UIInterfaceOrientation orientation = [SYNDeviceManager.sharedInstance orientation];
                                              
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
                                              
                                              if (resourceURLString == nil || [resourceURLString isEqualToString: @""])
                                              {
                                                  resourceURLString = @"http://rockpack.com";
                                              }
                                              
                                              if (message == nil || [message isKindOfClass: [NSNull class]])
                                              {
                                                  message = @"";
                                              }
                                              
                                              NSString *userName = nil;
                                              NSString *subject = nil;
                                                                                            
                                              
                                              User* user = appDelegate.currentUser;
                                              if (user.fullNameIsPublicValue)
                                              {
                                                  userName = user.fullName;
                                              }
                                              
                                              if (userName.length < 1)
                                              {
                                                  userName = user.username;
                                              }
                                              
                                              if (userName != nil)
                                              {
                                                  NSString *what = @"channel";
                                                  
                                                  if (isVideo.boolValue == TRUE)
                                                  {
                                                     what = @"video";
                                                  }
                                                  
                                                  subject = [NSString stringWithFormat: @"%@ has shared a %@ with you", userName, what];
                                              }

                                              NSURL *resourceURL = [NSURL URLWithString: resourceURLString];
                                              
                                              activityViewController.userInfo = @{@"text": message,
                                                                                  @"url": resourceURL,
                                                                                  @"image" : capturedScreenImage,
                                                                                  @"owner" : isOwner,
                                                                                  @"video" : isVideo,
                                                                                  @"subject" : subject};
                                              
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
                                                  [activityViewController presentFromRootViewController];
                                              }
                                              
            
                                              completionBlock();
                                          }
                                               errorHandler: ^(NSDictionary* errorDictionary) {
                                                   [activityIndicatorView stopAnimating];
//                                                   DebugLog(@"Share link failed");
                                                   completionBlock();
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

- (void) headerTapped
{
    
}

- (void) viewDidScrollToBack
{
    // to be implemented by subclass
}


#pragma mark - Load more footer

// Load more footer

- (CGSize) footerSize
{
    return [SYNDeviceManager.sharedInstance isIPhone] ? CGSizeMake(320.0f, 64.0f) : CGSizeMake(1024.0, 64.0);
}


- (void) loadingMoreContent: (BOOL) loadingMoreContent
{
    // First set the state of our footer spinner
    self.footerView.showsLoading = loadingMoreContent;
    
    // Now set our actual variable
    _loadingMoreContent = loadingMoreContent;
}


#pragma mark UIApplication Callback Notifications

- (void) applicationWillEnterForeground: (UIApplication *) application
{
    [self resetDataRequestRange];
    
    // and then make a class appropriate data call

}

- (NavigationButtonsAppearence) navigationAppearence
{
    // return the standard and overide in subclass for special cases such as the ChannelDetails Section
    return NavigationButtonsAppearenceBlack;
}

@end
