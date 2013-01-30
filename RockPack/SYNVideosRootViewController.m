//
//  SYNDiscoverTopTabViewController.m
//  RockPack
//
//  Created by Nick Banks on 16/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "AudioToolbox/AudioToolbox.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "SYNAppDelegate.h"
#import "SYNBottomTabViewController.h"
#import "SYNVideosRootViewController.h"
#import "SYNNetworkEngine.h"
#import "SYNVideoQueueCell.h"
#import "SYNVideoDB.h"
#import "SYNVideoThumbnailWideCell.h"
#import "SYNWallpackCarouseHorizontallLayout.h"
#import "SYNWallpackCarouselCell.h"
#import "UIFont+SYNFont.h"
#import "Video.h"
#import "VideoInstance.h"
#import <MediaPlayer/MediaPlayer.h>

@interface SYNVideosRootViewController () <UIGestureRecognizerDelegate,
                                           UIScrollViewDelegate,
                                           UIWebViewDelegate>

@property (nonatomic, assign, getter = isLargeVideoViewExpanded) BOOL largeVideoViewExpanded;
@property (nonatomic, strong) IBOutlet UIButton *rockItButton;
@property (nonatomic, strong) IBOutlet UIButton *shareItButton;
@property (nonatomic, strong) IBOutlet UIImageView *channelImageView;
@property (nonatomic, strong) IBOutlet UIImageView *videoPlaceholderImageView;
@property (nonatomic, strong) IBOutlet UILabel *channelLabel;
@property (nonatomic, strong) IBOutlet UILabel *rockItLabel;
@property (nonatomic, strong) IBOutlet UILabel *rockItNumberLabel;
@property (nonatomic, strong) IBOutlet UILabel *shareItLabel;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *userNameLabel;
@property (nonatomic, strong) IBOutlet UIView *largeVideoPanelView;
@property (nonatomic, strong) IBOutlet UIWebView *videoWebView;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, strong) IBOutlet UIButton *largeVideoPlayButton;

@end

@implementation SYNVideosRootViewController

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];

    // Set the labels to use the custom font
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: 17.0f];
    self.channelLabel.font = [UIFont rockpackFontOfSize: 14.0f];
    self.userNameLabel.font = [UIFont rockpackFontOfSize: 12.0f];
    self.rockItLabel.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.shareItLabel.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.rockItNumberLabel.font = [UIFont boldRockpackFontOfSize: 20.0f];
    
    
    // Set up large video view
    self.videoWebView.backgroundColor = [UIColor blackColor];
	self.videoWebView.opaque = NO;
    self.videoWebView.scrollView.scrollEnabled = false;
    self.videoWebView.scrollView.bounces = false;
    self.videoWebView.alpha = 0.0f;
    self.videoWebView.delegate = self;
    self.largeVideoPlayButton.alpha = 1.0f;
    self.largeVideoPlayButton.enabled = FALSE;

    // Init video thumbnail collection view
    UINib *videoThumbnailCellNib = [UINib nibWithNibName: @"SYNVideoThumbnailWideCell"
                                                  bundle: nil];

    [self.videoThumbnailCollectionView registerNib: videoThumbnailCellNib
                        forCellWithReuseIdentifier: @"SYNVideoThumbnailWideCell"];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    // TODO: Remove this video download hack once we have real data from the API
//    [[SYNVideoDB sharedVideoDBManager] downloadContentIfRequiredDisplayingHUDInView: self.view];
    SYNAppDelegate *appDelegate = UIApplication.sharedApplication.delegate;
    
    [appDelegate.networkEngine updateHomeScreen];
    [appDelegate.networkEngine updateChannelScreen];
    
    // Set the first video
    if (self.videoInstanceFetchedResultsController.fetchedObjects.count > 0)
    {
        [self setLargeVideoToIndexPath: [NSIndexPath indexPathForRow: 0
                                                           inSection: 0]];
    }
}


- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    [self.videoThumbnailCollectionView reloadData];
}


- (BOOL) hasVideoQueue
{
    return TRUE;
}


#pragma mark - Core Data support

- (NSPredicate *) videoInstanceFetchedResultsControllerPredicate
{
    //    // No predicate
    //    return nil;
    return [NSPredicate predicateWithFormat: @"viewId == \"Home\""];
}


- (NSArray *) videoInstanceFetchedResultsControllerSortDescriptors
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"dateAdded"
                                                                   ascending: NO];
    return @[sortDescriptor];
}

- (NSString *) videoInstanceFetchedResultsControllerSectionNameKeyPath
{
    //    return @"daysAgo";
    return nil;
}


- (void) reloadCollectionViews
{
    [self.videoThumbnailCollectionView reloadData];
}


#pragma mark - Collection view support

- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger) section
{
    // See if this can be handled in our abstract base class
    int items = [super collectionView: collectionView
               numberOfItemsInSection:  section];
    
    if (items < 0)
    {
        if (collectionView == self.videoThumbnailCollectionView)
        {
            id <NSFetchedResultsSectionInfo> sectionInfo = [self.videoInstanceFetchedResultsController sections][section];
            items = [sectionInfo numberOfObjects];
        }
        else
        {
            AssertOrLog(@"No valid collection view found");
        }
    }
    
    return items;
}

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    // See if this can be handled in our abstract base class
    UICollectionViewCell *cell = [super collectionView: collectionView
                                cellForItemAtIndexPath: indexPath];
    
    // Do we have a valid cell?
    if (!cell)
    {
        AssertOrLog(@"No valid collection view found");
    }
    
    return cell;
}


- (void) collectionView: (UICollectionView *) collectionView
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    // See if this can be handled in our abstract base class
    BOOL handledInSuperview = [super collectionView: (UICollectionView *) collectionView
                   didSelectItemAtIndexPathAbstract: (NSIndexPath *) indexPath];
    
    if (!handledInSuperview)
    {
        // Check to see if is one that we can handle
        if (collectionView == self.videoThumbnailCollectionView)
        {
            [self setLargeVideoToIndexPath: indexPath];
        }
        else
        {
            AssertOrLog(@"Trying to select unexpected collection view");
        }
    }
}


#pragma mark - User interface

- (void) setLargeVideoToIndexPath: (NSIndexPath *) indexPath
{
    if ([self.currentIndexPath isEqual: indexPath] == FALSE)
    {        
        self.currentIndexPath = indexPath;
        
        [self updateLargeVideoDetailsForIndexPath: indexPath];
        
        VideoInstance *videoInstance = [self.videoInstanceFetchedResultsController objectAtIndexPath: indexPath];
        
        [self loadWebViewWithJSAPIUsingYouTubeId: videoInstance.video.sourceId
                                           width: 494
                                          height: 278];
    }
}


- (IBAction) longPressLargeVideo: (UIGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        // figure out which item in the table was selected
        
        self.inDrag = YES;
        
        // Store the initial drag point, just in case we have to animate it back if the user misses the drop zone
        self.initialDragCenter = [sender locationInView: self.view];
        
        // Hardcoded for now, eeek!
        CGRect frame = CGRectMake(self.initialDragCenter.x - 63, self.initialDragCenter.y - 36, 123, 69);
        self.draggedView = [[UIImageView alloc] initWithFrame: frame];
        self.draggedView.alpha = 0.7;
        
        Video *video = [self.videoInstanceFetchedResultsController objectAtIndexPath: self.currentIndexPath];
        self.draggedView.image = video.thumbnailImage;
        
        // now add the item to the view
        [self.view addSubview: self.draggedView];
        
        // Highlight the image well
        [self highlightVideoQueue: TRUE];
    }
    else if (sender.state == UIGestureRecognizerStateChanged && self.inDrag)
    {
        // we dragged it, so let's update the coordinates of the dragged view
        CGPoint point = [sender locationInView: self.view];
        self.draggedView.center = point;
    }
    else if (sender.state == UIGestureRecognizerStateEnded && self.inDrag)
    {
        // Un-highlight the image well
        [self highlightVideoQueue: FALSE];
        
        // and let's figure out where we dropped it
//        CGPoint point = [sender locationInView: self.dropZoneView];
        CGPoint point = [sender locationInView: self.view];
        
        // If we have dropped it in the right place, then add it to our image well
        if ([self pointInVideoQueue: point])
            
        {
            // Hide the dragged thumbnail and add new image to image well
            [self.draggedView removeFromSuperview];
            [self addToVideoQueueFromLargeVideo: nil];
        }
        else
        {
            [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                                  delay: 0.0f
                                options: UIViewAnimationOptionCurveEaseInOut
                             animations: ^
             {
                 // Contract thumbnail view
                 self.draggedView.center = self.initialDragCenter;
                 
             }
                             completion: ^(BOOL finished)
             {
                 [self.draggedView removeFromSuperview];
             }];
        }
    }
}

- (void) displayVideoViewerFromView: (UIGestureRecognizer *) sender
{
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: [sender locationInView: self.videoThumbnailCollectionView]];
    
    [self setLargeVideoToIndexPath: indexPath];
}

- (IBAction) addToVideoQueueFromLargeVideo: (id) sender
{
    VideoInstance *videoInstance = [self.videoInstanceFetchedResultsController objectAtIndexPath: self.currentIndexPath];
    [self animateVideoAdditionToVideoQueue: videoInstance];
}


- (void) updateLargeVideoDetailsForIndexPath: (NSIndexPath *) indexPath
{
    VideoInstance *videoInstance = [self.videoInstanceFetchedResultsController objectAtIndexPath: indexPath];
    
    self.titleLabel.text = videoInstance.title;
    self.channelLabel.text = videoInstance.channel.title;
    self.userNameLabel.text = videoInstance.channel.channelOwner.name;
    
    [self.channelImageView setImageFromURL: [NSURL URLWithString: videoInstance.channel.thumbnailURL]
                          placeHolderImage: nil];
    
    [self updateLargeVideoRockpackForIndexPath: indexPath];
}


- (void) updateLargeVideoRockpackForIndexPath: (NSIndexPath *) indexPath
{
    VideoInstance *videoInstance = [self.videoInstanceFetchedResultsController objectAtIndexPath: indexPath];
    
    self.rockItNumberLabel.text = [NSString stringWithFormat: @"%@", videoInstance.video.starCount];
    self.rockItButton.selected = videoInstance.video.starredByUserValue;
}



- (void) setSelectedIndex: (NSUInteger) newSelectedIndex
                 animated: (BOOL) animated
{
    if (newSelectedIndex != NSNotFound)
    {
        [self highlightTab: newSelectedIndex];
        
        // We need to change the search criteria here to relect the change in genre
        
        [self.videoThumbnailCollectionView reloadData];
    }
}


- (void) toggleRockItAtIndex: (NSIndexPath *) indexPath
{
    VideoInstance *videoInstance = [self.videoInstanceFetchedResultsController objectAtIndexPath: indexPath];
    
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
    
    [self saveDB];
}


- (void) updateOtherOnscreenVideoAssetsForIndexPath: (NSIndexPath *) indexPath
{
    if ([indexPath isEqual: self.currentIndexPath])
    {
        [self updateLargeVideoRockpackForIndexPath: self.currentIndexPath];
    }
}



- (IBAction) toggleLargeVideoPanelStarItButton: (UIButton *) button
{
    button.selected = !button.selected;
    
    [self toggleRockItAtIndex: self.currentIndexPath];
    [self updateLargeVideoDetailsForIndexPath: self.currentIndexPath];
    [self.videoThumbnailCollectionView reloadData];
    
    [self saveDB];
}


// Buttons activated from scrolling list of thumbnails

#pragma mark - Video queue animation

- (void) slideVideoQueueUp
{
     CGRect videoQueueViewFrame = self.videoQueueView.frame;
     videoQueueViewFrame.origin.y -= kVideoQueueEffectiveHeight;
     self.videoQueueView.frame = videoQueueViewFrame;

     CGRect viewFrame = self.largeVideoPanelView.frame;
     viewFrame.size.height -= kVideoQueueEffectiveHeight;
     self.largeVideoPanelView.frame = viewFrame;

     viewFrame = self.videoThumbnailCollectionView.frame;
     viewFrame.size.height -= kVideoQueueEffectiveHeight;
     self.videoThumbnailCollectionView.frame = viewFrame;
}


- (void) slideVideoQueueDown
{
    CGRect videoQueueViewFrame = self.videoQueueView.frame;
    videoQueueViewFrame.origin.y += kVideoQueueEffectiveHeight;
    self.videoQueueView.frame = videoQueueViewFrame;
    
    // Slide video queue view downwards (and expand any other dependent visible views)
    CGRect viewFrame = self.largeVideoPanelView.frame;
    viewFrame.size.height += kVideoQueueEffectiveHeight;
    self.largeVideoPanelView.frame = viewFrame;
    
    viewFrame = self.videoThumbnailCollectionView.frame;
    viewFrame.size.height += kVideoQueueEffectiveHeight;
    self.videoThumbnailCollectionView.frame = viewFrame;
}


#pragma mark - Video support

- (void) loadWebViewWithIFrameUsingYouTubeId: (NSString *) videoId
                                       width: (int) width
                                      height: (int) height
{
    NSDictionary *parameterDictionary = @{@"autoplay" : @"1",
                                          @"modestbranding" : @"1",
                                          @"origin" : @"http://example.com\\",
                                          @"showinfo" : @"0"};
    
    NSString *parameterString = [self createParamStringFromDictionary: parameterDictionary];
    
    NSError *error = nil;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource: @"YouTubeIFramePlayer"
                                                         ofType: @"html"];
    
    NSString *templateHTMLString = [NSString stringWithContentsOfFile: fullPath
                                                             encoding: NSUTF8StringEncoding
                                                                error: &error];
    
    NSString *iFrameHTML = [NSString stringWithFormat: templateHTMLString, width, height, videoId, parameterString];
    
    [self.videoWebView loadHTMLString: iFrameHTML
                              baseURL: nil];
}


- (void) loadWebViewWithJSAPIUsingYouTubeId: (NSString *) videoId
                                      width: (int) width
                                     height: (int) height
{
    NSError *error = nil;
    
    // Show placeholder, but not webview (wait until that has loaded)
    self.videoWebView.alpha = 0.0f;
    self.videoPlaceholderImageView.alpha = 1.0f;
    self.largeVideoPlayButton.alpha = 1.0f;
    
    // Setup placeholder
    // http://img.youtube.com/vi/<videoid>/0.jpg
    
    NSString *placeholderURLString = [NSString stringWithFormat: @"http://img.youtube.com/vi/%@/0.jpg", videoId];
    
    [self.videoPlaceholderImageView setImageFromURL: [NSURL URLWithString: placeholderURLString]
                                   placeHolderImage: nil];
    
    // Now set up web view
    NSString *fullPath = [[NSBundle mainBundle] pathForResource: @"YouTubeJSAPIPlayerNoAutoplay"
                                                         ofType: @"html"];
    
    NSString *templateHTMLString = [NSString stringWithContentsOfFile: fullPath
                                                             encoding: NSUTF8StringEncoding
                                                                error: &error];
    
    NSString *iFrameHTML = [NSString stringWithFormat: templateHTMLString, width, height, videoId];
    
    [self.videoWebView loadHTMLString: iFrameHTML
                              baseURL: [NSURL URLWithString:@"http://www.youtube.com"]];
    
    self.videoWebView.mediaPlaybackRequiresUserAction = FALSE;
}


- (void) loadWebViewWithIFrameUsingVimeoId: (NSString *) videoId
                                     width: (int) width
                                    height: (int) height
{
    NSString *parameterString = @"";
    
    NSError *error = nil;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource: @"VimeoIFramePlayer"
                                                         ofType: @"html"];
    
    NSString *templateHTMLString = [NSString stringWithContentsOfFile: fullPath
                                                             encoding: NSUTF8StringEncoding
                                                                error: &error];
    
    NSString *iFrameHTML = [NSString stringWithFormat: templateHTMLString, videoId, parameterString, width, height];
    
    [self.videoWebView loadHTMLString: iFrameHTML
                              baseURL: nil];
}


- (NSString *) createParamStringFromDictionary: (NSDictionary *) params
{
    __block NSString *result = @"";
    
    [params enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop)
     {
         result = [result stringByAppendingFormat: @"%@=%@&", key, obj];
     }];
    
    // Chop off last ampersand
    result = [result substringToIndex: [result length] - 2];
    return [result stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
}


- (BOOL) webView: (UIWebView *) webView
         shouldStartLoadWithRequest: (NSURLRequest *) request
         navigationType: (UIWebViewNavigationType) navigationType
{
    // Break apart request URL
    NSString *requestString = [[request URL] absoluteString];
    NSArray *components = [requestString componentsSeparatedByString :@":"];
    
    // Check for your protocol
    if ([components count] >= 3 && [(NSString *)[components objectAtIndex:0] isEqualToString: @"rockpack"])
    {
        // Look for specific actions
        NSString *parameter2 = (NSString *)[components objectAtIndex: 1];
        if ([parameter2 isEqualToString: @"onStateChange"])
        {            
            NSString *parameter3 = (NSString *)[components objectAtIndex: 2];
            
            NSLog (@"Components %@", components);
            
            if ([parameter3 isEqualToString: @"1"])
            {
                
                [UIView animateWithDuration: 0.25f
                                      delay: 0.0f
                                    options: UIViewAnimationOptionCurveEaseInOut
                                 animations: ^
                 {
                    [self.videoWebView stringByEvaluatingJavaScriptFromString: @"pauseVideo()"];
//                    self.largeVideoPlayButton.alpha = 1.0f;
                 }
                 completion: ^(BOOL finished)
                 {
                     self.largeVideoPlayButton.enabled = TRUE;
                 }];
            }
        }
        
        // Return 'NO' to prevent navigation
        return NO;
    }
    
    // Return 'YES', navigate to requested URL as normal
    return YES;
}

- (IBAction) playLargeVideo: (id) sender
{

    
    [UIView animateWithDuration: 0.25f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         [self.videoWebView stringByEvaluatingJavaScriptFromString: @"playVideo()"];
         
         // Contract thumbnail view
         self.videoWebView.alpha = 1.0;
         self.videoPlaceholderImageView.alpha = 0.0f;
         self.largeVideoPlayButton.alpha = 0.0f;
     }
                     completion: ^(BOOL finished)
     {
        self.largeVideoPlayButton.enabled = FALSE;
     }];

}


@end
