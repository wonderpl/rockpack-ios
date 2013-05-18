    //
//  SYNVideoViewerViewController.m
//  rockpack
//
//  Created by Nick Banks on 23/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "BBCyclingLabel.h"
#import "Channel.h"
#import "ChannelCover.h"
#import "ChannelOwner.h"
#import "LXReorderableCollectionViewFlowLayout.h"
#import "NSIndexPath+Arithmetic.h"
#import "SYNAbstractViewController.h"
#import "SYNDeviceManager.h"
#import "SYNMasterViewController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNPassthroughView.h"
#import "SYNPopoverBackgroundView.h"
#import "SYNReportConcernTableViewController.h"
#import "SYNVideoPlaybackViewController.h"
#import "SYNVideoThumbnailSmallCell.h"
#import "SYNVideoViewerThumbnailLayout.h"
#import "SYNVideoViewerThumbnailLayoutAttributes.h"
#import "SYNVideoViewerViewController.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import "Video.h"
#import "VideoInstance.h"
#import <MediaPlayer/MediaPlayer.h>

@interface SYNVideoViewerViewController () <UIGestureRecognizerDelegate,
                                            UIPopoverControllerDelegate>

@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, assign) int currentSelectedIndex;
@property (nonatomic, getter = isVideoExpanded) BOOL videoExpanded;
@property (nonatomic, strong) IBOutlet SYNPassthroughView *blackPanelView;
@property (nonatomic, strong) IBOutlet SYNPassthroughView *chromeView;
@property (nonatomic, strong) IBOutlet SYNPassthroughView *passthroughView;
@property (nonatomic, strong) IBOutlet SYNVideoPlaybackViewController *videoPlaybackViewController;
@property (nonatomic, strong) IBOutlet UIButton *nextVideoButton;
@property (nonatomic, strong) IBOutlet UIButton *previousVideoButton;
@property (nonatomic, strong) IBOutlet UIButton *starButton;
@property (nonatomic, strong) IBOutlet UICollectionView *videoThumbnailCollectionView;
@property (nonatomic, strong) IBOutlet UIImageView *channelThumbnailImageView;
@property (nonatomic, strong) IBOutlet UIImageView *panelImageView;
@property (nonatomic, strong) IBOutlet BBCyclingLabel *channelCreatorLabel;
@property (nonatomic, strong) IBOutlet BBCyclingLabel *channelTitleLabel;
@property (nonatomic, strong) IBOutlet BBCyclingLabel *videoTitleLabel;
@property (nonatomic, strong) IBOutlet UIView *swipeView;
@property (nonatomic, strong) NSArray *videoInstanceArray;
@property (nonatomic, strong) SYNReportConcernTableViewController *reportConcernTableViewController;
@property (nonatomic, strong) SYNVideoViewerThumbnailLayout *layout;
@property (nonatomic, strong) IBOutlet UIPopoverController *reportConcernPopoverController;
@property (nonatomic, strong) IBOutlet UIButton* reportConcernButton;
@property (weak, nonatomic) IBOutlet UIButton *addVideoButton;

@end


@implementation SYNVideoViewerViewController 

#pragma mark - Initialisation

- (id) initWithVideoInstanceArray: (NSArray *) videoInstanceArray
                    selectedIndex: (int) selectedIndex;
{
  	if ((self = [super init]))
    {
		self.videoInstanceArray = videoInstanceArray;
        self.currentSelectedIndex = selectedIndex;
	}
    
	return self;
}


#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Google Analytics support
    self.trackedViewName = @"Video Viewer";
    
    BOOL isIPhone = [[SYNDeviceManager sharedInstance] isIPhone];
        BOOL isLandscape = [[SYNDeviceManager sharedInstance] isLandscape];
    
    if (isIPhone)
    {
        // Set custom fonts
        self.channelTitleLabel.font = [UIFont rockpackFontOfSize: 12.0f];
        self.channelCreatorLabel.font = [UIFont rockpackFontOfSize: 10.0f];
        self.videoTitleLabel.font = [UIFont boldRockpackFontOfSize: 16.0f];
        
        // Cross-face transitions
        self.channelTitleLabel.transitionDuration = kTextCrossfadeDuration;
        self.channelCreatorLabel.transitionDuration = kTextCrossfadeDuration;
        self.videoTitleLabel.transitionDuration = kTextCrossfadeDuration;
        
        self.channelTitleLabel.textColor = [UIColor colorWithRed: 234.0f/ 255.0f green: 234.0f/ 255.0f blue: 234.0f/ 255.0f alpha: 1.0f];
        self.channelCreatorLabel.textColor  = [UIColor colorWithRed: 234.0f/ 255.0f green: 234.0f/ 255.0f blue: 234.0f/ 255.0f alpha: 1.0f];
        self.videoTitleLabel.textColor = [UIColor whiteColor];
    }
    else
    {
        // Set custom fonts
        self.channelTitleLabel.font = [UIFont rockpackFontOfSize: 15.0f];
        self.channelCreatorLabel.font = [UIFont rockpackFontOfSize: 12.0f];
        self.videoTitleLabel.font = [UIFont boldRockpackFontOfSize: 25.0f];
        
        // Cross-face transitions
        self.channelTitleLabel.transitionDuration = kTextCrossfadeDuration;
        self.channelCreatorLabel.transitionDuration = kTextCrossfadeDuration;
        self.videoTitleLabel.transitionDuration = kTextCrossfadeDuration;
        
        self.channelTitleLabel.textColor = [UIColor colorWithRed: 185.0f/ 255.0f green: 207.0f/ 255.0f blue: 216.0f/ 255.0f alpha: 1.0f];
        self.channelCreatorLabel.textColor = [UIColor colorWithRed: 108.0f/ 255.0f green: 117.0f/ 255.0f blue: 121.0f/ 255.0f alpha: 1.0f];
        self.channelCreatorLabel.textColor = [UIColor whiteColor];
        self.channelCreatorLabel.text = @"xxxx";
        self.videoTitleLabel.textColor = [UIColor whiteColor];
    }


    // Regster video thumbnail cell
    UINib *videoThumbnailCellNib = [UINib nibWithNibName: @"SYNVideoThumbnailSmallCell"
                                                  bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: videoThumbnailCellNib
                        forCellWithReuseIdentifier: @"SYNVideoThumbnailSmallCell"];
    
    // Set custom flow layout to handle the chroma highlighting
    self.layout = [[SYNVideoViewerThumbnailLayout alloc] init];
    self.layout.itemSize = isIPhone?CGSizeMake(162.0f , 114.0f):CGSizeMake(147.0f , 106.0f);
    self.layout.minimumInteritemSpacing = 2.0f;
    self.layout.minimumLineSpacing = 0.0f;
    self.layout.scrollDirection =  UICollectionViewScrollDirectionHorizontal;
    
    // Fake up an index path from our selected array index
    self.layout.selectedItemIndexPath = [NSIndexPath indexPathForItem: self.currentSelectedIndex
                                                            inSection: 0];
    
    self.videoThumbnailCollectionView.collectionViewLayout = self.layout;
    
    // Create the video playback view controller, and insert it in the right place in the view hierarchy
    CGRect videoFrame, blackPanelFrame;
    UIView *videoView;
    
    if (isIPhone)
    {
        // iPhone
        videoView = self.view;
        videoFrame = self.swipeView.frame;
        videoFrame.size.height = 180.0f;
        blackPanelFrame = CGRectMake(0, 0, 1024, 768);
    }
    else
    {
        videoView = self.passthroughView;
        // iPad
        videoFrame = CGRectMake(142, 71, 739, 416);

        if (isLandscape)
        {
            // Landscape
            
            blackPanelFrame = CGRectMake(0, 0, 1024, 768);
        }
        else
        {
            // Portrait
            blackPanelFrame = CGRectMake(128, -128, 768, 1024);
        }
    }
    
    
    self.blackPanelView = [[SYNPassthroughView alloc] initWithFrame: blackPanelFrame];
    self.blackPanelView.backgroundColor = [UIColor blackColor];
    self.blackPanelView.alpha = 0.0f;
    self.blackPanelView.autoresizingMask = UIViewAutoresizingNone;
    
    [videoView insertSubview: self.blackPanelView
                aboveSubview: self.panelImageView];
    
    self.videoPlaybackViewController = [SYNVideoPlaybackViewController sharedInstance];

    [self.videoPlaybackViewController updateWithFrame: videoFrame
                                         indexUpdater: ^(int newIndex){
                                             self.currentSelectedIndex = newIndex;
                                             [self updateVideoDetailsForIndex: self.currentSelectedIndex];
                                             
                                             // We need to scroll the current thumbnail before the view appears (with no animation)
                                             [self scrollToCellAtIndex: self.currentSelectedIndex
                                                              animated: YES];
                                         }];
    
    self.videoPlaybackViewController.view.autoresizingMask = UIViewAutoresizingNone;

    [videoView insertSubview: self.videoPlaybackViewController.view
                     aboveSubview: self.blackPanelView];
    
    self.addButton.center = CGPointMake(self.videoPlaybackViewController.view.frame.origin.x + self.videoPlaybackViewController.view.frame.size.width - self.addButton.frame.size.width/2.0f, self.videoPlaybackViewController.view.frame.origin.y - self.addButton.frame.size.height/2.0f - 10.f);
    [videoView addSubview:self.addButton];
    
    UISwipeGestureRecognizer* rightSwipeRecogniser = [[UISwipeGestureRecognizer alloc] initWithTarget: self
                                                                                               action: @selector(userTouchedPreviousVideoButton:)];
    
    rightSwipeRecogniser.delegate = self;
    [rightSwipeRecogniser setDirection: UISwipeGestureRecognizerDirectionRight];
    [self.swipeView addGestureRecognizer:rightSwipeRecogniser];
    
    UISwipeGestureRecognizer* leftSwipeRecogniser = [[UISwipeGestureRecognizer alloc] initWithTarget: self
                                                                                              action: @selector(userTouchedNextVideoButton:)];
    
    leftSwipeRecogniser.delegate = self;
    [leftSwipeRecogniser setDirection: UISwipeGestureRecognizerDirectionLeft];
    [self.swipeView addGestureRecognizer: leftSwipeRecogniser];
    
    UITapGestureRecognizer* tapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                                    action: @selector(userTappedVideo)];
    
    tapRecogniser.delegate = self;
    [self.swipeView addGestureRecognizer: tapRecogniser];
    
    VideoInstance *videoInstance = self.videoInstanceArray [self.currentSelectedIndex];

    
    [self.channelThumbnailImageView setImageWithURL: [NSURL URLWithString: videoInstance.channel.channelCover.imageSmallUrl]
                                   placeholderImage: nil
                                            options: SDWebImageRetryFailed];

}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [self.videoPlaybackViewController setPlaylist: self.videoInstanceArray
                                    selectedIndex: self.currentSelectedIndex
                                         autoPlay: TRUE];
    
    if ([[SYNDeviceManager sharedInstance] isIPhone])
    {
        CGRect videoFrame = self.videoPlaybackViewController.view.frame;
        videoFrame.origin = self.swipeView.frame.origin;
        self.videoPlaybackViewController.view.frame = videoFrame;
    }
    
    // Update all the labels corresponding to the selected videos
    [self updateVideoDetailsForIndex: self.currentSelectedIndex];
    
    // We need to scroll the current thumbnail before the view appears (with no animation)
    [self scrollToCellAtIndex: self.currentSelectedIndex
                     animated: YES];
    
    self.addButton.hidden = !self.addVideoButton.selected;
    
}


- (void) viewWillDisappear: (BOOL) animated
{
    // Let's make sure that we stop playing the current video
    self.videoPlaybackViewController = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    [super viewWillDisappear: animated];
}


- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    [super willAnimateRotationToInterfaceOrientation: toInterfaceOrientation
                                            duration: duration];
    
    CGRect blackPanelFrame = self.blackPanelView.frame;
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        // Landscape
        blackPanelFrame = CGRectMake(0, 0, 1024, 768);
        
        if (self.isVideoExpanded)
        {
            self.videoPlaybackViewController.view.transform = CGAffineTransformMakeScale(1.384f, 1.384f);
        }
    }
    else
    {
        // Portrait
        blackPanelFrame = CGRectMake(128, -128, 768, 1024);
        if (self.isVideoExpanded)
        {
            self.videoPlaybackViewController.view.transform = CGAffineTransformMakeScale(1.0392f, 1.0392f);
            self.videoPlaybackViewController.view.center = CGPointMake(512, 374);
        }
    }
    
    self.blackPanelView.frame = blackPanelFrame;
}


#pragma mark - Video playback control

- (void) playVideoAtIndex: (int) index
{
    // We should start playing the selected video and scroll the thumbnnail so that it appears under the arrow
    [self.videoPlaybackViewController playVideoAtIndex: index];
    [self updateVideoDetailsForIndex: index];
    
    [self scrollToCellAtIndex: index
                     animated: YES];
    
    self.currentSelectedIndex = index;
}


#pragma mark - Update index and details

// We need to override the standard setter so that we can update our flow layout for highlighting (colour / monochrome)
- (void) setCurrentSelectedIndex: (int) currentSelectedIndex
{
    // Deselect the old thumbnail (if there is one, and it is not the same as the new one)
    if (_currentSelectedIndex != currentSelectedIndex)
    {
        SYNVideoThumbnailSmallCell *oldCell = (SYNVideoThumbnailSmallCell *)[self.videoThumbnailCollectionView cellForItemAtIndexPath: [NSIndexPath indexPathForItem: _currentSelectedIndex
                                                                                                                                                           inSection: 0]];
        
        // This will trigger a nice face out animation to monochrome
        oldCell.colour = FALSE;
    }
    
    // Now fade up the new image to full colour
    SYNVideoThumbnailSmallCell *newCell = (SYNVideoThumbnailSmallCell *)[self.videoThumbnailCollectionView cellForItemAtIndexPath: [NSIndexPath indexPathForItem: currentSelectedIndex
                                                                                                                                                       inSection: 0]];
    
    newCell.colour = TRUE;
    
    _currentSelectedIndex = currentSelectedIndex;
    
    self.layout.selectedItemIndexPath = [NSIndexPath indexPathForItem: currentSelectedIndex
                                                            inSection: 0];
    
    // Now set the channel thumbail for the new
    VideoInstance *videoInstance = self.videoInstanceArray [currentSelectedIndex];

    
    [self.channelThumbnailImageView setImageWithURL: [NSURL URLWithString: videoInstance.channel.channelCover.imageSmallUrl]
                                   placeholderImage: nil
                                            options: SDWebImageRetryFailed];

}


- (void) updateVideoDetailsForIndex: (int) index
{
    VideoInstance *videoInstance = self.videoInstanceArray [index];
    
    // In video overlay feed display BY followed by username, in video overlay search if no user name display nothing -Kish
    if ([videoInstance.channel.channelOwner.displayName length] == 0) {
        self.channelCreatorLabel.text = videoInstance.channel.channelOwner.displayName;
    }
    else
    {
        self.channelCreatorLabel.text = [NSString stringWithFormat:@"BY %@", videoInstance.channel.channelOwner.displayName];
    }
    
    self.channelTitleLabel.text = videoInstance.channel.title;
    self.videoTitleLabel.text = videoInstance.title;
    self.starButton.selected = videoInstance.video.starredByUserValue;
    self.addVideoButton.selected = [appDelegate.videoQueue videoInstanceIsAddedToChannel:videoInstance];
    self.addButton.hidden = !self.addVideoButton.selected;
}


// The built in UICollectionView scroll to index doesn't work correctly with contentOffset set to non-zero, so roll our own here
- (void) scrollToCellAtIndex: (int) index
                    animated: (BOOL) animated
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem: index
                                                 inSection: 0];
    
    [self.videoThumbnailCollectionView scrollToItemAtIndexPath: indexPath
                                              atScrollPosition: UICollectionViewScrollPositionCenteredHorizontally
                                                      animated: animated];
}


#pragma mark - Collection view support

- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger) section
{
//    DebugLog (@"Items in section %d", self.videoInstanceArray.count);
    return self.videoInstanceArray.count;
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNVideoThumbnailSmallCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNVideoThumbnailSmallCell"
                                                                                 forIndexPath: indexPath];
    
    VideoInstance *videoInstance = self.videoInstanceArray [indexPath.item];
    
    cell.titleLabel.text = videoInstance.title;
    
    SYNVideoViewerThumbnailLayoutAttributes* attributes = (SYNVideoViewerThumbnailLayoutAttributes *)[self.layout layoutAttributesForItemAtIndexPath: indexPath];
    
    BOOL thumbnailIsColour = attributes.isHighlighted;
    
    if (thumbnailIsColour)
    {
        cell.colour = TRUE;
    }
    else
    {
        cell.colour = FALSE;
    }
    
    cell.videoImageViewImage = videoInstance.video.thumbnailURL;
    
    return cell;
}


- (void) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    // We should start playing the selected vide and scroll the thumbnnail so that it appears under the arrow
    [self playVideoAtIndex: indexPath.item];
}


#pragma mark - UICollectionViewDelegateFlowLayout delegates

// A better solution than the previous implementation that used referenceSizeForHeaderInSection and referenceSizeForFooterInSection
- (UIEdgeInsets) collectionView: (UICollectionView *) collectionView
                         layout: (UICollectionViewLayout*) collectionViewLayout
         insetForSectionAtIndex: (NSInteger)section
{
    CGFloat insetWidth = [[SYNDeviceManager sharedInstance] isIPhone] ? 81.0f : 438.0f;
    
    // We only have one section, so add both trailing and leading insets
    return UIEdgeInsetsMake (0, insetWidth, 0, insetWidth );
}


#pragma mark - User actions

- (IBAction) userTouchedNextVideoButton: (id) sender
{
    int index = (self.currentSelectedIndex + 1) % self.videoInstanceArray.count;

    
    [self playVideoAtIndex: index];
}


- (IBAction) userTouchedPreviousVideoButton: (id) sender
{
    int index = self.currentSelectedIndex -  1;
    
    // wrap around if necessary
    if (index < 0)
    {
        index = self.videoInstanceArray.count - 1;
    }
    
    [self playVideoAtIndex: index];
}


- (IBAction) userTouchedVideoAddItButton: (UIButton *) addItButton
{
    
    VideoInstance *videoInstance = self.videoInstanceArray [self.currentSelectedIndex];
    
    if([appDelegate.videoQueue videoInstanceIsAddedToChannel:videoInstance])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: kVideoQueueRemove
                                                        object: self
                                                      userInfo: @{@"VideoInstance" : videoInstance}];
        addItButton.selected = NO;
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: kVideoQueueAdd
                                                            object: self
                                                          userInfo: @{@"VideoInstance" : videoInstance}];
        addItButton.selected = YES;
    }
    self.addButton.hidden = !addItButton.selected;
}


- (IBAction) toggleStarButton: (UIButton *) button
{
    VideoInstance *videoInstance = self.videoInstanceArray [self.currentSelectedIndex];
    
    [appDelegate.oAuthNetworkEngine recordActivityForUserId: appDelegate.currentUser.uniqueId
                                                     action: @"star" videoInstanceId: videoInstance.uniqueId
                                          completionHandler: ^(id response) {
                                              button.selected = !button.selected;
                                              
                                              if (videoInstance.video.starredByUserValue == TRUE)
                                              {
                                                  // Currently highlighted, so decrement
                                                  videoInstance.video.starredByUserValue = FALSE;
                                                  videoInstance.video.starCountValue -= 1;
                                              }
                                              else
                                              {
                                                  // Currently highlighted, so increment
                                                  videoInstance.video.starredByUserValue = TRUE;
                                                  videoInstance.video.starCountValue += 1;
                                              }
                                              
                                              [self updateVideoDetailsForIndex: self.currentSelectedIndex];
                                              
                                              [appDelegate saveContext:YES];
                                              
                                          } errorHandler: ^(id error) {
                                              NSLog(@"Could not star video");
                                          }];
}

- (IBAction) userTouchedCloseButton: (id) sender
{
    // Call the close method on our parent
    [self.overlayParent removeVideoOverlayController];
}


// The user touched the invisible button above the channel thumbnail, taking the user to the channel page
- (IBAction) userTouchedChannelButton: (id) sender
{
    [self.overlayParent removeVideoOverlayController];
    
    // Get the video instance for the currently selected video
    VideoInstance *videoInstance = self.videoInstanceArray [self.currentSelectedIndex];
    
    [(SYNAbstractViewController *)self.overlayParent.originViewController viewChannelDetails: videoInstance.channel];
}


// The user touched the invisible button above the user details, taking the user to the profile page
- (IBAction) userTouchedProfileButton: (id) sender
{
    [self.overlayParent removeVideoOverlayController];
    
    // Get the video instance for the currently selected video
    VideoInstance *videoInstance = self.videoInstanceArray [self.currentSelectedIndex];
    
    [(SYNAbstractViewController *)self.overlayParent.originViewController viewProfileDetails: videoInstance.channel.channelOwner];
}


- (void) userTappedVideo
{
    if ([[SYNDeviceManager sharedInstance] isIPad])
    {
        // iPad
        if (self.isVideoExpanded)
        {
            if ([[SYNDeviceManager sharedInstance] isLandscape])
            {
                // Landscape
                [UIView transitionWithView: self.view
                                  duration: 0.5f
                                   options: UIViewAnimationOptionCurveEaseInOut
                                animations: ^ {
                                    self.blackPanelView.alpha = 0.0f;
                                    self.chromeView.alpha = 1.0f;
                                    self.swipeView.frame =  CGRectMake(172, 142, 676, 295);
                                    self.blackPanelView.frame = CGRectMake(0, 0, 1024, 768);
                                    self.videoPlaybackViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                    self.videoPlaybackViewController.view.center = CGPointMake(512, 279);
                                    self.videoPlaybackViewController.shuttleBarView.alpha = 1.0f;
                                }
                                completion: nil];
            }
            else
            {
                // Portrait
                [UIView transitionWithView: self.view
                                  duration: 0.5f
                                   options: UIViewAnimationOptionCurveEaseInOut
                                animations: ^ {
                                    self.blackPanelView.alpha = 0.0f;
                                    self.chromeView.alpha = 1.0f;
                                    self.swipeView.frame =  CGRectMake(172, 142, 676, 295);
                                    self.blackPanelView.frame = CGRectMake(128, -128, 768, 1024);
                                    self.videoPlaybackViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                    self.videoPlaybackViewController.view.center = CGPointMake(512, 279);
                                    self.videoPlaybackViewController.shuttleBarView.alpha = 1.0f;
                                }
                                completion: nil];
            }
        }
        else
        {
            if ([[SYNDeviceManager sharedInstance] isLandscape])
            {
                // Landscape
                [UIView transitionWithView: self.view
                                  duration: 0.5f
                                   options: UIViewAnimationOptionCurveEaseInOut
                                animations: ^ {
                                    self.blackPanelView.alpha = 1.0f;
                                    self.chromeView.alpha = 0.0f;
                                    self.swipeView.frame =  CGRectMake(0, 0, 1024, 768);
                                    self.blackPanelView.frame = CGRectMake(0, 0, 1024, 768);
                                    self.videoPlaybackViewController.view.transform = CGAffineTransformMakeScale(1.384f, 1.384f);
                                    self.videoPlaybackViewController.view.center = CGPointMake(512, 374);
                                    self.videoPlaybackViewController.shuttleBarView.alpha = 0.0f;
                                }
                                completion: nil];
            }
            else
            {
                // Portrait
                [UIView transitionWithView: self.view
                                  duration: 0.5f
                                   options: UIViewAnimationOptionCurveEaseInOut
                                animations: ^ {
                                    self.blackPanelView.alpha = 1.0f;
                                    self.chromeView.alpha = 0.0f;
                                    self.swipeView.frame =  CGRectMake(0, 0, 1024, 768);
                                    self.blackPanelView.frame = CGRectMake(128, -128, 768, 1024);
                                    self.videoPlaybackViewController.view.transform = CGAffineTransformMakeScale(1.0392f, 1.0392f);
                                    self.videoPlaybackViewController.view.center = CGPointMake(512, 374);
                                    self.videoPlaybackViewController.shuttleBarView.alpha = 0.0f;
                                }
                                completion: nil];
            }
        }
    }
    else
    {
        // iPhone
        if (self.isVideoExpanded)
        {
            [UIView transitionWithView: self.view
                              duration: 0.5f
                               options: UIViewAnimationOptionCurveEaseInOut
                            animations: ^ {
                                self.blackPanelView.alpha = 0.0f;
                                self.chromeView.alpha = 1.0f;
                                self.swipeView.transform = CGAffineTransformIdentity;
                                self.videoPlaybackViewController.view.transform = self.swipeView.transform;
                                self.swipeView.frame = self.originalFrame;
                                CGRect videoFrame = self.videoPlaybackViewController.view.frame;
                                videoFrame.origin = self.originalFrame.origin;
                                self.videoPlaybackViewController.view.frame = videoFrame;
                                self.videoPlaybackViewController.shuttleBarView.alpha = 1.0f;
                            }
                            completion: nil];
        }
        else
        {
            self.originalFrame = self.swipeView.frame;
            [UIView transitionWithView: self.view
                              duration: 0.5f
                               options: UIViewAnimationOptionCurveEaseInOut
                            animations: ^ {
                                CGRect fullScreenFrame = CGRectMake(0,0,[[SYNDeviceManager sharedInstance] currentScreenHeight]-20.0f, [[SYNDeviceManager sharedInstance] currentScreenWidth]);
                                if(fullScreenFrame.size.width < fullScreenFrame.size.height)
                                {
                                    //Device orientation may confuse screen dimensions. Ensure the width is always the larger dimension.
                                    fullScreenFrame = CGRectMake(0,0,[[SYNDeviceManager sharedInstance] currentScreenWidth]-20.0f, [[SYNDeviceManager sharedInstance] currentScreenHeight]);
                                }
                                self.blackPanelView.alpha = 1.0f;
                                self.chromeView.alpha = 0.0f;
                                self.swipeView.frame =  fullScreenFrame;
                                self.swipeView.center = CGPointMake(fullScreenFrame.size.height/2.0f,fullScreenFrame.size.width/2.0f);
                                self.videoPlaybackViewController.view.center =self.swipeView.center;
                                self.swipeView.transform = CGAffineTransformMakeRotation(M_PI_2);
                                CGFloat scaleFactor = fullScreenFrame.size.width/self.videoPlaybackViewController.view.frame.size.width;
                                self.videoPlaybackViewController.view.transform = CGAffineTransformScale(self.swipeView.transform,scaleFactor,scaleFactor);
                                self.videoPlaybackViewController.shuttleBarView.alpha = 0.0f;
                            }
                            completion: nil];
        }
        
    }
    
    self.videoExpanded = !self.videoExpanded;
}


- (IBAction) userTouchedVideoShareButton: (UIButton *) videoShareButton
{
    VideoInstance *videoInstance = self.videoInstanceArray [self.currentSelectedIndex];
    
    [self shareVideoInstance: videoInstance
                     inView: self.chromeView
                    fromRect: videoShareButton.frame
             arrowDirections: UIPopoverArrowDirectionDown];
}

- (IBAction) userTouchedReportConcernButton: (UIButton*) button
{
    button.selected = !button.selected;
    
    if (button.selected)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            // Create out concerns table view controller
            self.reportConcernTableViewController = [[SYNReportConcernTableViewController alloc]
                                                     initWithSendReportBlock: ^ (NSString *reportString){
                                                         [self.reportConcernPopoverController dismissPopoverAnimated: YES];
                                                         [self reportConcern: reportString];
                                                         self.reportConcernButton.selected = FALSE;
                                                     }
                                                     cancelReportBlock: ^{
                                                         [self.reportConcernPopoverController dismissPopoverAnimated: YES];
                                                         self.reportConcernButton.selected = FALSE;
                                                     }];
            
            // Wrap it in a navigation controller
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController: self.reportConcernTableViewController];
            
            // Hard way of adding a title (need to due to custom font offsets)
            UIView *containerView = [[UIView alloc] initWithFrame: CGRectMake (0, 0, 80, 28)];
            containerView.backgroundColor = [UIColor clearColor];
            UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake (0, 4, 80, 28)];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont boldRockpackFontOfSize: 20.0];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor blackColor];
            label.shadowColor = [UIColor whiteColor];
            label.shadowOffset = CGSizeMake(0.0, 1.0);
            label.text = NSLocalizedString(@"REPORT", nil);
            [containerView addSubview: label];
            self.reportConcernTableViewController.navigationItem.titleView = containerView;
            
            // Need show the popover controller
            self.reportConcernPopoverController = [[UIPopoverController alloc] initWithContentViewController: navController];
            self.reportConcernPopoverController.popoverContentSize = CGSizeMake(245, 344);
            self.reportConcernPopoverController.delegate = self;
            self.reportConcernPopoverController.popoverBackgroundViewClass = [SYNPopoverBackgroundView class];
            
            // Now present appropriately
            [self.reportConcernPopoverController presentPopoverFromRect: button.frame
                                                                 inView: self.chromeView
                                               permittedArrowDirections: UIPopoverArrowDirectionDown
                                                               animated: YES];
        }
        else
        {
            SYNMasterViewController *masterViewController = (SYNMasterViewController*)appDelegate.masterViewController;
            
            self.reportConcernTableViewController = [[SYNReportConcernTableViewController alloc] initWithNibName: @"SYNReportConcernTableViewControllerFullScreen~iphone"
                                                                                                          bundle: [NSBundle mainBundle]
                                                                                                 sendReportBlock: ^ (NSString *reportString){
                                                                                                     [UIView animateWithDuration: kChannelEditModeAnimationDuration
                                                                                                                      animations: ^{
                                                                                                                          // Fade out the category tab controller
                                                                                                                          self.reportConcernTableViewController.view.alpha = 0.0f;
                                                                                                                      }
                                                                                                                      completion: nil];
                                                                                                     self.reportConcernButton.selected = FALSE;
                                                                                                     [self reportConcern: reportString];
                                                                                                 }
                                                                                               cancelReportBlock: ^{
                                                                                                   [UIView animateWithDuration: kChannelEditModeAnimationDuration
                                                                                                                    animations: ^{
                                                                                                                        // Fade out the category tab controller
                                                                                                                        self.reportConcernTableViewController.view.alpha = 0.0f;
                                                                                                                    }
                                                                                                                    completion: ^(BOOL success){
                                                                                                                        [self.reportConcernTableViewController.view removeFromSuperview];
                                                                                                                    }];
                                                                                                   self.reportConcernButton.selected = FALSE;
                                                                                               }];
            
            
            // Move off the bottom of the screen
            CGRect startFrame = self.reportConcernTableViewController.view.frame;
            startFrame.origin.y = self.view.frame.size.height;
            self.reportConcernTableViewController.view.frame = startFrame;
            
            [masterViewController.view addSubview: self.reportConcernTableViewController.view];
            
            // Slide up onto the screen
            [UIView animateWithDuration: 0.3f
                                  delay: 0.0f
                                options: UIViewAnimationOptionCurveEaseOut
                             animations: ^{
                                 CGRect endFrame = self.reportConcernTableViewController.view.frame;
                                 endFrame.origin.y = 0.0f;
                                 self.reportConcernTableViewController.view.frame = endFrame;
                             }
                             completion: nil];
        }
    }
}


- (void) reportConcern: (NSString *) reportString
{
    VideoInstance *videoInstance = self.videoInstanceArray [self.currentSelectedIndex];
    
    [appDelegate.oAuthNetworkEngine reportConcernForUserId: appDelegate.currentOAuth2Credentials.userId
                                                objectType: @"video"
                                                  objectId: videoInstance.video.uniqueId
                                                    reason: reportString
                                         completionHandler: ^(NSDictionary *dictionary){
                                             DebugLog(@"Concern successfully reported");
                                         }
                                              errorHandler: ^(NSError* error) {
                                                  DebugLog(@"Report concern failed");
                                                  DebugLog(@"%@", [error debugDescription]);
                                              }];
}

- (BOOL) needsAddButton
{
    return YES;
}

@end
