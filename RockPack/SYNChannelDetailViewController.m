//
//  SYNAbstractChannelsDetailViewController.m
//  rockpack
//
//  Created by Nick Banks on 17/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "Channel.h"
#import "ChannelCover.h"
#import "ChannelOwner.h"
#import "CoverArt.h"
#import "GKImagePicker.h"
#import "Genre.h"
#import "SSTextView.h"
#import "SYNCameraPopoverViewController.h"
#import "SYNCategoriesTabViewController.h"
#import "SYNChannelCategoryTableViewController.h"
#import "SYNChannelCoverImageSelectorViewController.h"
#import "SYNChannelDetailViewController.h"
#import "SYNCoverThumbnailCell.h"
#import "SYNDeviceManager.h"
#import "SYNMasterViewController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNPopoverBackgroundView.h"
#import "SYNReportConcernTableViewController.h"
#import "SYNVideoThumbnailRegularCell.h"
#import "SubGenre.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import "Video.h"
#import "VideoInstance.h"
#import "SYNCoverChooserController.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

@interface SYNChannelDetailViewController () <UITextViewDelegate,
                                              GKImagePickerDelegate,
                                              UIPopoverControllerDelegate,
                                              SYNCameraPopoverViewControllerDelegate,
                                              SYNChannelCategoryTableViewDelegate,
                                              SYNChannelCoverImageSelectorDelegate>


@property (nonatomic, assign)  CGPoint originalContentOffset;
@property (nonatomic, assign, getter = isImageSelectorOpen) BOOL imageSelectorOpen;
@property (nonatomic, strong) GKImagePicker *imagePicker;
@property (nonatomic, strong) IBOutlet SSTextView *channelTitleTextView;
@property (nonatomic, strong) IBOutlet UIButton *buyButton;
@property (nonatomic, strong) IBOutlet UIButton *cameraButton;
@property (nonatomic, strong) IBOutlet UIButton *createChannelButton;
@property (strong, nonatomic) IBOutlet UIButton *saveChannelButton;
@property (nonatomic, strong) IBOutlet UIButton *shareButton;
@property (nonatomic, strong) IBOutlet UIButton* addCoverButton;
@property (nonatomic, strong) IBOutlet UIButton* profileImageButton;
@property (nonatomic, strong) IBOutlet UIButton* reportConcernButton;
@property (nonatomic, strong) IBOutlet UIButton* selectCategoryButton;
@property (nonatomic, strong) IBOutlet UIButton* subscribeButton;
@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet UIImageView *channelCoverImageView;
@property (nonatomic, strong) IBOutlet UILabel *channelDetailsLabel;
@property (nonatomic, strong) IBOutlet UILabel *channelOwnerLabel;
@property (nonatomic, strong) IBOutlet UIPopoverController *cameraMenuPopoverController;
@property (nonatomic, strong) IBOutlet UIPopoverController *cameraPopoverController;
@property (nonatomic, strong) IBOutlet UIPopoverController *reportConcernPopoverController;
@property (nonatomic, strong) IBOutlet UIView *avatarBackgroundView;
@property (nonatomic, strong) IBOutlet UIView *channelTitleTextBackgroundView;
@property (nonatomic, strong) IBOutlet UIView *displayControlsView;
@property (nonatomic, strong) IBOutlet UIView *editControlsView;
@property (nonatomic, strong) IBOutlet UIView *masterControlsView;
@property (nonatomic, strong) NSFetchedResultsController *channelCoverFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *userChannelCoverFetchedResultsController;
@property (nonatomic, strong) SYNCategoriesTabViewController *categoriesTabViewController;
@property (nonatomic, strong) SYNCoverChooserController* coverChooserController;
@property (nonatomic, strong) SYNReportConcernTableViewController *reportConcernTableViewController;
@property (nonatomic, strong) UIActivityIndicatorView* subscribingIndicator;
@property (nonatomic, strong) UIImage* originalBackgroundImage;
@property (nonatomic, strong) UIView *coverChooserMasterView;
@property (nonatomic, strong) UIView* noVideosMessageView;
@property (nonatomic, strong) id<SDWebImageOperation> currentWebImageOperation;
@property (nonatomic, weak) Channel *channel;
@property (nonatomic,strong) NSString* selectedCategoryId;
@property (nonatomic,strong) NSString* selectedCoverId;
@property (nonatomic,strong) VideoInstance* instanceToDelete;
@property (weak, nonatomic) IBOutlet UIButton *cancelEditButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UILabel *byLabel;

//iPhone specific
@property (nonatomic,strong) AVURLAsset* selectedAsset;
@property (nonatomic,strong) SYNChannelCoverImageSelectorViewController* coverImageSelector;
@property (strong,nonatomic) SYNChannelCategoryTableViewController *categoryTableViewController;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelTextInputButton;
@property (weak, nonatomic) IBOutlet UIImageView *textBackgroundImageView;

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
        _mode = mode;
        
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
    
    self.channelDetailsLabel.font = [UIFont boldRockpackFontOfSize: self.channelDetailsLabel.font.pointSize];
    [self addShadowToLayer: self.channelDetailsLabel.layer];
    
    self.byLabel.font = [UIFont rockpackFontOfSize: self.byLabel.font.pointSize];
    [self addShadowToLayer: self.byLabel.layer];

    
    // Add Rockpack font and shadow to UITextView
    self.channelTitleTextView.font = [UIFont rockpackFontOfSize: self.channelTitleTextView.font.pointSize];
    [self addShadowToLayer: self.channelTitleTextView.layer];
    
    // Display 'Done' instead of 'Return' on Keyboard
    self.channelTitleTextView.returnKeyType = UIReturnKeyDone;
    
    // Needed for shadows to work
    self.channelTitleTextView.backgroundColor = [UIColor clearColor];

    self.channelTitleTextView.placeholder = NSLocalizedString (@"CHANNEL NAME", nil);
    
    self.channelTitleTextView.placeholderTextColor = [UIColor colorWithRed: 0.909
                                                                     green: 0.909
                                                                      blue: 0.909
                                                                     alpha: 1.0f];
    // Set delegate so that we can respond to events
    self.channelTitleTextView.delegate = self;

    // Shadow for avatar background
    [self addShadowToLayer: self.avatarBackgroundView.layer];
    
    // Add a custom flow layout to our thumbail collection view (with the right size and spacing)
    LXReorderableCollectionViewFlowLayout *layout = [[LXReorderableCollectionViewFlowLayout alloc] init];
    layout.itemSize = isIPhone?CGSizeMake(310.0f , 175.0f):CGSizeMake(249.0f , 141.0f);
    layout.minimumInteritemSpacing = isIPhone ? 0.0f : 6.0f;
    layout.minimumLineSpacing = isIPhone ? 4.0f : 6.0f;
    
    self.videoThumbnailCollectionView.collectionViewLayout = layout;
    
    if (isIPhone)
    {
        layout.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        self.videoThumbnailCollectionView.contentInset = UIEdgeInsetsMake([[SYNDeviceManager sharedInstance] currentScreenHeight] - 110.0f, 0.0f, 0.0f, 0.0f);
    }
    else
    {
        layout.sectionInset = UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 5.0f);
    }
    
    
    // == Video Cells == //
    
    UINib *videoThumbnailCellNib = [UINib nibWithNibName: @"SYNVideoThumbnailRegularCell"
                                                  bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: videoThumbnailCellNib
                        forCellWithReuseIdentifier: @"SYNVideoThumbnailRegularCell"];
    
    
    
    // == Cover Image == //
  
    if (self.mode == kChannelDetailsModeDisplay) // only load bg on display
    {
        self.currentWebImageOperation = [self loadBackgroundImage];
    }
    
    
    // == Avatar Image == //
    
    UIImage* placeholderImage = [UIImage imageNamed: @"PlaceholderAvatarProfile.png"];
    
    NSArray *thumbnailURLItems = [self.channel.channelOwner.thumbnailURL componentsSeparatedByString:@"/"];
    
    if (thumbnailURLItems.count >= 6) // there is a url string with the proper format
    {
        
        // whatever is set to be the default size by the server (ex. 'thumbnail_small') //
        NSString* thumbnailSizeString = thumbnailURLItems[5];
        
        
        NSString* thumbnailUrlString = [self.channel.channelOwner.thumbnailURL stringByReplacingOccurrencesOfString:thumbnailSizeString withString:@"thumbnail_large"];
        
        [self.avatarImageView setImageWithURL: [NSURL URLWithString: thumbnailUrlString]
                             placeholderImage: placeholderImage
                                      options: SDWebImageRetryFailed];
    }
    else
    {
        self.avatarImageView.image = placeholderImage;
    }
    
    
    
    
    

    if (!isIPhone)
    {
        // Create categories tab, but make invisible (alpha = 0) for now
        self.categoriesTabViewController = [[SYNCategoriesTabViewController alloc] initWithHomeButton: @"OTHER"];
        self.categoriesTabViewController.delegate = self;
        CGRect tabFrame = self.categoriesTabViewController.view.frame;
        tabFrame.origin.y = kChannelCreationCategoryTabOffsetY;
        self.categoriesTabViewController.view.frame = tabFrame;
        [self.view addSubview: self.categoriesTabViewController.view];
        self.categoriesTabViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.categoriesTabViewController.view.alpha = 0.0f;
        [self addChildViewController: self.categoriesTabViewController];
    }
    
    self.originalContentOffset = self.videoThumbnailCollectionView.contentOffset;
    
    if (self.mode == kChannelDetailsModeDisplay)
    {
        self.addButton.hidden = NO;
        self.createChannelButton.hidden = YES;
    }
    else
    {
        self.addButton.hidden = YES;
        self.createChannelButton.hidden = NO;
    }
    
    //Remove the save button. It is added back again if the edit button is tapped.
    [self.saveChannelButton removeFromSuperview];
    
    if (!isIPhone)
    {
        // Set text on add cover and select category buttons
        NSString *coverString = NSLocalizedString (@"ADD A COVER", nil);
        
        NSMutableAttributedString* attributedCoverString = [[NSMutableAttributedString alloc] initWithString: coverString
                                                                                                  attributes: @{NSForegroundColorAttributeName : [UIColor colorWithRed: 40.0f/255.0f green: 45.0f/255.0f blue: 51.0f/255.0f alpha: 1.0f],
                                                                                        NSFontAttributeName : [UIFont boldRockpackFontOfSize: 18.0f]}];
        
        [self.addCoverButton setAttributedTitle: attributedCoverString
                                       forState: UIControlStateNormal];
        
        // Now do fancy attributed string
        //NSString *categoryString = @"SELECT A CATEGORY (Optional)";
        NSString *categoryString = NSLocalizedString (@"SELECT A CATEGORY", nil);

        
        NSMutableAttributedString* attributedCategoryString = [[NSMutableAttributedString alloc] initWithString: categoryString
                                                                                                     attributes: @{NSForegroundColorAttributeName : [UIColor colorWithRed: 40.0f/255.0f green: 45.0f/255.0f blue: 51.0f/255.0f alpha: 1.0f],
                                                                                           NSFontAttributeName : [UIFont boldRockpackFontOfSize: 18.0f]}];
        
        
        // Set text on add cover and select category buttons
        [self.selectCategoryButton setAttributedTitle: attributedCategoryString
                                             forState: UIControlStateNormal];
        self.coverChooserController = [[SYNCoverChooserController alloc] init];
        [self addChildViewController:self.coverChooserController];
        self.coverChooserMasterView = self.coverChooserController.view;
        
    }
    else
    {
        self.textBackgroundImageView.image = [[UIImage imageNamed:@"FieldChannelTitle"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 6, 6)];
        
        self.addCoverButton.titleLabel.font = [UIFont boldRockpackFontOfSize:self.addCoverButton.titleLabel.font.pointSize];
        self.addCoverButton.titleLabel.numberOfLines = 2;
        self.addCoverButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.addCoverButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        self.selectCategoryButton.titleLabel.font = [UIFont boldRockpackFontOfSize:self.selectCategoryButton.titleLabel.font.pointSize];
        self.selectCategoryButton.titleLabel.numberOfLines = 2;
        self.selectCategoryButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.selectCategoryButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        if (self.mode == kChannelDetailsModeEdit)
        {
            self.view.backgroundColor = [UIColor colorWithWhite:0.92f alpha:1.0f];
        }
        
        // Cover Image Selector //
        
    }
    self.selectedCategoryId = @"";
    self.selectedCoverId = @"";
    
    
    CGRect correctRect = self.coverChooserMasterView.frame;
    correctRect.origin.y = 404.0;
    self.coverChooserMasterView.frame = correctRect;
    [self.editControlsView addSubview:self.coverChooserMasterView];
    
    self.cameraButton = self.coverChooserController.cameraButton;
    
    [self.cameraButton addTarget:self action:@selector(userTouchedCameraButton:) forControlEvents:UIControlEventTouchUpInside];
    
    
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
    
    [self.channelTitleTextView addObserver: self
                                forKeyPath: kTextViewContentSizeKey
                                   options: NSKeyValueObservingOptionNew
                                   context: NULL];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(coverImageChangedHandler:)
                                                 name: kCoverArtChanged
                                               object: nil];
    

    
    
    self.subscribeButton.enabled = YES;
    self.subscribeButton.selected = self.channel.subscribedByUserValue;
    
    [self.channel addObserver: self
                   forKeyPath: kSubscribedByUserKey
                      options: NSKeyValueObservingOptionNew
                      context :nil];
    
    // We set up assets depending on whether we are in display or edit mode
    [self setDisplayControlsVisibility: (self.mode == kChannelDetailsModeDisplay)];
    
    // Refresh our view
    [self.videoThumbnailCollectionView reloadData];
    
    // Only do this is we have a resource URL (i.e. we haven't just created the channel)
    
    if (self.mode == kChannelDetailsModeDisplay && self.channel != nil)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: kChannelUpdateRequest
                                                            object: self
                                                          userInfo: @{kChannel: self.channel}];
    }
    
    
    [self displayChannelDetails];
}


- (void) viewWillDisappear: (BOOL) animated
{
    
    [self.videoThumbnailCollectionView removeObserver: self
                                           forKeyPath: kCollectionViewContentOffsetKey];

    [self.channel removeObserver: self
                      forKeyPath: kSubscribedByUserKey];
    
    [self.channelTitleTextView removeObserver: self
                                   forKeyPath: kTextViewContentSizeKey];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kCoverArtChanged
                                                  object: nil];
    
    if (self.subscribingIndicator)
    {
        [self.subscribingIndicator removeFromSuperview];
        self.subscribingIndicator = nil;
    }
        


    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: NSManagedObjectContextDidSaveNotification
                                                  object: self.channel.managedObjectContext];
    [super viewWillDisappear: animated];
}


- (void) updateCategoryButtonText: (NSString *) buttonText
{
    NSMutableAttributedString* attributedCategoryString = [[NSMutableAttributedString alloc] initWithString: buttonText
                                                                                                 attributes: @{NSForegroundColorAttributeName : [UIColor colorWithRed: 40.0f/255.0f green: 45.0f/255.0f blue: 51.0f/255.0f alpha: 1.0f],
                                                                                       NSFontAttributeName : [UIFont boldRockpackFontOfSize: 18.0f]}];
    // Set text on add cover and select category buttons
    [self.selectCategoryButton setAttributedTitle: attributedCategoryString
                                         forState: UIControlStateNormal];
}

-(void)coverImageChangedHandler:(NSNotification*)notification
{
    NSString* coverArtUrl = (NSString*)[[notification userInfo] objectForKey:kCoverArt];
    if (!coverArtUrl)
        return;
    
    if ([coverArtUrl isEqualToString: @""])
    {
        self.channelCoverImageView.image = nil;
        
    }
    else
    {
        NSString* largeImageUrlString = [coverArtUrl stringByReplacingOccurrencesOfString:@"thumbnail_medium" withString:@"background"];
        [self.channelCoverImageView setImageWithURL: [NSURL URLWithString: largeImageUrlString]
                                   placeholderImage: [UIImage imageNamed: @"PlaceholderChannelCreation.png"]
                                            options: SDWebImageRetryFailed];
    }
    
    self.originalBackgroundImage = nil;
}


#pragma mark - Orientation Methods

- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                 duration: (NSTimeInterval) duration
{
    [super willRotateToInterfaceOrientation: toInterfaceOrientation
                                   duration: duration];

    [self.self.videoThumbnailCollectionView.collectionViewLayout invalidateLayout];
}


- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    [super willAnimateRotationToInterfaceOrientation: toInterfaceOrientation
                                            duration: duration];
    
    UIImage* croppedImage = [self croppedImageForOrientation: toInterfaceOrientation];
    
    self.channelCoverImageView.image = croppedImage;
}


- (void) mainContextDataChanged: (NSNotification*) notification
{
    if (!notification)
        return;
    
    if (notification.object == self.channel.managedObjectContext)
    {
        [self reloadCollectionViews];
        
        if (self.channel.videoInstances.count == 0)
        {
            [self showNoVideosMessage];
        }
        else if (self.noVideosMessageView != nil)
        {
            [self.noVideosMessageView removeFromSuperview];
            self.noVideosMessageView = nil;
        }
    }
}

- (void) showNoVideosMessage
{
    CGSize viewFrameSize = CGSizeMake(360.0, 50.0);
    self.noVideosMessageView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 640.0, viewFrameSize.width, viewFrameSize.height)];
    self.noVideosMessageView.center = CGPointMake(self.view.frame.size.width * 0.5, self.noVideosMessageView.center.y);
    self.noVideosMessageView.frame = CGRectIntegral(self.noVideosMessageView.frame);
    self.noVideosMessageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    UIView* noVideosBGView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, viewFrameSize.width, viewFrameSize.height)];
    noVideosBGView.backgroundColor = [UIColor blackColor];
    noVideosBGView.alpha = 0.3;
    
    [self.noVideosMessageView addSubview:noVideosBGView];
    
    
    UILabel* noVideosLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    noVideosLabel.text = @"THERE ARE NO VIDEOS IN THIS CHANNEL YET";
    noVideosLabel.textAlignment = NSTextAlignmentCenter;
    noVideosLabel.font = [UIFont rockpackFontOfSize:16.0];
    noVideosLabel.textColor = [UIColor whiteColor];
    [noVideosLabel sizeToFit];
    noVideosLabel.center = CGPointMake(viewFrameSize.width * 0.5, viewFrameSize.height * 0.5 + 4.0);
    noVideosLabel.frame = CGRectIntegral(noVideosLabel.frame);
    noVideosLabel.backgroundColor = [UIColor clearColor];
    
    [self.noVideosMessageView addSubview:noVideosLabel];
    
    [self.view addSubview:self.noVideosMessageView];
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
    
    
    NSLog(@"current channel s count : %lld", self.channel.subscribersCountValue);
    
    NSString *detailsString = [NSString stringWithFormat: @"%lld %@", self.channel.subscribersCountValue, NSLocalizedString(@"SUBSCRIBERS", nil)];
    self.channelDetailsLabel.text = detailsString;
    
    // If we have a valid ecommerce URL, then display the button
    if (self.channel.eCommerceURL != nil && ![self.channel.eCommerceURL isEqualToString: @""])
    {
        self.buyButton.hidden = FALSE;
    }
    
    self.channelTitleTextView.text = self.channel.title;
    
    [self adjustTextView];
}


#pragma mark - Collection Delegate Methods

- (NSInteger) collectionView: (UICollectionView *) collectionView numberOfItemsInSection: (NSInteger) section
{
    
    return self.channel.videoInstances.count;
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
    
    videoThumbnailCell.displayMode = self.mode;
    
    VideoInstance *videoInstance = self.channel.videoInstances [indexPath.item];
    
    [videoThumbnailCell.imageView setImageWithURL: [NSURL URLWithString: videoInstance.video.thumbnailURL]
                                 placeholderImage: [UIImage imageNamed: @"PlaceholderVideoWide.png"]
                                          options: SDWebImageRetryFailed];
    
    videoThumbnailCell.titleLabel.text = videoInstance.title;
    videoThumbnailCell.viewControllerDelegate = self;
    
    videoThumbnailCell.addItButton.highlighted = NO;
    videoThumbnailCell.addItButton.selected = [appDelegate.videoQueue videoInstanceIsAddedToChannel:videoInstance];
    
    cell = videoThumbnailCell;
    
    return cell;
}


- (void) collectionView: (UICollectionView *) collectionView
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (self.mode != kChannelDetailsModeEdit)
    {
        [self displayVideoViewerWithVideoInstanceArray: self.channel.videoInstances.array
                                      andSelectedIndex: indexPath.item];
    }
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
    self.channelTitleTextBackgroundView.backgroundColor = (visible) ? [UIColor clearColor] : [UIColor whiteColor];
    self.displayControlsView.alpha = (visible) ? 1.0f : 0.0f;
    self.editControlsView.alpha = (visible) ? 0.0f : 1.0f;
    self.coverChooserMasterView.hidden = (visible) ? TRUE : FALSE;
    self.profileImageButton.enabled = visible;
    self.subscribeButton.hidden = (visible && [self.channel.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId]);
    self.editButton.hidden = (visible && ! [self.channel.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId]);
    [(LXReorderableCollectionViewFlowLayout *)self.videoThumbnailCollectionView.collectionViewLayout longPressGestureRecognizer].enabled = (visible) ? FALSE : TRUE;
}


// For edit controls just do the inverse of details control
- (void) setEditControlsVisibility: (BOOL) visible
{
    _mode = visible;
    
    [self setDisplayControlsVisibility: !visible];
    
    [self.videoThumbnailCollectionView reloadData];
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

    
    if ([keyPath isEqualToString: kTextViewContentSizeKey])
    {
        UITextView *tv = object;
            //Bottom vertical alignment
            CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height);
//            topCorrect = (topCorrect <0.0 ? 0.0 : topCorrect);
                    NSLog (@"offset %f, bounds.height %f, content.height %f, content.height2 %f", tv.contentOffset.y, [tv bounds].size.height, [tv contentSize].height, -topCorrect);
        
        [tv setContentOffset: (CGPoint){.x = 0, .y = -topCorrect}
                    animated: NO];
    }
    else if ([keyPath isEqualToString: kCollectionViewContentOffsetKey])
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
        self.subscribeButton.selected = finalValue;
        self.subscribeButton.enabled = YES;
        
        if (self.subscribingIndicator)
        {
            [self.subscribingIndicator removeFromSuperview];
            self.subscribingIndicator = nil;
        }
        
    }
}


#pragma mark - Control Delegate

- (IBAction) shareChannelButtonTapped: (UIButton *) shareButton
{
    // Prevent multiple clicks
    shareButton.enabled = FALSE;
    
    [self shareChannel: self.channel
                inView: self.view
              fromRect: self.shareButton.frame
       arrowDirections: UIPopoverArrowDirectionDown
            onComplete: ^{
                // Re-enable button
                    shareButton.enabled = TRUE;
            }];
}


// If the buy button is visible, then (hopefully) we have a valid URL
// But check to see that it should open anyway
- (IBAction) buyButtonTapped: (id) sender
{
    [self initiatePurchaseAtURL: [NSURL URLWithString: self.channel.eCommerceURL]];
}


- (IBAction) subscribeButtonTapped: (id) sender
{
    self.subscribeButton.enabled = NO;
    
    [self addSubscribeActivityIndicator];
    
    // Defensive programming
    if (self.channel != nil)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: kChannelSubscribeRequest
                                                            object: self
                                                          userInfo: @{ kChannel : self.channel }];
    }
}



- (IBAction) profileImagePressed: (UIButton*) sender
{
    [self viewProfileDetails: self.channel.channelOwner];
}


- (void) videoAddButtonTapped: (UIButton *) addButton
{
    NSString* noteName;
    
    if (!addButton.selected || [[SYNDeviceManager sharedInstance] isIPhone]) // There is only ever one video in the queue on iPhone. Always fire the add action.
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
    
    // Defensive programming
    if (videoInstance != nil)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: noteName
                                                            object: self
                                                          userInfo: @{@"VideoInstance" : videoInstance}];
    }
    
    addButton.selected = !addButton.selected;
}


- (void) videoDeleteButtonTapped: (UIButton *) deleteButton
{
    UIView *v = deleteButton.superview.superview;
    
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: v.center];
    
    self.instanceToDelete = (VideoInstance*)[self.channel.videoInstances objectAtIndex: indexPath.item];
    
    if (self.instanceToDelete != nil)
    {
        [[[UIAlertView alloc] initWithTitle: NSLocalizedString (@"Delete Video", nil)
                                                        message: NSLocalizedString (@"Are you sure you want to delete this video?", nil)
                                                       delegate: self
                                              cancelButtonTitle: NSLocalizedString (@"No", nil)
                                              otherButtonTitles: NSLocalizedString (@"Yes", nil), nil] show];
    }
}


// Alert view delegarte for 
- (void) alertView: (UIAlertView *) alertView
         clickedButtonAtIndex: (NSInteger) buttonIndex
{
    if (buttonIndex == 0)
    {
        // cancel, do nothing
        DebugLog(@"Delete cancelled");
    }
    else
    { 
        if (self.channel.managedObjectContext == appDelegate.channelsManagedObjectContext) // the channel is the under creation channel
        {
            [[NSNotificationCenter defaultCenter] postNotificationName: kVideoQueueRemove
                                                                object: self
                                                              userInfo: @{kVideoInstance: self.instanceToDelete}];
        }
        else
        {
            NSMutableOrderedSet *channelsSet = [NSMutableOrderedSet orderedSetWithOrderedSet: self.channel.videoInstances];
            
            [channelsSet removeObject: self.instanceToDelete];
            
            [self.channel setVideoInstances: channelsSet];
        }
        
        [self reloadCollectionViews];
    }
}


- (IBAction) addCoverButtonTapped: (UIButton *) button
{
    // Prevent multiple clicks of the add cover button on iPhoen
    if ([[SYNDeviceManager sharedInstance] isIPhone])
    {
        if (self.isImageSelectorOpen == TRUE)
        {
            return;
        }
        
        self.imageSelectorOpen = TRUE;
    }
    
    [self.channelTitleTextView resignFirstResponder];
    [self showCoverChooser];
    [self hideCategoryChooser];
}


- (IBAction) selectCategoryButtonTapped: (UIButton *) button
{
    [self.channelTitleTextView resignFirstResponder];
    [self showCategoryChooser];
    [self hideCoverChooser];
}


- (IBAction) editButtonTapped: (id) sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteAllNavControlsHide
                                                        object: self
                                                      userInfo: nil];
    
    [self setEditControlsVisibility: YES];
    [self.createChannelButton removeFromSuperview];
    [self.view addSubview:self.saveChannelButton];
    self.saveChannelButton.hidden = NO;
    self.cancelEditButton.hidden = NO;
    self.backButton.hidden = YES;
    self.addButton.hidden = YES;
}


- (IBAction) cancelEditTapped: (id) sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteAllNavControlsShow
                                                        object: self
                                                      userInfo: nil];
    
    [self setEditControlsVisibility: NO];
    [self displayChannelDetails];
    self.saveChannelButton.hidden = YES;
    self.cancelEditButton.hidden = YES;
    self.addButton.hidden = NO;
    self.backButton.hidden= NO;

}


- (IBAction) saveChannelTapped: (id) sender
{ 
    if ([[SYNDeviceManager sharedInstance] isIPhone])
    {
        self.saveChannelButton.hidden = YES;
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
    }
    
    self.channel.title = self.channelTitleTextView.text;
    self.channel.channelDescription = @"Test Description";
    
    NSString* category = self.selectedCategoryId;
    if ([category length] == 0)
    {
        category = self.channel.categoryId;
        if (!category)
        {
            category = @"all";
        }
    }
    
    NSString* cover = self.selectedCoverId;
    if ([cover length]==0)
    {
        cover = @"KEEP";
    }
    
    [appDelegate.oAuthNetworkEngine updateChannelForUserId: appDelegate.currentOAuth2Credentials.userId
                                                 channelId: self.channel.uniqueId
                                                     title: self.channel.title
                                               description: (self.channel.channelDescription)
                                                  category: category
                                                     cover: cover
                                                  isPublic: YES
                                         completionHandler: ^(NSDictionary* resourceCreated) {
                                             NSString* channelId = [resourceCreated objectForKey: @"id"];
                                             [[NSNotificationCenter defaultCenter] postNotificationName: kNoteAllNavControlsShow
                                                                                                 object: self
                                                                                               userInfo: nil];
                                             [self setEditControlsVisibility: NO];
                                             self.saveChannelButton.hidden = YES;
                                             self.cancelEditButton.hidden = YES;
                                             
                                             [self setVideosForChannelById: channelId
                                                                 isUpdated: YES];
                                             
                                             // the method above will call the [self getChanelById:channelId isUpdated:YES]
                                             
                                         }
                                              errorHandler: ^(NSDictionary* error) {
                                                  NSDictionary* specificErrors = [error objectForKey: @"form_errors"];
                                                  NSString* errorText = [specificErrors objectForKey: @"title"];
                                                  
                                                  if (!errorText)
                                                  {
                                                      errorText = @"Could not save channel. Please try again later.";
                                                  }
                                                  
                                                  DebugLog(@"Error @ saveChannelPressed:");
                                                  NSString* errorMessage = NSLocalizedString(errorText, nil);
                                                  [self showError:errorMessage];
                                              }];
}


#pragma mark - Cover choice

- (void) showCoverChooser
{
    if ([[SYNDeviceManager sharedInstance] isIPad])
    {
        // Check to see if we are already display the cover chooser
        if (self.coverChooserMasterView.alpha == 0.0f)
        {
            
            [self.coverChooserController updateCoverArt];
            
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
    else
    {
        self.coverImageSelector = [[SYNChannelCoverImageSelectorViewController alloc] init];
        self.coverImageSelector.imageSelectorDelegate = self;
        CGRect startFrame = self.coverImageSelector.view.frame;
        startFrame.origin.y = self.view.frame.size.height;
        self.coverImageSelector.view.frame = startFrame;
        [self.view addSubview:self.coverImageSelector.view];
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGRect endFrame = self.coverImageSelector.view.frame;
            endFrame.origin.y = 0.0f;
            self.coverImageSelector.view.frame = endFrame;
        } completion:nil];
        
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
    if ([[SYNDeviceManager sharedInstance] isIPad])
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
    else
    {
        if (!self.categoryTableViewController)
        {
            self.categoryTableViewController = [[SYNChannelCategoryTableViewController alloc] initWithNibName:@"SYNChannelCategoryTableViewControllerFullscreen~iphone" bundle: [NSBundle mainBundle]];
            self.categoryTableViewController.categoryTableControllerDelegate = self;
            self.categoryTableViewController.showAllCategoriesHeader = NO;
        }
        else
        {
            // Check to see if the panel is already displayed (prevent multiple taps on choose category button)
            if (self.categoryTableViewController.view.frame.origin.y == 0.0f)
            {
                return;
            }
        }
        CGRect startFrame = self.categoryTableViewController.view.frame;
        startFrame.origin.y = self.view.frame.size.height;
        self.categoryTableViewController.view.frame = startFrame;
        [self.view addSubview:self.categoryTableViewController.view];
        
        [UIView animateWithDuration: 0.3f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             CGRect endFrame = self.categoryTableViewController.view.frame;
                             endFrame.origin.y = 0.0f;
                             self.categoryTableViewController.view.frame = endFrame;
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

- (IBAction) addItToChannelPresssed: (id) sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteAddToChannelRequest
                                                        object: self];
    
}


#pragma mark - Tab delegates

- (BOOL) showSubcategories
{
    return YES;
}


- (void) handleNewTabSelectionWithId: (NSString*) itemId
{
    self.selectedCategoryId = itemId;
}

- (void) handleNewTabSelectionWithGenre: (Genre*) genre
{
    NSString* genreName;
    if (!genre)
        genreName = @"OTHER";
    else
        genreName = genre.name;
    
    [self updateCategoryButtonText: genreName];
}


- (void) handleMainTap: (UITapGestureRecognizer*) recogniser
{
    self.selectedCategoryId = @"";
}


- (void) handleSecondaryTap: (UITapGestureRecognizer*) recogniser
{
    [self hideCategoryChooser];
}


#pragma mark - Channel Creation (3 steps)

- (IBAction) createChannelPressed: (id) sender
{
    if ([[SYNDeviceManager sharedInstance] isIPhone])
    {
        self.createChannelButton.hidden = YES;
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
    }
    
    self.channel.title = self.channelTitleTextView.text;
    self.channel.channelDescription = @"Test Description";
    
    [appDelegate.oAuthNetworkEngine createChannelForUserId: appDelegate.currentOAuth2Credentials.userId
                                                     title: self.channel.title
                                               description: (self.channel.channelDescription)
                                                  category: self.selectedCategoryId
                                                     cover: self.selectedCoverId
                                                  isPublic: YES
                                         completionHandler: ^(NSDictionary* resourceCreated) {
                                             NSString* channelId = [resourceCreated objectForKey: @"id"];
                                             
                                             [self setVideosForChannelById:channelId isUpdated:NO];
                                         }
                                              errorHandler: ^(id error) {
                                             
                                             DebugLog(@"Error @ createChannelPressed:");
                                             NSString* errorMessage = NSLocalizedString(@"Could not create channel. Please try again later.", nil);
                                             if ([[error objectForKey: @"form_errors"] objectForKey :@"title"])
                                             {
                                                 errorMessage = NSLocalizedString(@"You already created a channel with this title. Please choose a different title.",nil);
                                             };

                                             [self showError:errorMessage];
                                             
                                             
                                         }];
}


- (void) setVideosForChannelById: (NSString*) channelId isUpdated:(BOOL) isUpdated
{
    [appDelegate.oAuthNetworkEngine updateVideosForChannelForUserId: appDelegate.currentOAuth2Credentials.userId
                                                          channelId: channelId
                                                   videoInstanceSet: self.channel.videoInstances
                                                  completionHandler: ^(id response) {
                                                      // a 204 returned
                                                      
                                                      [self fetchAndStoreUpdatedChannelForId:channelId isUpdate:isUpdated];
                                                      
                                                  } errorHandler: ^(id err) {
                                                      
                                                           
                                                           DebugLog(@"Error @ addVideosToNewChannelForId:");
                                                           [self showError:NSLocalizedString(@"Could not create channel. Please try again later.", nil)];
                                                }];
}


- (void) fetchAndStoreUpdatedChannelForId: (NSString*) channelId isUpdate:(BOOL)isUpdate
{
    [appDelegate.oAuthNetworkEngine channelCreatedForUserId: appDelegate.currentOAuth2Credentials.userId
                                                  channelId: channelId
                                          completionHandler: ^(id dictionary) {
                                              IgnoringObjects ignore = kIgnoreChannelOwnerObject;
                                              if (!isUpdate)
                                              {
                                                  ignore = ignore | kIgnoreStoredObjects;
                                              }
                                              Channel* createdChannel = [Channel instanceFromDictionary:dictionary
                                                                              usingManagedObjectContext:appDelegate.mainManagedObjectContext
                                                                                    ignoringObjectTypes:ignore
                                                                                              andViewId:kProfileViewId];
                                              
                                              createdChannel.channelOwner = appDelegate.currentUser;
                                              
                                              [self.channel removeObserver: self
                                                                forKeyPath: kSubscribedByUserKey];
                                              
                                              self.channel = createdChannel;
                                              
                                              [self.channel addObserver: self
                                                             forKeyPath: kSubscribedByUserKey
                                                                options: NSKeyValueObservingOptionNew
                                                               context :nil];
                                              
                                              DebugLog(@"Channel: %@", createdChannel);
                                              
                                              [appDelegate saveContext:YES];
                                              
                                              
                                              // Complete Channel Creation //
                                              
                                              self.channelOwnerLabel.text = appDelegate.currentUser.displayName;
                                              
                                              [self displayChannelDetails];
                                              
                                              [self setDisplayControlsVisibility:YES];
                                              
                                              if ([[SYNDeviceManager sharedInstance] isIPad])
                                              {
                                                  self.addButton.hidden = YES;
                                                  self.createChannelButton.hidden = YES;
                                                  
                                              }
                                              else
                                              {
                                                  // On iPad the existing channels viewcontroller's view is removed from the master view controller when a new channel is created.
                                                  // On iPhone we want to be able to go back which means the existing channels view remains onscreen. Here we remove it as channel creation was complete.
                                                  UIViewController *master = self.presentingViewController;
                                                  [[[[master childViewControllers] lastObject] view] removeFromSuperview];
                                                  [self setDisplayControlsVisibility:YES];
                                                  
                                                  //Move the back button from the edit view to allow closing this view
                                                  [self.backButton removeFromSuperview];
                                                  [self.view addSubview:self.backButton];
                                              }
                                              
                                              [[NSNotificationCenter defaultCenter] postNotificationName: kVideoQueueClear
                                                                                                  object: nil];
                                              [[NSNotificationCenter defaultCenter] postNotificationName:kNoteChannelSaved object:self];
                                              
                                          } errorHandler:^(id err) {
                                              
                                              DebugLog(@"Error @ getNewlyCreatedChannelForId:");
                                              [self showError: NSLocalizedString(@"Could not create channel. Please try again later.", nil)];
                                          }];
}

-(void) showError: (NSString*) errorMessage
{
    self.createChannelButton.hidden = NO;
    [self.activityIndicator stopAnimating];
    [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", nil)
                                message: errorMessage
                               delegate: nil
                      cancelButtonTitle: NSLocalizedString(@"OK", nil)
                      otherButtonTitles: nil] show];
}


#pragma mark - UITextView delegate

// Try and force everything to uppercase
- (BOOL) textView: (UITextView *) textView
         shouldChangeTextInRange: (NSRange) range
         replacementText: (NSString *) text
{
    // Stop editing when the return key is pressed
    if ([text isEqualToString: @"\n"])
    {
        [self resignTextView];
        return NO;
    }
    
    if (textView.text.length >= 25 && ![text isEqualToString: @""])
    {
        return NO;
    }
    
    NSRange lowercaseCharRange = [text rangeOfCharacterFromSet: [NSCharacterSet lowercaseLetterCharacterSet]];
    
    if (lowercaseCharRange.location != NSNotFound)
    {
        textView.text = [textView.text stringByReplacingCharactersInRange: range
                                                               withString: [text uppercaseString]];
        return NO;
    }
    
    return YES;
}


- (void) textViewDidBeginEditing: (UITextView *) textView
{
    self.createChannelButton.hidden = YES;
    self.saveChannelButton.hidden = YES;
    self.cancelTextInputButton.hidden = NO;
    
}

- (void) textViewDidEndEditing: (UITextView *) textView
{
    self.createChannelButton.hidden = NO;
    self.saveChannelButton.hidden = NO;
    self.cancelTextInputButton.hidden = YES;
}


// Big invisible buttong to cancel title entry
- (IBAction) cancelTitleEntry
{
    [self resignTextView];
}


- (void) resignTextView
{
    [self adjustTextView];
    
    [self.channelTitleTextView resignFirstResponder];
}


- (void) adjustTextView
{
    CGFloat topCorrect = ([self.channelTitleTextView bounds].size.height - [self.channelTitleTextView contentSize].height);
    topCorrect = (topCorrect <0.0 ? 0.0 : topCorrect);
    
    [self.channelTitleTextView setContentOffset: (CGPoint){.x = 0, .y = -topCorrect}
                                       animated: NO];
}

#pragma mark - Report a concern

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
                                                                 inView: self.displayControlsView
                                               permittedArrowDirections: UIPopoverArrowDirectionLeft
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
    [appDelegate.oAuthNetworkEngine reportConcernForUserId: appDelegate.currentOAuth2Credentials.userId
                                                objectType: @"channel"
                                                  objectId: self.channel.uniqueId
                                                    reason: reportString
                                          completionHandler: ^(NSDictionary *dictionary){
                                              DebugLog(@"Concern successfully reported");
                                          }
                                               errorHandler: ^(NSError* error) {
                                                   DebugLog(@"Report concern failed");
                                                   DebugLog(@"%@", [error debugDescription]);
                                               }];
}


#pragma mark - Cover selection and upload support

- (void) userTouchedCameraButton: (UIButton*) button
{
    button.selected = !button.selected;
    
    if (button.selected)
    {
        SYNCameraPopoverViewController *actionPopoverController = [[SYNCameraPopoverViewController alloc] init];
        actionPopoverController.delegate = self;
        
        // Need show the popover controller
        self.cameraMenuPopoverController = [[UIPopoverController alloc] initWithContentViewController: actionPopoverController];
       self.cameraMenuPopoverController.popoverContentSize = CGSizeMake(206, 96);
        self.cameraMenuPopoverController.delegate = self;
        self.cameraMenuPopoverController.popoverBackgroundViewClass = [SYNPopoverBackgroundView class];
        
        [self.cameraMenuPopoverController presentPopoverFromRect: button.frame
                                                          inView: self.coverChooserMasterView
                                        permittedArrowDirections: UIPopoverArrowDirectionLeft
                                                        animated: YES];
    }
}


- (void) popoverControllerDidDismissPopover: (UIPopoverController *) popoverController
{
    if (popoverController == self.cameraMenuPopoverController)
    {
        self.cameraButton.selected = NO;
        self.cameraPopoverController = nil;
    }
    else if (popoverController == self.cameraPopoverController)
    {
        self.cameraButton.selected = NO;
        self.cameraPopoverController = nil;
    }
    else if (popoverController == self.reportConcernPopoverController)
    {
        self.reportConcernButton.selected = NO;
        self.reportConcernPopoverController = nil;
    }
    else
    {
        AssertOrLog(@"Unknown popup dismissed");
    }
}


- (void) userTouchedTakePhotoButton
{
    [self.cameraMenuPopoverController dismissPopoverAnimated: NO];
    [self showImagePicker: UIImagePickerControllerSourceTypeCamera];
}


- (void) userTouchedChooseExistingPhotoButton
{
    [self.cameraMenuPopoverController dismissPopoverAnimated: NO];
    [self showImagePicker: UIImagePickerControllerSourceTypePhotoLibrary];
}


- (void) showImagePicker: (UIImagePickerControllerSourceType) sourceType
{
    self.imagePicker = [[GKImagePicker alloc] init];
    self.imagePicker.cropSize = CGSizeMake(280, 280);
    self.imagePicker.delegate = self;
    self.imagePicker.imagePickerController.sourceType = sourceType;
    
    if ((sourceType == UIImagePickerControllerSourceTypeCamera) && [UIImagePickerController respondsToSelector: @selector(isCameraDeviceAvailable:)])
    {
        if ([UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront])
        {
            self.imagePicker.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        }
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.cameraPopoverController = [[UIPopoverController alloc] initWithContentViewController: self.imagePicker.imagePickerController];
        
        self.cameraPopoverController.popoverBackgroundViewClass = [SYNPopoverBackgroundView class];
        
        [self.cameraPopoverController presentPopoverFromRect: self.cameraButton.frame
                                                      inView: self.coverChooserMasterView
                                    permittedArrowDirections: UIPopoverArrowDirectionLeft
                                                    animated: YES];
        
        self.cameraPopoverController.delegate = self;
    }
    else
    {
        [self presentViewController: self.imagePicker.imagePickerController
                           animated: YES
                         completion: nil];
    }
}


# pragma mark - GKImagePicker Delegate Methods

- (void) imagePicker: (GKImagePicker *) imagePicker
         pickedImage: (UIImage *) image
{
    DebugLog(@"width %f, height %f", image.size.width, image.size.height);
    
    self.channelCoverImageView.image = image;
    
    [self uploadChannelImage: image];
    
    [self hideImagePicker];
}

- (void) hideImagePicker
{
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        
        [self.cameraPopoverController dismissPopoverAnimated: YES];
        
    } else {
        
        [self.imagePicker.imagePickerController dismissViewControllerAnimated: YES
                                                                   completion: nil];
    }
}

#pragma mark - Upload channel cover image

- (void) uploadChannelImage: (UIImage *) imageToUpload
{
    // Upload the image for this user
    [appDelegate.oAuthNetworkEngine uploadCoverArtForUserId: appDelegate.currentOAuth2Credentials.userId
                                                      image: imageToUpload
                                          completionHandler: ^(NSDictionary *dictionary){
                                              NSString *imageUrl = dictionary [@"thumbnail_url"];

                                              if (imageUrl && [imageUrl isKindOfClass:[NSString class]])
                                              {
                                                  self.channel.channelCover.imageUrl = imageUrl;
                                                  [self.coverChooserController updateCoverArt];
                                                  DebugLog(@"Success");
                                              }
                                              else
                                              {
                                                  DebugLog(@"Failed to uploa wallpaper URL");
                                              }
                                              
                                              self.selectedCoverId = [dictionary objectForKey:@"cover_ref"];
                                          }
                                               errorHandler: ^(NSError* error) {
                                                   DebugLog(@"%@", [error debugDescription]);
                                               }];
}


#pragma mark - iPhone viewcontroller dismissal
- (IBAction) backButtonTapped: (id) sender
{
    CATransition *animation = [CATransition animation];
    
    [animation setType:kCATransitionReveal];
    [animation setSubtype:kCATransitionFromLeft];
    
    [animation setDuration: 0.30];
    [animation setTimingFunction:
     [CAMediaTimingFunction functionWithName:
      kCAMediaTimingFunctionEaseInEaseOut]];
    
    [self.view.window.layer addAnimation: animation
                                  forKey:nil];
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
}


-(void)addSubscribeActivityIndicator
{
    self.subscribingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    CGRect indicatorRect = self.subscribingIndicator.frame;
    indicatorRect.origin.x = self.subscribeButton.frame.origin.x - 32.0;
    indicatorRect.origin.y = self.subscribeButton.frame.origin.y + 10.0;
    self.subscribingIndicator.frame = indicatorRect;
    [self.subscribingIndicator startAnimating];
    [self.view addSubview:self.subscribingIndicator];
}


#pragma mark - iPhone Category Table delegate

- (void) categoryTableController:(SYNChannelCategoryTableViewController *)tableController didSelectSubCategory:(SubGenre *)subCategory
{
    self.selectedCategoryId = subCategory.uniqueId;
    
    [self.selectCategoryButton setTitle: [NSString stringWithFormat:@"%@/\n%@", subCategory.genre.name, subCategory.name]
                               forState: UIControlStateNormal];
    
    [self hideCategoriesTable];
}

- (void) categoryTableControllerDeselectedAll: (SYNChannelCategoryTableViewController *) tableController
{
    [self.selectCategoryButton setTitle: NSLocalizedString(@"SELECT A\nCATEGORY", nil)
                               forState: UIControlStateNormal];
    
    [self hideCategoriesTable];
}


- (void) hideCategoriesTable
{
    [UIView animateWithDuration: 0.3f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseIn
                     animations: ^{
                         CGRect endFrame = self.categoryTableViewController.view.frame;
                         endFrame.origin.y = self.view.frame.size.height;
                         self.categoryTableViewController.view.frame = endFrame;
                     }
                     completion: ^(BOOL finished) {
                         [self.categoryTableViewController.view removeFromSuperview];
                     }];
}


#pragma mark - iPhone Cover Chooser delegate

- (void) closeImageSelector: (SYNChannelCoverImageSelectorViewController *) imageSelector
{
    [UIView animateWithDuration: 0.3f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseIn
                     animations: ^{
                         CGRect endFrame = self.coverImageSelector.view.frame;
                         endFrame.origin.y = self.view.frame.size.height;
                         self.coverImageSelector.view.frame = endFrame;
                     }
                     completion: ^(BOOL finished) {
                         [self.coverImageSelector.view removeFromSuperview];
                         self.coverImageSelector = nil;
                     }];
    
    self.imageSelectorOpen = FALSE;
}


- (void) imageSelector: (SYNChannelCoverImageSelectorViewController *) imageSelector
   didSelectAVURLAsset:(AVURLAsset *)asset
{
    self.selectedAsset = asset;
    [self closeImageSelector: imageSelector];
    
}


- (void) imageSelector: (SYNChannelCoverImageSelectorViewController *) imageSelector
      didSelectUIImage: (UIImage *) image
{
    [self.channelCoverImageView setImage: image];
    [self uploadChannelImage: image];
    [self closeImageSelector: imageSelector];
}


- (void) imageSelector: (SYNChannelCoverImageSelectorViewController *) imageSelector
        didSelectImage: (NSString *) imageUrlString
          withRemoteId: (NSString *) remoteId
{
    self.selectedCoverId = remoteId;
    [self.channelCoverImageView setImageFromURL:[NSURL URLWithString: imageUrlString]];
    [self closeImageSelector: imageSelector];
}


#pragma mark - Image render

- (UIImage*) croppedImageForOrientation: (UIInterfaceOrientation) orientation
{
    CGRect croppingRect = UIInterfaceOrientationIsLandscape(orientation) ?
    CGRectMake(0.0, 138.0, 1024.0, 886.0) : CGRectMake(138.0, 0.0, 886.0, 1024.0);
    
    if (self.mode == kChannelDetailsModeEdit && !self.originalBackgroundImage) // set the bg var once
    {
        self.originalBackgroundImage = self.channelCoverImageView.image;
    }
    
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect([self.originalBackgroundImage CGImage], croppingRect);
    
    UIImage* croppedImage = [UIImage imageWithCGImage: croppedImageRef];
    
    CGImageRelease(croppedImageRef);
    
    return croppedImage;
}

- (id<SDWebImageOperation>) loadBackgroundImage
{
    __weak SDWebImageManager* shareImageManager = SDWebImageManager.sharedManager;
    __weak SYNChannelDetailViewController *wself = self;
    return [shareImageManager downloadWithURL: [NSURL URLWithString:self.channel.channelCover.imageBackgroundUrl]
                                      options: SDWebImageRetryFailed
                                     progress: nil
                                    completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                        if (!wself || !image)
                                            return;
                                        
                                        wself.originalBackgroundImage = image;
                                        
                                        UIImage* croppedImage = [wself croppedImageForOrientation:[[SYNDeviceManager sharedInstance] orientation]];
                                        
                                        [UIView transitionWithView: wself.view
                                                          duration: 0.35f
                                                           options: UIViewAnimationOptionTransitionCrossDissolve
                                                        animations: ^{
                                                            wself.channelCoverImageView.image = croppedImage;
                                                        } completion: nil];
                                        
                                        [wself.channelCoverImageView setNeedsLayout];
                                    }];
}

- (BOOL) needsAddButton
{
    return YES;
}

@end
