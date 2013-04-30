//
//  SYNAbstractChannelsDetailViewController.m
//  rockpack
//
//  Created by Nick Banks on 17/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "Channel.h"
#import "ChannelOwner.h"
#import "ChannelCover.h"
#import "SYNCategoriesTabViewController.h"
#import "SYNChannelDetailViewController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNVideoThumbnailRegularCell.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+ImageProcessing.h"
#import "Video.h"
#import "VideoInstance.h"
#import "SYNCoverThumbnailCell.h"
#import <QuartzCore/QuartzCore.h>
#import "SYNDeviceManager.h"

@interface SYNChannelDetailViewController ()

@property (nonatomic, assign)  CGPoint originalContentOffset;
@property (nonatomic, assign)  kChannelDetailsMode mode;
@property (nonatomic, weak) Channel *channel;
@property (nonatomic, strong) IBOutlet UIButton *addToChannelButton;
@property (nonatomic, strong) IBOutlet UIButton *createChannelButton;
@property (nonatomic, strong) IBOutlet UIButton *buyButton;
@property (nonatomic, strong) IBOutlet UIButton *shareButton;
@property (nonatomic, strong) IBOutlet UIButton* subscribeButton;
@property (nonatomic, strong) IBOutlet UICollectionView *coverThumbnailCollectionView;
@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet UIImageView *channelCoverImageView;
@property (nonatomic, strong) IBOutlet UILabel *channelDetailsLabel;
@property (nonatomic, strong) IBOutlet UILabel *channelOwnerLabel;
@property (nonatomic, strong) IBOutlet UITextView *channelTitleTextView;
@property (nonatomic, strong) IBOutlet UIView *avatarBackgroundView;
@property (nonatomic, strong) IBOutlet UIView *coverChooserMasterView;
@property (nonatomic, strong) IBOutlet UIView *displayControlsView;
@property (nonatomic, strong) IBOutlet UIView *editControlsView;
@property (nonatomic, strong) IBOutlet UIView *masterControlsView;
@property (nonatomic, strong) NSFetchedResultsController *channelCoverFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *userChannelCoverFetchedResultsController;
@property (nonatomic, strong) SYNCategoriesTabViewController *categoriesTabViewController;
@property (weak, nonatomic) IBOutlet UILabel *byLabel;

@end


@implementation SYNChannelDetailViewController

@synthesize channelCoverFetchedResultsController = _channelCoverFetchedResultsController;
@synthesize userChannelCoverFetchedResultsController = _userChannelCoverFetchedResultsController;

- (id) initWithChannel: (Channel *) channel
             usingMode: (kChannelDetailsMode) mode
{

    if ((self = [super initWithViewId: kChannelDetailsViewId]))
    {
		self.channel = channel;
        self.mode = mode;
	}

	return self;
}


#pragma mark - View lifecyle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    BOOL isIPhone= [[SYNDeviceManager sharedInstance] isIPhone];
    
    // Google Analytics support
    self.trackedViewName = @"Channels - Detail";
    
    // Originally the opacity was required to be 0.25f, but this appears less visible on the actual screen
    // Set custom fonts and shadows for labels
    self.channelOwnerLabel.font = [UIFont boldRockpackFontOfSize: self.channelOwnerLabel.font.pointSize];
    [self addShadowToLayer: self.channelOwnerLabel.layer];
    
    self.channelDetailsLabel.font = [UIFont rockpackFontOfSize: self.channelDetailsLabel.font.pointSize];
    [self addShadowToLayer: self.channelDetailsLabel.layer];
    
    self.byLabel.font = [UIFont rockpackFontOfSize: self.byLabel.font.pointSize];
    
    // Add Rockpack font and shadow to UITextView
    self.channelTitleTextView.font = [UIFont rockpackFontOfSize: self.channelTitleTextView.font.pointSize];
    [self addShadowToLayer: self.channelTitleTextView.layer];
    
    // Needed for shadows to work
    self.channelTitleTextView.backgroundColor = [UIColor clearColor];
    
    // Shadow for avatar background
    [self addShadowToLayer: self.avatarBackgroundView.layer];
    
    // Add a custom flow layout to our thumbail collection view (with the right size and spacing)
    LXReorderableCollectionViewFlowLayout *layout = [[LXReorderableCollectionViewFlowLayout alloc] init];
    layout.itemSize = isIPhone?CGSizeMake(158.0f , 86.0f):CGSizeMake(256.0f , 179.0f);
    layout.minimumInteritemSpacing = 0.0f;
    layout.minimumLineSpacing = isIPhone ? 4.0f : 0.0f;
    
    self.videoThumbnailCollectionView.collectionViewLayout = layout;
    
    if (isIPhone)
    {
        layout.sectionInset = UIEdgeInsetsMake(0.0f, 2.0f, 0.0f, 2.0f);
        self.videoThumbnailCollectionView.contentInset = UIEdgeInsetsMake([[SYNDeviceManager sharedInstance] currentScreenHeight] - 110.0f, 0.0f, 0.0f, 0.0f);
    }
    
    // Regster video thumbnail cell
    UINib *videoThumbnailCellNib = [UINib nibWithNibName: @"SYNVideoThumbnailRegularCell"
                                                  bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: videoThumbnailCellNib
                        forCellWithReuseIdentifier: @"SYNVideoThumbnailRegularCell"];
    
    // Register cover thumbnail cell
    
    // Regster video thumbnail cell
    UINib *coverThumbnailCellNib = [UINib nibWithNibName: @"SYNCoverThumbnailCell"
                                                  bundle: nil];
    
    [self.coverThumbnailCollectionView registerNib: coverThumbnailCellNib
                        forCellWithReuseIdentifier: @"SYNCoverThumbnailCell"];
    
    // Set wallpaper
    [self.channelCoverImageView setAsynchronousImageFromURL: [NSURL URLWithString: self.channel.wallpaperURL]
                                           placeHolderImage: nil];
    
    // Set wallpaper
    [self.avatarImageView setAsynchronousImageFromURL: [NSURL URLWithString: self.channel.channelOwner.thumbnailURL]
                                     placeHolderImage: nil];
    
    // Store the initial content offset, so that we can fade out the control if the user scrolls away from this
    self.originalContentOffset = self.videoThumbnailCollectionView.contentOffset;
    
    // Create categories tab, but make invisible (alpha = 0) for now
    self.categoriesTabViewController = [[SYNCategoriesTabViewController alloc] init];
    self.categoriesTabViewController.delegate = self;
    CGRect tabFrame = self.categoriesTabViewController.view.frame;
    tabFrame.origin.y = kChannelCreationCategoryTabOffsetY;
    self.categoriesTabViewController.view.frame = tabFrame;
    [self.view addSubview: self.categoriesTabViewController.view];
    self.categoriesTabViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.categoriesTabViewController.view.alpha = 0.0f;
    [self addChildViewController: self.categoriesTabViewController];
    
    if (self.mode == kChannelDetailsModeDisplay)
    {
        self.addToChannelButton.hidden = NO;
        self.createChannelButton.hidden = YES;
    }
    else
    {
        self.addToChannelButton.hidden = YES;
        self.createChannelButton.hidden = NO;
        
    }
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(mainContextDataChanged:)
                                                 name: NSManagedObjectContextDidSaveNotification
                                               object: self.channel.managedObjectContext];
    
    // Use KVO on the collection view to detect user scrolling (to fade out overlaid controls)
    [self.videoThumbnailCollectionView addObserver: self
                                        forKeyPath: kCollectionViewContentOffsetKey
                                           options: NSKeyValueObservingOptionNew
                                           context: nil];
    
    if ([self.channel.subscribedByUser boolValue])
    {
        self.subscribeButton.selected = YES;
    }
    else
    {
        self.subscribeButton.selected = NO;
    }
    
    [self.channel addObserver: self
                   forKeyPath: kSubscribedByUserKey
                      options: NSKeyValueObservingOptionNew
                      context :nil];
    
    // We set up assets depending on whether we are in display or edit mode
    [self setDisplayControlsVisibility: (self.mode == kChannelDetailsModeDisplay) ? TRUE: FALSE];
    
    // Refresh our view
    [self.videoThumbnailCollectionView reloadData];
    
    // Only do this is we have a resource URL (i.e. we haven't just created the channel)
    
    if(self.mode == kChannelDetailsModeDisplay)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kChannelUpdateRequest object:self userInfo:@{kChannel:self.channel}];
    }
    
    
    [self displayChannelDetails];
}


- (void) viewWillDisappear: (BOOL) animated
{
    
    [self.videoThumbnailCollectionView removeObserver: self
                                           forKeyPath: kCollectionViewContentOffsetKey];

    [self.channel removeObserver: self
                      forKeyPath: kSubscribedByUserKey];

    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: NSManagedObjectContextDidSaveNotification
                                                  object: self.channel.managedObjectContext];
    [super viewWillDisappear: animated];
}

- (void) mainContextDataChanged: (NSNotification*) notification
{
    if (!notification)
        return;
    
    if (notification.object == self.channel.managedObjectContext)
    {
        [self reloadCollectionViews];
    }
}


- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{
    if (controller == self.fetchedResultsController)
    {
        startAnimationDelay = 0.0;
        [self reloadCollectionViews];
    }
    else if ((controller == self.channelCoverFetchedResultsController) || (controller == self.userChannelCoverFetchedResultsController))
    {
         [self.coverThumbnailCollectionView reloadData];
    }
    else
    {
        AssertOrLog(@"Received update from unexpected fetched results controller")
    }
    
}


- (void) reloadCollectionViews
{
    [self.videoThumbnailCollectionView reloadData];
    
    [self displayChannelDetails];
}


#pragma mark - VIEW helper methods

- (void) addShadowToLayer: (CALayer *) layer
{
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    layer.shadowOpacity = 0.3f;
    layer.shadowRadius = 2.0f;
}

- (void) displayChannelDetails
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
    // Check to see what collection this concerns
    if (collectionView == self.coverThumbnailCollectionView)
    {
        // Video thumbnails
        switch (section)
        {
            case 0:
            {
                return 1;
            }
            break;
                
            case 1:
            {
                id <NSFetchedResultsSectionInfo> sectionInfo = self.userChannelCoverFetchedResultsController.sections [0];
                return sectionInfo.numberOfObjects;
            }
            break;
                
            case 2:
            {
                id <NSFetchedResultsSectionInfo> sectionInfo = self.channelCoverFetchedResultsController.sections [0];
                return sectionInfo.numberOfObjects;
            }
                break;
                
            default:
            {
                AssertOrLog(@"Shouldn't have more than two sections");
                return 0;
            }
            break;
        }
    }
    else
    {
        // Video thumbnails
        switch (section)
        {
            case 0:
            {
                return self.channel.videoInstances.count;
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
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    // Check to see what collection this concerns
    if (collectionView == self.coverThumbnailCollectionView)
    {
        // There are two sections for cover thumbnails, the first represents 'no cover' the second contains all images
        return 3;
    }
    else
    {
        // Only one sectino for video thumbnails
        return 1;
    }
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    // Check to see what collection this concerns
    if (collectionView == self.coverThumbnailCollectionView)
    {
        SYNCoverThumbnailCell *coverThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNCoverThumbnailCell"
                                                                                              forIndexPath: indexPath];
        
        // There are two sections for cover thumbnails, the first represents 'no cover' the second contains all images
        switch (indexPath.section)
        {
            case 0:
            {               
                coverThumbnailCell.coverImageView.image = [UIImage imageNamed: @"ChannelCreationCoverNone.png"];
                return coverThumbnailCell;
            }
            break;
                
            case 1:
            {
                // User channel covers
                ChannelCover *channelCover = [self.userChannelCoverFetchedResultsController objectAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row
                                                                                                        inSection: 0]];
                
                coverThumbnailCell.coverImageWithURLString = channelCover.carouselURL;
                return coverThumbnailCell;
            }
            break;
                
            case 2:
            {
                // Rockpack channel covers
                ChannelCover *channelCover = [self.channelCoverFetchedResultsController objectAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row
                                                                                                                  inSection: 0]];
                
                coverThumbnailCell.coverImageWithURLString = channelCover.carouselURL;
                return coverThumbnailCell;
            }
            break;
                
            default:
            {
                AssertOrLog(@"Shouldn't have more than two sections");
                return 0;
            }
            break;
        }
    }
    else
    {
        UICollectionViewCell *cell = nil;
        
        SYNVideoThumbnailRegularCell *videoThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNVideoThumbnailRegularCell"
                                                                                                     forIndexPath: indexPath];
        videoThumbnailCell.displayMode = (self.mode == kChannelDetailsModeDisplay) ?
                                                        kChannelThumbnailDisplayModeStandard: kChannelThumbnailDisplayModeEdit;
        
        VideoInstance *videoInstance = self.channel.videoInstances [indexPath.item];
        videoThumbnailCell.videoImageViewImage = videoInstance.video.thumbnailURL;
        videoThumbnailCell.titleLabel.text = videoInstance.title;
        videoThumbnailCell.viewControllerDelegate = self;
        
        cell = videoThumbnailCell;
        
        return cell;
    }
}


- (void) collectionView: (UICollectionView *) collectionView
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (collectionView == self.coverThumbnailCollectionView)
    {
        // Ensure that the cell we have selected is fully on-screen
        [self.coverThumbnailCollectionView scrollToItemAtIndexPath: indexPath
                                                  atScrollPosition: UICollectionViewScrollPositionNone
                                                          animated: YES];
    }
    else
    {
        [self displayVideoViewerWithVideoInstanceArray: self.channel.videoInstances.array
                                      andSelectedIndex: indexPath.item];
    }
}

#pragma mark - Fetched results controller




- (NSFetchedResultsController *) channelCoverFetchedResultsController
{
    if (_channelCoverFetchedResultsController)
        return _channelCoverFetchedResultsController;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    
    fetchRequest.entity = [NSEntityDescription entityForName: @"ChannelCover"
                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat: [NSString stringWithFormat: @"viewId == \"%@\"", kCoverArtViewId]];
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"position" ascending: YES]];
    
    self.channelCoverFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                        managedObjectContext: appDelegate.mainManagedObjectContext
                                                                          sectionNameKeyPath: nil
                                                                                   cacheName: nil];
    self.channelCoverFetchedResultsController.delegate = self;
    
    
    NSError *error = nil;
    
    ZAssert([_channelCoverFetchedResultsController performFetch: &error], @"Channels Details Failed: %@\n%@", [error localizedDescription], [error userInfo]);
    
    return _channelCoverFetchedResultsController;
}

- (NSFetchedResultsController *) userChannelCoverFetchedResultsController
{
    if (_userChannelCoverFetchedResultsController)
        return _userChannelCoverFetchedResultsController;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName: @"ChannelCover"
                                                         inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    fetchRequest.entity = entityDescription;
    
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat: [NSString stringWithFormat: @"viewId == \"%@\"", kUserCoverArtViewId]];
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"position" ascending: YES]];
    
    self.userChannelCoverFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                                    managedObjectContext: appDelegate.mainManagedObjectContext
                                                                                      sectionNameKeyPath: nil
                                                                                               cacheName: nil];
    self.userChannelCoverFetchedResultsController.delegate = self;
    
    
    NSError *error = nil;
    
    ZAssert([_userChannelCoverFetchedResultsController performFetch: &error], @"Channels Details Failed: %@\n%@", [error localizedDescription], [error userInfo]);
    
    return _userChannelCoverFetchedResultsController;
}

#pragma mark - Helper methods

- (void) reorderVideoInstances
{
    // Now we need to update the 'position' for each of the objects (so that we can keep in step with getFetchedResultsController
    // Do this with block enumeration for speed
    [self.channel.videoInstances enumerateObjectsUsingBlock: ^(id obj, NSUInteger index, BOOL *stop) {
        [(VideoInstance *)obj setPositionValue : index];
    }];
    
}


#pragma mark - LXReorderableCollectionViewDelegateFlowLayout methods

- (void) collectionView: (UICollectionView *) collectionView
        itemAtIndexPath: (NSIndexPath *) fromIndexPath
    willMoveToIndexPath: (NSIndexPath *) toIndexPath {

    
    NSMutableOrderedSet* mutableInstance = [[NSMutableOrderedSet alloc] initWithOrderedSet:self.channel.videoInstances];
    
    [mutableInstance exchangeObjectAtIndex: fromIndexPath.item
                         withObjectAtIndex: toIndexPath.item];
    
    self.channel.videoInstances = [[NSOrderedSet alloc] initWithOrderedSet: mutableInstance];
    
    // Now we need to update the 'position' for each of the objects (so that we can keep in step with getFetchedResultsController
    // Do this with block enumeration for speed
    [self reorderVideoInstances];
}


- (void) setDisplayControlsVisibility: (BOOL) visible
{
    // Support for different appearances / functionality of textview
    self.channelTitleTextView.textColor = (visible) ? [UIColor whiteColor] : [UIColor blackColor];
    self.channelTitleTextView.userInteractionEnabled = (visible) ? NO : YES;

    self.displayControlsView.alpha = (visible) ? 1.0f : 0.0f;
    self.editControlsView.alpha = (visible) ? 0.0f : 1.0f;
    self.coverChooserMasterView.hidden = (visible) ? TRUE : FALSE;
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
    else if ([keyPath isEqualToString: kSubscribedByUserKey])
    {
        NSNumber* newSubscribedByUserValue = (NSNumber*)[change valueForKey: NSKeyValueChangeNewKey];
        BOOL finalValue = [newSubscribedByUserValue boolValue];
        if (finalValue)
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


- (IBAction) addButtonTapped: (id) sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kChannelSubscribeRequest
                                                        object: self
                                                      userInfo: @{ kChannel : self.channel }];
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
    VideoInstance *videoInstance = self.channel.videoInstances [indexPath.row];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: noteName
                                                        object: self
                                                      userInfo: @{@"VideoInstance" : videoInstance}];
    
    addButton.selected = !addButton.selected;
}


- (void) videoDeleteButtonTapped: (UIButton *) deleteButton
{
    UIView *v = deleteButton.superview.superview;
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: v.center];
    
    VideoInstance* instanceToDelete = (VideoInstance*)[self.channel.videoInstances objectAtIndex: indexPath.item];
    
    NSMutableOrderedSet *channelsSet = [NSMutableOrderedSet orderedSetWithOrderedSet: self.channel.videoInstances];
    
    [channelsSet removeObject: instanceToDelete];
    
    [self.channel setVideoInstances: channelsSet];
    
    [self reloadCollectionViews];
}


- (IBAction) addCoverButtonTapped: (UIButton *) button
{
    [self showCoverChooser];
    [self hideCategoryChooser];
}


- (IBAction) selectCategoryButtonTapped: (UIButton *) button
{
    [self showCategoryChooser];
    [self hideCoverChooser];
}


#pragma mark - Cover choice

- (void) showCoverChooser
{
    if (self.coverChooserMasterView.alpha == 0.0f)
    {
        
        // Update the list of cover art
        [appDelegate.networkEngine updateCoverArtOnCompletion: ^{
            DebugLog(@"Success");
        }
                                                      onError: ^(NSError* error) {
                                                          DebugLog(@"%@", [error debugDescription]);
                                                      }];
        
        [appDelegate.oAuthNetworkEngine updateCoverArtForUserId: appDelegate.currentOAuth2Credentials.userId
                                                   onCompletion: ^{
                                                       DebugLog(@"Success");
                                                   }
                                                        onError: ^(NSError* error) {
                                                            DebugLog(@"%@", [error debugDescription]);
                                                        }];

        self.originalContentOffset = CGPointMake (0, kChannelCreationCollectionViewOffsetY +
                                                     kChannelCreationCategoryAdditionalOffsetY);
        
        [UIView animateWithDuration: kChannelEditModeAnimationDuration
                         animations: ^{
                             // Fade up the category tab controller
                             self.coverChooserMasterView.alpha = 1.0f;
                             
                             // slide down the video collection view a bit
                             self.videoThumbnailCollectionView.contentInset = UIEdgeInsetsMake(kChannelCreationCollectionViewOffsetY +
                                                                                               kChannelCreationCategoryAdditionalOffsetY, 0, 0, 0);
                             
                             self.videoThumbnailCollectionView.contentOffset = CGPointMake (0, -(kChannelCreationCollectionViewOffsetY +
                                                                                                 kChannelCreationCategoryAdditionalOffsetY));
                         }
                         completion: nil];
    }
}

- (void) hideCoverChooser
{
    if (self.coverChooserMasterView.alpha == 1.0f)
    {
        [UIView animateWithDuration: kChannelEditModeAnimationDuration
                         animations: ^{
                             // Fade out the category tab controller
                             self.coverChooserMasterView.alpha = 0.0f;
                         }
                         completion: nil];
    }
}


#pragma mark - Category choice

- (void) showCategoryChooser
{
    if (self.categoriesTabViewController.view.alpha == 0.0f)
    {
        [UIView animateWithDuration: kChannelEditModeAnimationDuration
                         animations: ^{
                             // Fade up the category tab controller
                             self.categoriesTabViewController.view.alpha = 1.0f;
                             
                             // slide down the video collection view a bit
                             self.videoThumbnailCollectionView.contentInset = UIEdgeInsetsMake(kChannelCreationCollectionViewOffsetY +
                                                                                               kChannelCreationCategoryAdditionalOffsetY, 0, 0, 0);
                             
                             self.videoThumbnailCollectionView.contentOffset = CGPointMake (0, -(kChannelCreationCollectionViewOffsetY +
                                                                                                 kChannelCreationCategoryAdditionalOffsetY));
                         }
                         completion: nil];
    }

}


- (void) hideCategoryChooser
{
    if (self.categoriesTabViewController.view.alpha == 1.0f)
    {
        [UIView animateWithDuration: kChannelEditModeAnimationDuration
                         animations: ^{
                             // Fade out the category tab controller
                             self.categoriesTabViewController.view.alpha = 0.0f;
                         }
                         completion: nil];
    }
}

- (void) resetVideoCollectionViewPosition
{
    [UIView animateWithDuration: kChannelEditModeAnimationDuration
                     animations: ^{
                         // Fade out the category tab controller
                         self.categoriesTabViewController.view.alpha = 0.0f;
                         
                         // slide up the video collection view a bit ot its original position
                         self.videoThumbnailCollectionView.contentOffset = CGPointMake (0, kChannelCreationCollectionViewOffsetY);
                         
                         self.videoThumbnailCollectionView.contentOffset = CGPointMake (0, -(kChannelCreationCollectionViewOffsetY));
                     }
                     completion: nil];
}

- (BOOL) showSubcategories
{
    return YES;
}

- (void) handleMainTap: (UITapGestureRecognizer*) recogniser
{
    
}

- (void) handleSecondaryTap: (UITapGestureRecognizer*) recogniser
{
    
}

// general
- (void) handleNewTabSelectionWithId: (NSString*) temId
{
    
}


#pragma mark - Channel Creation (3 steps)

- (IBAction) createChannelPressed: (id) sender
{
    self.channel.title = self.channelTitleTextView.text;
    self.channel.channelDescription = @"Test Description";
    
    [appDelegate.oAuthNetworkEngine createChannelForUserId: appDelegate.currentOAuth2Credentials.userId
                                                     title: self.channel.title
                                               description: (self.channel.channelDescription)
                                                  category: @"222"
                                                     cover: @""
                                                  isPublic: YES
                                         completionHandler:^(NSDictionary* resourceCreated) {
                                             
            
                                             NSString* channelId = [resourceCreated objectForKey:@"id"];
                                             
                                             [self addVideosToNewChannelForId:channelId];
                                             
                                             
                                         } errorHandler:^(id error) {
                                             
                                             DebugLog(@"Error @ createChannelPressed:");
                                             
                                             
                                         }];
}

- (void) addVideosToNewChannelForId: (NSString*) channelId
{
    [appDelegate.oAuthNetworkEngine updateVideosForChannelForUserId: appDelegate.currentOAuth2Credentials.userId
                                                          channelId: channelId
                                                   videoInstanceSet: self.channel.videoInstances
                                                  completionHandler: ^(id response) {
                                                      // a 204 returned
                                                      
                                                      [self getNewlyCreatedChannelForId:channelId];
                                                  }
                                                       errorHandler:^(id err) {
                                                           
                                                           DebugLog(@"Error @ addVideosToNewChannelForId:");
                                                           
                                                       }];
    
    
}

- (void) getNewlyCreatedChannelForId: (NSString*) channelId
{

    [appDelegate.oAuthNetworkEngine channelCreatedForUserId:appDelegate.currentOAuth2Credentials.userId
                                                  channelId:channelId
                                          completionHandler:^(id dictionary) {
                                              
                                              
                                              Channel* createdChannel = [Channel instanceFromDictionary: dictionary
                                                                              usingManagedObjectContext: appDelegate.mainManagedObjectContext
                                                                                           channelOwner: appDelegate.currentUser
                                                                                              andViewId: kChannelDetailsViewId];
                                              
                                              DebugLog(@"Channel: %@", createdChannel);
                                              
                                              [appDelegate saveContext:YES];
                                              
                                              
                                          } errorHandler:^(id err) {
                                              
                                              DebugLog(@"Error @ getNewlyCreatedChannelForId:");
                                              
                                          }];

}

@end
