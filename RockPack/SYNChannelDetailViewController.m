//
//  SYNAbstractChannelsDetailViewController.m
//  rockpack
//
//  Created by Nick Banks on 17/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "Channel.h"
#import "ChannelOwner.h"
#import "SYNChannelDetailViewController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNVideoThumbnailRegularCell.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+ImageProcessing.h"
#import "Video.h"
#import "VideoInstance.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNChannelDetailViewController ()

@property (nonatomic, assign)  CGPoint originalContentOffset;
@property (nonatomic, strong) Channel *channel;
@property (nonatomic, strong) IBOutlet UIButton *buyButton;
@property (nonatomic, strong) IBOutlet UIButton *shareButton;
@property (nonatomic, strong) IBOutlet UIButton* subscribeButton;
@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet UIImageView *channelCoverImageView;
@property (nonatomic, strong) IBOutlet UILabel *channelDetailsLabel;
@property (nonatomic, strong) IBOutlet UILabel *channelOwnerLabel;
@property (nonatomic, strong) IBOutlet UITextView *channelTitleTextView;
@property (nonatomic, strong) IBOutlet UIView *avatarBackgroundView;
@property (nonatomic, strong) IBOutlet UIView *displayControlsView;
@property (nonatomic, strong) IBOutlet UIView *editControlsView;
@property (nonatomic, strong) IBOutlet UIView *masterControlsView;
@property (strong, nonatomic) NSMutableArray *videoInstances;

@end


@implementation SYNChannelDetailViewController

- (id) initWithChannel: (Channel *) channel
{

    if ((self = [super init]))
    {
		self.channel = channel;
	}

	return self;
}


#pragma mark - View lifecyle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Google Analytics support
    self.trackedViewName = @"Channels - Detail";
    
    // Originally the opacity was required to be 0.25f, but this appears less visible on the actual screen
    // Set custom fonts and shadows for labels
    self.channelOwnerLabel.font = [UIFont boldRockpackFontOfSize: 18.0f];
    [self addShadowToLayer: self.channelOwnerLabel.layer];
    
    self.channelDetailsLabel.font = [UIFont rockpackFontOfSize: 15.0f];
    [self addShadowToLayer: self.channelDetailsLabel.layer];
    
    // Add Rockpack font and shadow to UITextView
    self.channelTitleTextView.font = [UIFont rockpackFontOfSize: 55.0f];
    [self addShadowToLayer: self.channelTitleTextView.layer];
    
    // Needed for shadows to work
    self.channelTitleTextView.backgroundColor = [UIColor clearColor];
    
    // Shadow for avatar background
    [self addShadowToLayer: self.avatarBackgroundView.layer];
    
    // Add a custom flow layout to our thumbail collection view (with the right size and spacing)
    LXReorderableCollectionViewFlowLayout *layout = [[LXReorderableCollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(256.0f , 179.0f);
    layout.minimumInteritemSpacing = 0.0f;
    layout.minimumLineSpacing = 0.0f;
    
    self.videoThumbnailCollectionView.collectionViewLayout = layout;
    
    // Regster video thumbnail cell
    UINib *videoThumbnailCellNib = [UINib nibWithNibName: @"SYNVideoThumbnailRegularCell"
                                                  bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: videoThumbnailCellNib
                        forCellWithReuseIdentifier: @"SYNVideoThumbnailRegularCell"];
    
    // Set wallpaper
    [self.channelCoverImageView setAsynchronousImageFromURL: [NSURL URLWithString: self.channel.wallpaperURL]
                                           placeHolderImage: nil];
    
    // Set wallpaper
    [self.avatarImageView setAsynchronousImageFromURL: [NSURL URLWithString: self.channel.channelOwner.thumbnailURL]
                                     placeHolderImage: nil];
    
    // Store the initial content offset, so that we can fade out the control if the user scrolls away from this
    self.originalContentOffset = self.videoThumbnailCollectionView.contentOffset;
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    self.videoInstances = [[NSMutableArray alloc] initWithCapacity: self.channel.videoInstances.count];
    
    // There are some intricacies here with regards to NSOrderedSetProxies being returned, so we have to do this the hard way
    
    // First, sort the array in 'position' order
    NSArray *sortedArray = [self.channel.videoInstances.array sortedArrayUsingComparator: ^NSComparisonResult(id a, id b) {
        NSNumber *first = [(VideoInstance *)a position];
        NSNumber *second = [(VideoInstance *)b position];
        return [first compare: second];
    }];
    
    // Now add those videoinstances to our own mutable array
    for (VideoInstance *videoInstance in sortedArray)
    {
        [self.videoInstances addObject: videoInstance];
    }
    
    // Look out for update notifications
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(reloadCollectionViews)
                                                 name: kDataUpdated
                                               object: nil];
    
    // Use KVO on the collection view to detect user scrolling (to fade out overlaid controls)
    [self.videoThumbnailCollectionView addObserver: self
                                        forKeyPath: kCollectionViewContentOffsetKey
                                           options: NSKeyValueObservingOptionNew
                                           context: nil];
    
    if([self.channel.subscribedByUser boolValue])
    {
        self.subscribeButton.selected = YES;
    }
    else
    {
        self.subscribeButton.selected = NO;
    }
    
    [self.channel addObserver: self
                   forKeyPath: @"subscribedByUser"
                      options: NSKeyValueObservingOptionNew
                      context :nil];
    
    // FIXME: Move out to subclass is there is a distinct display view, overridden by edit subclass
    [self setDisplayControlsVisibility: TRUE];
    
    // Refresh our view
    [self.videoThumbnailCollectionView reloadData];
    
    // Only do this is we have a resource URL (i.e. we haven't just created the channel)
    
    if (self.channel.resourceURL != nil && ![self.channel.resourceURL isEqualToString: @""])
    {
        if ([self.channel.resourceURL hasPrefix: @"https"])
        {
            [appDelegate.oAuthNetworkEngine updateChannel: self.channel.resourceURL
                                        completionHandler: ^(NSDictionary *responseDictionary) {
                                            // Save the position for back-patching in later
                                            NSNumber *savedPosition = self.channel.position;
                                            
                                            [self.channel setAttributesFromDictionary: responseDictionary
                                                                               withId: self.channel.uniqueId
                                                            usingManagedObjectContext: appDelegate.mainManagedObjectContext
                                                                  ignoringObjectTypes: kIgnoreNothing
                                                                            andViewId: kChannelDetailsViewId];
                                            
                                            // Back-patch a few things that may have been overwritten
                                            self.channel.position = savedPosition;
                                            self.channel.viewId = kChannelsViewId;
                                            
                                            self.videoInstances = [[NSMutableArray alloc] initWithCapacity: self.channel.videoInstances.count];
                                            
                                            for (VideoInstance *videoInstance in self.channel.videoInstances)
                                            {
                                                [self.videoInstances addObject: videoInstance];
                                            }
                                            
                                            [self reloadCollectionViews];
                                        }
                                             errorHandler: ^(NSDictionary* errorDictionary) {
                                                 DebugLog(@"Update action failed");
                                             }];

        }
        else
        {
            [appDelegate.networkEngine updateChannel: self.channel.resourceURL
                                   completionHandler: ^(NSDictionary *responseDictionary) {
                                       // Save the position for back-patching in later
                                       NSNumber *savedPosition = self.channel.position;
                                       
                                       [self.channel setAttributesFromDictionary: responseDictionary
                                                                          withId: self.channel.uniqueId
                                                       usingManagedObjectContext: appDelegate.mainManagedObjectContext
                                                             ignoringObjectTypes: kIgnoreNothing
                                                                       andViewId: kChannelDetailsViewId];
                                       
                                       // Back-patch a few things that may have been overwritten
                                       self.channel.position = savedPosition;
                                       self.channel.viewId = kChannelsViewId;
                                       
                                       self.videoInstances = [[NSMutableArray alloc] initWithCapacity: self.channel.videoInstances.count];
                                       
                                       for (VideoInstance *videoInstance in self.channel.videoInstances)
                                       {
                                           [self.videoInstances addObject: videoInstance];
                                       }
                                       
                                       [self reloadCollectionViews];
                                   }
                                        errorHandler: ^(NSDictionary* errorDictionary) {
                                            DebugLog(@"Update action failed");
                                        }];

        }
    }
    
    [self updateChannelDetails];
}


- (void) viewWillDisappear: (BOOL) animated
{
    self.videoInstances = nil;
    
    [self.channel removeObserver: self
                      forKeyPath: @"subscribedByUser"];
    
    [self.videoThumbnailCollectionView removeObserver: self
                                           forKeyPath: kCollectionViewContentOffsetKey];
    
    [self.channel removeObserver:self
                      forKeyPath:@"subscribedByUser"];
    
    // Remove update notification observer
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kDataUpdated
                                                  object: nil];
    [super viewWillDisappear: animated];
}


- (void) reloadCollectionViews
{
    [self.videoThumbnailCollectionView reloadData];
    
    [self updateChannelDetails];
}


#pragma mark - VIEW helper methods

- (void) addShadowToLayer: (CALayer *) layer
{
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    layer.shadowOpacity = 0.3f;
    layer.shadowRadius = 2.0f;
}

- (void) updateChannelDetails
{
    self.channelOwnerLabel.text = self.channel.channelOwner.displayName;
    
    NSString *detailsString = [NSString stringWithFormat: @"%d VIDEOS / %d SUBSCRIBERS", self.channel.videoInstancesSet.count, 0];
    self.channelDetailsLabel.text = detailsString;
    
    // If we have a valid ecommerce URL, then display the button
    if (self.channel.eCommerceURL != nil && ![self.channel.eCommerceURL isEqualToString: @""])
    {
        self.buyButton.hidden = FALSE;
    }
    
    self.channelTitleTextView.text = self.channel.title;
}


#pragma mark - Collection view support

- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger) section
{
    switch (section)
    {
        case 0:
        {
            return self.videoInstances.count;
        }
        break;
            
        default:
        {
            AssertOrLog(@"Shouldn't have more than one section");
            return 0;
        }
        break;
    }
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    UICollectionViewCell *cell = nil;
    
    SYNVideoThumbnailRegularCell *videoThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNVideoThumbnailRegularCell"
                                                                                                 forIndexPath: indexPath];
    
    VideoInstance *videoInstance = self.videoInstances [indexPath.row];
    videoThumbnailCell.videoImageViewImage = videoInstance.video.thumbnailURL;
    videoThumbnailCell.titleLabel.text = videoInstance.title;
    
    cell = videoThumbnailCell;
    
    return cell;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *) fetchedResultsController
{
    
    
    if (fetchedResultsController)
        return fetchedResultsController;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    
    fetchRequest.entity = [NSEntityDescription entityForName: @"VideoInstance"
                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat: @"channel.uniqueId == \"%@\"", self.channel.uniqueId]];
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"position" ascending: YES]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                        managedObjectContext: appDelegate.mainManagedObjectContext
                                                                          sectionNameKeyPath: nil
                                                                                   cacheName: nil];
    fetchedResultsController.delegate = self;
    
    
    NSError *error = nil;
    ZAssert([fetchedResultsController performFetch: &error], @"Channels Details Failed: %@\n%@", [error localizedDescription], [error userInfo]);
    
    return fetchedResultsController;
}



- (void) collectionView: (UICollectionView *) collectionView
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
        // Display the video viewer
        [self displayVideoViewerWithSelectedIndexPath: indexPath];
}


#pragma mark - LXReorderableCollectionViewDelegateFlowLayout methods

- (void) collectionView: (UICollectionView *) collectionView
        itemAtIndexPath: (NSIndexPath *) fromIndexPath
    willMoveToIndexPath: (NSIndexPath *) toIndexPath
{
    id fromItem = [self.videoInstances objectAtIndex: fromIndexPath.item];
    
    [self.videoInstances removeObjectAtIndex: fromIndexPath.item];
    
    [self.videoInstances insertObject: fromItem
                              atIndex: toIndexPath.item];
    
    // Now we need to update the 'position' for each of the objects (so that we can keep in step with getFetchedResultsController
    // Do this with block enumeration for speed
    [self.videoInstances enumerateObjectsUsingBlock: ^(id obj, NSUInteger index, BOOL *stop) {
        [(VideoInstance *)obj setPositionValue : index];
    } ];
}


- (void) setDisplayControlsVisibility: (BOOL) visible
{
    // Support for different appearances / functionality of textview
    self.channelTitleTextView.textColor = (visible) ? [UIColor whiteColor] : [UIColor blackColor];
    self.channelTitleTextView.userInteractionEnabled = (visible) ? NO : YES;

    self.displayControlsView.alpha = (visible) ? 1.0f : 0.0f;
    self.editControlsView.alpha = (visible) ? 0.0f : 1.0f;
}


// For edit controls just do the inverse of details control
- (void) setEditControlsVisibility: (BOOL) visible
{
    [self setDisplayControlsVisibility: !visible];
}


- (void) enterEditMode
{
    [UIView animateWithDuration: kChannelEditModeAnimationDuration
                     animations: ^{
                         [self setEditControlsVisibility: TRUE];
                     }
                     completion: nil];
}


- (void) leaveEditMode
{
    [UIView animateWithDuration: kChannelEditModeAnimationDuration
                     animations: ^{
                         [self setDisplayControlsVisibility: TRUE];
                     }
                     completion: nil];
}


#pragma mark - KVO support

// We face out all controls/information views when the user starts scrolling the videos collection view
// but monitoring the collectionview content offset using KVO
- (void) observeValueForKeyPath: (NSString *) keyPath
                       ofObject: (id) object
                         change: (NSDictionary *) change
                        context: (void *) context
{
    if ([keyPath isEqualToString: kCollectionViewContentOffsetKey])
    {
        CGPoint newContentOffset = [[change valueForKey: NSKeyValueChangeNewKey] CGPointValue];

        if (newContentOffset.y <= self.originalContentOffset.y)
        {
            self.masterControlsView.alpha = 1.0f;
        }
        else
        {
            CGFloat differenceInY = - (self.originalContentOffset.y - newContentOffset.y);
            // kChannelDetailsFadeSpan
            if (differenceInY < kChannelDetailsFadeSpan)
            {
                self.masterControlsView.alpha = 1 - (differenceInY / kChannelDetailsFadeSpan);
            }
            else
            {
                self.masterControlsView.alpha = 0.0f;
            }
        }
    }
    else if ([keyPath isEqualToString:@"subscribedByUser"])
    {
        NSNumber* newSubscribedByUserValue = (NSNumber*)[change valueForKey: NSKeyValueChangeNewKey];
        BOOL finalValue = [newSubscribedByUserValue boolValue];
        if(finalValue)
        {
            self.subscribeButton.selected = YES;
        }
        else
        {
            self.subscribeButton.selected = NO;
        }
    }
}


#pragma mark - Control Delegate

- (IBAction) shareChannelButtonTapped: (id) sender
{
    NSString *messageString = kChannelShareMessage;
    
    //  TODO: Put in cover art image?
    //  UIImage *messageImage = [UIImage imageNamed: @"xyz.png"];
    
    // TODO: Put in real link
    NSURL *messageURL = [NSURL URLWithString: @"http://www.rockpack.com"];
    
    [self shareURL: messageURL
       withMessage: messageString
          fromRect: self.shareButton.frame
   arrowDirections: UIPopoverArrowDirectionDown];
}


// If the buy button is visible, then (hopefully) we have a valid URL
// But check to see that it should open anyway
- (IBAction) buyButtonTapped: (id) sender
{
    [self initiatePurchaseAtURL: [NSURL URLWithString: self.channel.eCommerceURL]];
}


- (IBAction) subscribeButtonTapped: (id) sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kChannelSubscribeRequest
                                                        object: self
                                                      userInfo: @{ kChannel : self.channel }];
}





@end
