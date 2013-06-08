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
#import "User.h"
#import "CoverArt.h"
#import "GAI.h"
#import "GKImagePicker.h"
#import "Genre.h"
#import "SSTextView.h"
#import "SYNCameraPopoverViewController.h"
#import "SYNGenreTabViewController.h"
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
{
    BOOL _isIPhone; //So many calls were being made to the SYNDeviceManager a boolean initialised at viewDidLoad was introduced.
}


@property (nonatomic, assign)  CGPoint originalContentOffset;
@property (nonatomic, assign)  CGPoint originalMasterControlsViewOrigin;
@property (nonatomic, assign, getter = isImageSelectorOpen) BOOL imageSelectorOpen;
@property (nonatomic, strong) Channel *channel;
@property (nonatomic, strong) GKImagePicker *imagePicker;
@property (nonatomic, strong) IBOutlet SSTextView *channelTitleTextView;
@property (nonatomic, strong) IBOutlet UIButton *buyButton;
@property (nonatomic, strong) IBOutlet UIButton *cameraButton;
@property (nonatomic, strong) IBOutlet UIButton *createChannelButton;
@property (nonatomic, strong) IBOutlet UIButton *saveChannelButton;
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
@property (nonatomic, strong) NSIndexPath* indexPathToDelete;
@property (nonatomic, strong) NSString* selectedCategoryId;
@property (nonatomic, strong) NSString* selectedCoverId;
@property (nonatomic, strong) SYNCoverChooserController* coverChooserController;
@property (nonatomic, strong) SYNGenreTabViewController *categoriesTabViewController;
@property (nonatomic, strong) SYNReportConcernTableViewController *reportConcernTableViewController;
@property (nonatomic, strong) UIActivityIndicatorView* subscribingIndicator;
@property (nonatomic, strong) UIImage* originalBackgroundImage;
@property (nonatomic, strong) UIView *coverChooserMasterView;
@property (nonatomic, strong) UIView* noVideosMessageView;
@property (nonatomic, strong) id<SDWebImageOperation> currentWebImageOperation;
@property (nonatomic, weak) Channel* originalChannel;
@property (nonatomic, weak) IBOutlet UIButton *cancelEditButton;
@property (nonatomic, weak) IBOutlet UIButton *editButton;
@property (nonatomic, weak) IBOutlet UILabel *byLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *shareActivityIndicator;

//iPhone specific
@property (nonatomic,strong) SYNChannelCoverImageSelectorViewController* coverImageSelector;
@property (strong,nonatomic) SYNChannelCategoryTableViewController *categoryTableViewController;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelTextInputButton;
@property (weak, nonatomic) IBOutlet UIImageView *textBackgroundImageView;


@end


@implementation SYNChannelDetailViewController

@synthesize channelCoverFetchedResultsController = _channelCoverFetchedResultsController;
@synthesize userChannelCoverFetchedResultsController = _userChannelCoverFetchedResultsController;
@synthesize channel = _channel;

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
    
    _isIPhone = [SYNDeviceManager.sharedInstance isIPhone];

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

    self.channelTitleTextView.placeholder = NSLocalizedString (@"channel_creation_screen_field_channeltitle_placeholder", nil);
    
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
    layout.itemSize = _isIPhone?CGSizeMake(310.0f , 175.0f):CGSizeMake(249.0f , 141.0f);
    layout.minimumInteritemSpacing = _isIPhone ? 0.0f : 4.0f;
    layout.minimumLineSpacing = _isIPhone ? 4.0f : 4.0f;
    
    self.videoThumbnailCollectionView.collectionViewLayout = layout;
    
    if (_isIPhone)
    {
        layout.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        self.videoThumbnailCollectionView.contentInset = UIEdgeInsetsMake([SYNDeviceManager.sharedInstance currentScreenHeight] - 168.0f, 0.0f, 0.0f, 0.0f);
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

    if (!_isIPhone)
    {
        // Create categories tab, but make invisible (alpha = 0) for now
        self.categoriesTabViewController = [[SYNGenreTabViewController alloc] initWithHomeButton: @"other"];
        self.categoriesTabViewController.delegate = self;
        CGRect tabFrame = self.categoriesTabViewController.view.frame;
        tabFrame.origin.y = kChannelCreationCategoryTabOffsetY;
        tabFrame.size.width = self.view.frame.size.width;
        self.categoriesTabViewController.view.frame = tabFrame;
        
        self.categoriesTabViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.categoriesTabViewController.view.alpha = 0.0f;
        [self addChildViewController: self.categoriesTabViewController];
    }
    
    
    self.originalMasterControlsViewOrigin = self.masterControlsView.frame.origin;
    
    
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
    
    if (!_isIPhone)
    {
        // Set text on add cover and select category buttons
        NSString *coverString = NSLocalizedString (@"channel_creation_screen_button_selectcover_label", nil);
        
        NSMutableAttributedString* attributedCoverString = [[NSMutableAttributedString alloc] initWithString: coverString
                                                                                                  attributes: @{NSForegroundColorAttributeName : [UIColor colorWithRed: 40.0f/255.0f green: 45.0f/255.0f blue: 51.0f/255.0f alpha: 1.0f],
                                                                                        NSFontAttributeName : [UIFont boldRockpackFontOfSize: 18.0f]}];
        
        [self.addCoverButton setAttributedTitle: attributedCoverString
                                       forState: UIControlStateNormal];
        
        // Now do fancy attributed string
        NSString *categoryString = NSLocalizedString (@"channel_creation_screen_button_selectcat_label", nil);

        
        NSMutableAttributedString* attributedCategoryString = [[NSMutableAttributedString alloc] initWithString: categoryString
                                                                                                     attributes: @{NSForegroundColorAttributeName : [UIColor colorWithRed: 40.0f/255.0f green: 45.0f/255.0f blue: 51.0f/255.0f alpha: 1.0f],
                                                                                           NSFontAttributeName : [UIFont boldRockpackFontOfSize: 18.0f]}];
        
        // Set text on add cover and select category buttons
        [self.selectCategoryButton setAttributedTitle: attributedCategoryString
                                             forState: UIControlStateNormal];
        
        self.coverChooserController = [[SYNCoverChooserController alloc] initWithSelectedImageURL: self.channel.channelCover.imageUrl];
        [self addChildViewController: self.coverChooserController];
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
    }
    
    self.selectedCategoryId = self.channel.categoryId;
    self.selectedCoverId = @"";

    CGRect correctRect = self.coverChooserMasterView.frame;
    correctRect.origin.y = 404.0;
    self.coverChooserMasterView.frame = correctRect;
    [self.editControlsView addSubview:self.coverChooserMasterView];
    
    self.cameraButton = self.coverChooserController.cameraButton;
    
    [self.cameraButton addTarget:self action:@selector(userTouchedCameraButton:) forControlEvents:UIControlEventTouchUpInside];
    
    if(self.autoplayVideoId)
    {
        [self autoplayVideoIfAvailable];
    }
    
    self.originalContentOffset = self.videoThumbnailCollectionView.contentOffset;
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    
    NSString *viewMode = [NSString stringWithFormat: @"Channels - Detail - %@", (self.mode == kChannelDetailsModeDisplay) ? @"Display" : @"Edit"];
    
    // Google analytics support
    [GAI.sharedInstance.defaultTracker sendView: viewMode];
    
    [self.channelTitleTextView addObserver: self
                                forKeyPath: kTextViewContentSizeKey
                                   options: NSKeyValueObservingOptionNew
                                   context: NULL];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(coverImageChangedHandler:)
                                                 name: kCoverArtChanged
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoQueueCleared)
                                                 name:kVideoQueueClear
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFailed:)
                                                 name:kUpdateFailed
                                               object:nil];
    
    if(self.channel.channelOwner.uniqueId == appDelegate.currentUser.uniqueId)
    {
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                selector: @selector(reloadUserImage:)
                                                name: kUserDataChanged
                                                object: nil];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteSearchBarRequestHide
                                                        object: self];

    self.subscribeButton.enabled = YES;
    
    
    self.subscribeButton.selected = self.channel.subscribedByUserValue;
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteSearchBarRequestHide
                                                        object: self];
    
    
    
    // We set up assets depending on whether we are in display or edit mode
    [self setDisplayControlsVisibility: (self.mode == kChannelDetailsModeDisplay)];
    
    // Refresh our view
    [self.videoThumbnailCollectionView reloadData];
    
    
    if(self.channel.videoInstances.count == 0)
    {
        [self showNoVideosMessage: NSLocalizedString(@"channel_screen_loading_videos", nil) withLoader:YES];
    }
    
    [self displayChannelDetails];
    
}


- (void) viewWillDisappear: (BOOL) animated
{
    
    [super viewWillDisappear: animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteAllNavControlsShow
                                                        object: self
                                                      userInfo: nil];
    
    [self.channelTitleTextView removeObserver: self
                                   forKeyPath: kTextViewContentSizeKey];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kCoverArtChanged
                                                  object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kUserDataChanged
                                                  object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kUpdateFailed
                                                  object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kVideoQueueClear
                                                  object:nil];

    if(!_isIPhone)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: kVideoQueueClear
                                                        object: self
                                                      userInfo: nil];
    }

    
    if (self.subscribingIndicator)
    {
        [self.subscribingIndicator removeFromSuperview];
        self.subscribingIndicator = nil;
    }

    
    // cancel the existing request if there is one
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kChannelUpdateRequest
                                                        object: self
                                                      userInfo: nil];
    
}



-(void) videoQueueCleared
{
    [self.videoThumbnailCollectionView reloadData];
}

-(void) updateFailed: (NSNotification*)notification
{
    self.subscribeButton.selected = self.channel.subscribedByUserValue;
    self.subscribeButton.enabled = YES;
    
    if (self.subscribingIndicator)
    {
        [self.subscribingIndicator removeFromSuperview];
        self.subscribingIndicator = nil;
    }
    
    self.channelDetailsLabel.text = [NSString stringWithFormat:
                                     NSLocalizedString(@"channel_screen_error_subscribe", nil)];
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


- (void) coverImageChangedHandler: (NSNotification*) notification
{
    NSDictionary * detailDictionary = [notification userInfo];
    NSString* coverArtUrl = (NSString* )[detailDictionary objectForKey: kCoverArt];
    UIImage* coverArtImage = (UIImage *)[detailDictionary objectForKey: kCoverArtImage];
    
    if (!coverArtUrl)
        return;
    
    if ([coverArtUrl isEqualToString: @""])
    {
        self.channelCoverImageView.image = nil;
        
    }
    else if ([coverArtUrl isEqualToString: @"uploading"])
    {
        [UIView transitionWithView: self.view
                          duration: 0.35f
                           options: UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                        animations: ^{
                            self.channelCoverImageView.image = coverArtImage;
                        }
                        completion: nil];
    }
    else
    {
        NSString* largeImageUrlString = [coverArtUrl stringByReplacingOccurrencesOfString:@"thumbnail_medium" withString:@"background"];
        [self.channelCoverImageView setImageWithURL: [NSURL URLWithString: largeImageUrlString]
                                   placeholderImage: [UIImage imageNamed: @"PlaceholderChannelCreation.png"]
                                            options: SDWebImageRetryFailed];
    }
    
    self.selectedCoverId = [detailDictionary objectForKey:kCoverImageReference];
    
    self.originalBackgroundImage = nil;
}


#pragma mark - Orientation Methods

- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                 duration: (NSTimeInterval) duration
{
    [super willRotateToInterfaceOrientation: toInterfaceOrientation
                                   duration: duration];

    [self.videoThumbnailCollectionView.collectionViewLayout invalidateLayout];
}


- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    [super willAnimateRotationToInterfaceOrientation: toInterfaceOrientation
                                            duration: duration];
    
    UIImage* croppedImage = [self croppedImageForOrientation: toInterfaceOrientation];
    
    self.channelCoverImageView.image = croppedImage;
}


- (void) handleDataModelChange: (NSNotification*) notification
{

    
    NSArray* updatedObjects = [[notification userInfo] objectForKey: NSUpdatedObjectsKey];
    NSArray* insertedObjects = [[notification userInfo] objectForKey: NSInsertedObjectsKey];
    NSArray* deletedObjects = [[notification userInfo] objectForKey: NSDeletedObjectsKey];
    

    
    [updatedObjects enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        
        
        if (obj == self.channel)
        {
            
            self.subscribeButton.selected = self.channel.subscribedByUserValue;
            self.subscribeButton.enabled = YES;
            
            if (self.subscribingIndicator)
            {
                [self.subscribingIndicator removeFromSuperview];
                self.subscribingIndicator = nil;
            }
            
            
            
            // == Handle Rest == //
            
            if(self.channel.videoInstances.count == 0)
            {
                [self showNoVideosMessage: NSLocalizedString(@"channel_screen_no_videos",nil) withLoader:NO];
            }
            else
            {
                [self showNoVideosMessage:nil withLoader:NO];
            }
            
            
            // == Handle Inserted ==
            
            
            NSMutableArray* insertedIndexPathArray = [NSMutableArray arrayWithCapacity:insertedObjects.count]; // maximum
            
            [self.channel.videoInstances enumerateObjectsUsingBlock:^(VideoInstance* videoInstance, NSUInteger cidx, BOOL *cstop) {
                
                
                
                [insertedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    
                    if(obj == videoInstance)
                    {
                        NSLog(@"CD(+) Inserted (%@): %@", NSStringFromClass([obj class]), ((VideoInstance*)obj).title);
                        
                        [insertedIndexPathArray addObject:[NSIndexPath indexPathForItem:cidx inSection:0]];
                    }
                }];
                
            }];
            
            
            // == Handle Deleted == //
            
            NSMutableArray* deletedIndetifiers = [NSMutableArray arrayWithCapacity:deletedObjects.count];
            NSMutableArray* deletedIndexPathArray = [NSMutableArray arrayWithCapacity:deletedObjects.count]; // maximum
            [deletedObjects enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
                
                if ([obj isKindOfClass:[VideoInstance class]]) {
                    
                    NSLog(@"CD(-) Deleted: %@", ((VideoInstance*)obj).title);
                    
                    [deletedIndetifiers addObject:((VideoInstance*)obj).uniqueId];
                    
                }
                
            }];
            
            int index = 0;
            for(SYNVideoThumbnailRegularCell* cell in self.videoThumbnailCollectionView.visibleCells){
                
                if([deletedIndetifiers containsObject:cell.dataIndetifier])
                {
                    NSLog(@"CD(-) Found Cell at: %i", index);
                    [deletedIndexPathArray addObject:[NSIndexPath indexPathForItem:index inSection:0]];
                }
                index++;
                
            }
            
            
            [self.videoThumbnailCollectionView performBatchUpdates:^{
                
                if(insertedIndexPathArray.count > 0)
                    [self.videoThumbnailCollectionView insertItemsAtIndexPaths:insertedIndexPathArray];
                
                if(deletedIndexPathArray.count > 0)
                    [self.videoThumbnailCollectionView deleteItemsAtIndexPaths:deletedIndexPathArray];
                
            } completion:^(BOOL finished) {
                
            }];
            
            
            return;
            
        }
        else if(obj  == appDelegate.currentUser) // if username is being updated by account settings (or the private/public ivar)
        {
            [self updateChannelOwnerWithUser];
        }
    }];
    
    
}

- (void) showNoVideosMessage:(NSString*)message withLoader:(BOOL)withLoader
{
    if (self.noVideosMessageView)
    {
        [self.noVideosMessageView removeFromSuperview];
        self.noVideosMessageView = nil;  
    }
    
    if (!message)
        return;
    
    CGSize viewFrameSize = _isIPhone ? CGSizeMake(300.0, 50.0) : CGSizeMake(360.0, 50.0);
    if(withLoader && !_isIPhone)
    {
        viewFrameSize.width = 380.0;
    }
  
    self.noVideosMessageView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 640.0, viewFrameSize.width, viewFrameSize.height)];
    self.noVideosMessageView.center = _isIPhone ? CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height - 70.0f) : CGPointMake(self.view.frame.size.width * 0.5, self.noVideosMessageView.center.y);
    self.noVideosMessageView.frame = CGRectIntegral(self.noVideosMessageView.frame);
    self.noVideosMessageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    UIView* noVideosBGView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, viewFrameSize.width, viewFrameSize.height)];
    noVideosBGView.backgroundColor = [UIColor blackColor];
    noVideosBGView.alpha = 0.3;
    
    [self.noVideosMessageView addSubview:noVideosBGView];
    
    
    UILabel* noVideosLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    noVideosLabel.text = message;
    noVideosLabel.textAlignment = NSTextAlignmentCenter;
    noVideosLabel.font = [UIFont rockpackFontOfSize:_isIPhone?12.0f:16.0f];
    noVideosLabel.textColor = [UIColor whiteColor];
    [noVideosLabel sizeToFit];
    noVideosLabel.backgroundColor = [UIColor clearColor];
    noVideosLabel.center = CGPointMake(viewFrameSize.width * 0.5, viewFrameSize.height * 0.5 + 4.0);
    noVideosLabel.frame = CGRectIntegral(noVideosLabel.frame);
    
    if (withLoader && !_isIPhone)
    {
        UIActivityIndicatorView* loader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        CGRect loaderRect = loader.frame;
        loaderRect.origin.x = noVideosLabel.frame.origin.x + noVideosLabel.frame.size.width + 8.0;
        loaderRect.origin.y = 16.0;
        loader.frame = loaderRect;
        [self.noVideosMessageView addSubview:loader];
        [loader startAnimating]; 
    }

    [self.noVideosMessageView addSubview:noVideosLabel];
    
    [self.view addSubview:self.noVideosMessageView];
}


- (void) reloadCollectionViews
{
    [self.videoThumbnailCollectionView reloadData];
    
    [self displayChannelDetails];
    
    if(self.autoplayVideoId)
    {
        [self autoplayVideoIfAvailable];
    }
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
    self.channelOwnerLabel.text = [self.channel.channelOwner.displayName uppercaseString];
    
    NSString *detailsString;
    
    if (self.channel.publicValue)
    {
        detailsString = [NSString stringWithFormat: @"%lld %@", self.channel.subscribersCountValue, NSLocalizedString(@"SUBSCRIBERS", nil)];
        self.shareButton.hidden = FALSE;
    }
    else
    {
        detailsString = @"PRIVATE";
        self.shareButton.hidden = TRUE;
    }
    self.channelDetailsLabel.text = detailsString;
    
    // If we have a valid ecommerce URL, then display the button
    if (self.channel.eCommerceURL != nil && ![self.channel.eCommerceURL isEqualToString: @""])
    {
        self.buyButton.hidden = FALSE;
    }
    
    // Set title //
    if (self.channel.title)
    {
        self.channelTitleTextView.text = self.channel.title;
    }
    else
    {
        self.channelTitleTextView.text = @"";
    }

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
    
    // special mode for the favorite channel so we cannot delete the videos (un-heart them only)
    
    if (self.channel.favouritesValue)
    {
        videoThumbnailCell.displayMode = kChannelThumbnailDisplayModeDisplayFavourite;
    }
    else
    {
        videoThumbnailCell.displayMode = self.mode;
    }
    
    VideoInstance *videoInstance = self.channel.videoInstances [indexPath.item];
    
    
    [videoThumbnailCell.imageView setImageWithURL: [NSURL URLWithString: videoInstance.video.thumbnailURL]
                                 placeholderImage: [UIImage imageNamed: @"PlaceholderVideoWide.png"]
                                          options: SDWebImageRetryFailed];
    
    videoThumbnailCell.titleLabel.text = videoInstance.title;
    videoThumbnailCell.viewControllerDelegate = self;
    
    videoThumbnailCell.dataIndetifier = videoInstance.uniqueId;
    
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

-(void)autoplayVideoIfAvailable
{
    NSArray* videoSubset = [[self.channel.videoInstances array] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uniqueId == %@",self.autoplayVideoId]];
    if([videoSubset count] ==1)
    {
        [self displayVideoViewerWithVideoInstanceArray: self.channel.videoInstances.array
                                      andSelectedIndex: [self.channel.videoInstances indexOfObject:[videoSubset objectAtIndex:0]]];
        self.autoplayVideoId= nil;
    }
}


#pragma mark - LXReorderableCollectionViewDelegateFlowLayout methods

- (void) collectionView: (UICollectionView *) collectionView
        itemAtIndexPath: (NSIndexPath *) fromIndexPath
    willMoveToIndexPath: (NSIndexPath *) toIndexPath
{
    VideoInstance* viToSwap = [self.channel.videoInstancesSet objectAtIndex:fromIndexPath.item];
    [self.channel.videoInstancesSet removeObjectAtIndex:fromIndexPath.item];
    [self.channel.videoInstancesSet insertObject:viToSwap atIndex:toIndexPath.item];
    
    // set the new positions
    [self.channel.videoInstances enumerateObjectsUsingBlock: ^(id obj, NSUInteger index, BOOL *stop) {
        [(VideoInstance *)obj setPositionValue : index];
    }];
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
    
    // If the current user's favourites channel, hide edit button and move subscribers
    if (self.channel.favouritesValue && [self.channel.channelOwner.uniqueId isEqualToString:appDelegate.currentUser.uniqueId])
    {
        self.editButton.hidden = TRUE;
        
        CGFloat offset = 125;
        
        if (!_isIPhone)
        {
            offset = 130;
        }

        CGRect frame = self.channelDetailsLabel.frame;
        frame.origin.x -= offset;
        self.channelDetailsLabel.frame = frame;
    }
    
    [(LXReorderableCollectionViewFlowLayout *)self.videoThumbnailCollectionView.collectionViewLayout longPressGestureRecognizer].enabled = (visible) ? FALSE : TRUE;
    
//    self.channel.favouritesValue
    
    if (visible == NO)
    {
        // If we are in edit mode, then hide navigation controls
        [[NSNotificationCenter defaultCenter] postNotificationName: kChannelsNavControlsHide
                                                            object: self
                                                          userInfo: nil];
    }
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

        
        [tv setContentOffset: (CGPoint){.x = 0, .y = -topCorrect}
                    animated: NO];
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
       arrowDirections: UIPopoverArrowDirectionRight
     activityIndicator: self.shareActivityIndicator
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
    if([self.channel.channelOwner.uniqueId isEqualToString:appDelegate.currentUser.uniqueId])
    {
        NSNotification* navigationNotification = [NSNotification notificationWithName: kNavigateToPage
                                                                               object: self
                                                                             userInfo: @{@"pageName":kProfileViewId}];
        
        [[NSNotificationCenter defaultCenter] postNotification: navigationNotification];
        return;
    }
    
    [self viewProfileDetails: self.channel.channelOwner];
}


- (void) videoAddButtonTapped: (UIButton *) addButton
{
    NSString* noteName;
    
    if (!addButton.selected || _isIPhone) // There is only ever one video in the queue on iPhone. Always fire the add action.
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

#pragma mark - Deleting Video Instances

- (void) videoDeleteButtonTapped: (UIButton *) deleteButton
{
    UIView *v = deleteButton.superview.superview;
    
    self.indexPathToDelete = [self.videoThumbnailCollectionView indexPathForItemAtPoint: v.center];
    
    VideoInstance* videoInstanceToDelete = (VideoInstance*)self.channel.videoInstances[self.indexPathToDelete.item];
    
    if (!videoInstanceToDelete)
        return;
    
    [[[UIAlertView alloc] initWithTitle: NSLocalizedString (@"channel_creation_screen_channel_delete_dialog_title", nil)
                                message: NSLocalizedString (@"channel_creation_screen_video_delete_dialog_description", nil)
                               delegate: self
                      cancelButtonTitle: NSLocalizedString (@"Cancel", nil)
                      otherButtonTitles: NSLocalizedString (@"Delete", nil), nil] show];
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
        [self deleteVideoInstance];
        
        
    }
}

- (void) deleteVideoInstance
{
    VideoInstance* videoInstanceToDelete = (VideoInstance*)self.channel.videoInstances[self.indexPathToDelete.item];
    
    if (!videoInstanceToDelete)
        return;
    
    
   
    
    UICollectionViewCell* cell =
    [self.videoThumbnailCollectionView cellForItemAtIndexPath:self.indexPathToDelete];
    
    [UIView animateWithDuration:0.2 animations:^{
        
        cell.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
        
         [self.channel.videoInstancesSet removeObject:videoInstanceToDelete];
        
        [videoInstanceToDelete.managedObjectContext deleteObject:videoInstanceToDelete];
        
        
        [self.videoThumbnailCollectionView deleteItemsAtIndexPaths:@[self.indexPathToDelete]];
        
        [appDelegate saveContext:YES];
        
        
    }];
}

- (IBAction) addCoverButtonTapped: (UIButton *) button
{
    // Prevent multiple clicks of the add cover button on iPhone
    if (_isIPhone)
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
    [[NSNotificationCenter defaultCenter] postNotificationName: (! _isIPhone) ? kChannelsNavControlsHide : kNoteAllNavControlsHide
                                                        object: self
                                                      userInfo: nil];
    
    [self setEditControlsVisibility: YES];
    [self.createChannelButton removeFromSuperview];
    [self.view addSubview:self.saveChannelButton];
    CGRect newFrame = self.saveChannelButton.frame;
    newFrame.origin.x = self.view.frame.size.width  - newFrame.size.width;
    self.saveChannelButton.frame = newFrame;
    self.saveChannelButton.hidden = NO;
    self.cancelEditButton.hidden = NO;
    self.backButton.hidden = YES;
    self.addButton.hidden = YES;
    
    
    if (self.channel.categoryId)
    {
        //If a category is already selected on the channel, we should display it when entering edit mode
        
        NSEntityDescription* categoryEntity = [NSEntityDescription entityForName: @"Genre"
                                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
        NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
        [categoriesFetchRequest setEntity:categoryEntity];
    
        NSPredicate* excludePredicate = [NSPredicate predicateWithFormat:@"uniqueId== %@", self.channel.categoryId];
        [categoriesFetchRequest setPredicate:excludePredicate];
    
        NSError* error;
    
        NSArray* selectedCategoryResult = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                error: &error];
        if ([selectedCategoryResult count]>0)
        {
            Genre* genre = selectedCategoryResult[0];
            NSString* newTitle = nil;
            if ([genre isKindOfClass:[SubGenre class]])
            {
                SubGenre* subCategory = (SubGenre*) genre;
                if (_isIPhone)
                {
                    newTitle =[NSString stringWithFormat:@"%@/\n%@", subCategory.genre.name, subCategory.name];
                }
                else
                {
                    newTitle =[NSString stringWithFormat:@"%@/%@", subCategory.genre.name, subCategory.name];
                }
            }
            else
            {
                newTitle = genre.name;
            }
            
            if (!_isIPhone)
            {
                [self updateCategoryButtonText:newTitle];
            }
            else
            {
                [self.selectCategoryButton setTitle: newTitle
                                        forState: UIControlStateNormal];
            }
        }
        self.selectedCategoryId = self.channel.categoryId;
    }
    
}


- (IBAction) cancelEditTapped: (id) sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteAllNavControlsShow
                                                        object: self
                                                      userInfo: nil];
    
    [self setEditControlsVisibility: NO];
    [self displayChannelDetails];
    self.categoryTableViewController = nil;
    self.saveChannelButton.hidden = YES;
    self.cancelEditButton.hidden = YES;
    self.addButton.hidden = NO;
    self.backButton.hidden= NO;

}


- (IBAction) saveChannelTapped: (id) sender
{ 
    self.saveChannelButton.enabled = NO;
    [self.activityIndicator startAnimating];
    
    [self hideCategoryChooser];
    
    self.channel.channelDescription = self.channel.channelDescription ? self.channel.channelDescription : @"";
    

    NSString* category = [self categoryIdStringForServiceCall];
    
    NSString* cover = [self coverIdStringForServiceCall];
    
    [appDelegate.oAuthNetworkEngine updateChannelForUserId: appDelegate.currentOAuth2Credentials.userId
                                                 channelId: self.channel.uniqueId
                                                     title: self.channelTitleTextView.text
                                               description: (self.channel.channelDescription)
                                                  category: category
                                                     cover: cover
                                                  isPublic: YES
                                         completionHandler: ^(NSDictionary* resourceCreated) {

                                             NSString* channelId = [resourceCreated objectForKey: @"id"];
                                             
                                             [self setEditControlsVisibility: NO];
                                             self.saveChannelButton.enabled = YES;
                                             [self.activityIndicator stopAnimating];
                                             self.saveChannelButton.hidden = YES;
                                             self.cancelEditButton.hidden = YES;
                                             self.addButton.hidden = NO;
                                             
                                             [self setVideosForChannelById: channelId
                                                                 isUpdated: YES];
                                             
                                             [[NSNotificationCenter defaultCenter] postNotificationName: kNoteAllNavControlsShow
                                                                                                 object: self
                                                                                               userInfo: nil];

                                             // this block will also call the [self getChanelById:channelId isUpdated:YES] //
                                         }
                                              errorHandler: ^(id error) {
                                                  
                                                  DebugLog(@"Error @ saveChannelPressed:");
                                                  
                                                  NSString *errorTitle = NSLocalizedString(@"channel_creation_screen_error_unknown_title", nil);
                                                  NSString* errorMessage = NSLocalizedString(@"channel_creation_screen_error_unknown_save_description", nil);
                                                  
                                                  NSArray *errorTitleArray =  [[error objectForKey: @"form_errors"] objectForKey :@"title"];
                                                  
                                                  if ([errorTitleArray count] > 0)
                                                  {
                                                      
                                                      NSString* errorType = [errorTitleArray objectAtIndex:0];
                                                      
                                                      if ([errorType isEqualToString:@"Duplicate title."])
                                                      {
                                                          errorTitle = NSLocalizedString(@"channel_creation_screen_error_existing_dialog_title", nil);
                                                          errorMessage = NSLocalizedString(@"channel_creation_screen_error_existing_dialog_description",nil);
                                                      }
                                                      
                                                      else if ([errorType isEqualToString:@"Mind your language!"])
                                                      {
                                                          errorTitle = NSLocalizedString(@"channel_creation_screen_error_inappropriate_dialog_title", nil);
                                                          errorMessage = NSLocalizedString(@"channel_creation_screen_error_inappropriate_dialog_description",nil);
                                                      }
                                                      
                                                      else
                                                      {
                                                          errorTitle = NSLocalizedString(@"channel_creation_screen_error_unknown_title", nil);
                                                          errorMessage = NSLocalizedString(@"channel_creation_screen_error_unknown_save_description",nil);
                                                      }
                                                  };
                                          
                                                  [self showError: errorMessage showErrorTitle:errorTitle];
                                                  self.saveChannelButton.hidden = NO;
                                                  self.saveChannelButton.enabled = YES;
                                                  [self.activityIndicator stopAnimating];
                                                  [self.activityIndicator stopAnimating];
                                              }];
}


#pragma mark - Cover choice

- (void) showCoverChooser
{
    if (!_isIPhone)
    {
        // Check to see if we are already display the cover chooser
        if (self.coverChooserMasterView.alpha == 0.0f)
        {
            
            [self.coverChooserController updateCoverArt];
            
            
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
        self.coverImageSelector = [[SYNChannelCoverImageSelectorViewController alloc] initWithSelectedImageURL: self.channel.channelCover.imageUrl];
        self.coverImageSelector.imageSelectorDelegate = self;
        CGRect startFrame = self.coverImageSelector.view.frame;
        startFrame.origin.y = self.view.frame.size.height;
        self.coverImageSelector.view.frame = startFrame;
        [self.view addSubview:self.coverImageSelector.view];
        
        [UIView animateWithDuration: 0.3f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             CGRect endFrame = self.coverImageSelector.view.frame;
                             endFrame.origin.y = 0.0f;
                             self.coverImageSelector.view.frame = endFrame;
                         }
                         completion:nil];
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


#pragma mark - Genre Choose Bar

- (void) showCategoryChooser
{
    if (!_isIPhone)
    {
        [self.view addSubview: self.categoriesTabViewController.view];
        
        if (self.categoriesTabViewController.view.alpha == 0.0f)
        {
            [UIView animateWithDuration: kChannelEditModeAnimationDuration
                             animations: ^{
                                 // Fade up the category tab controller // 
                                 self.categoriesTabViewController.view.alpha = 1.0f;   
                             }
                             completion: ^(BOOL finished) {

                                 if ([self.selectedCategoryId isEqualToString: @""])
                                 {
                                     // if no category has been selected the "other" category if it exists
                                    if( self.categoriesTabViewController.otherGenre)
                                    {
                                        [self handleNewTabSelectionWithGenre: self.categoriesTabViewController.otherGenre];
                                    }
                                 }
                                 else
                                 {
                                     NSIndexPath* genreIndexPath = [self.categoriesTabViewController findIndexPathForGenreId: self.selectedCategoryId];
                                     if(!genreIndexPath)
                                     {
                                         //"Other/other" selected. Do nothing
                                         return;
                                     }
                                     Genre* genreSelected =
                                     [self.categoriesTabViewController selectAndReturnGenreForIndexPath: genreIndexPath
                                                                                       andSubcategories: YES];
                                     
                                     if (genreSelected)
                                     {
                                         if ([genreSelected isMemberOfClass: [Genre class]])
                                         {
                                             [self updateCategoryButtonText: genreSelected.name];
                                         }
                                         else
                                         {
                                             [self updateCategoryButtonText: [NSString stringWithFormat: @"%@/%@",
                                                                              ((SubGenre*)genreSelected).genre.name, genreSelected.name]];
                                         }   
                                     }
                                     else
                                     {
                                         [self.categoriesTabViewController deselectAll];
                                     }
                                 }

                                 [UIView animateWithDuration: 0.4f
                                                       delay: 0.1f
                                                     options: UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                                                  animations: ^{
                                                      // slide down the video collection view a bit //
                                                      CGFloat totalY =
                                                      kChannelCreationCollectionViewOffsetY + kChannelCreationCategoryAdditionalOffsetY;
                                                      self.videoThumbnailCollectionView.contentInset = UIEdgeInsetsMake(totalY, 0, 0, 0);
                                                      
                                                      CGFloat totalX =
                                                      kChannelCreationCollectionViewOffsetY + kChannelCreationCategoryAdditionalOffsetY;
                                                      self.videoThumbnailCollectionView.contentOffset = CGPointMake (0, -(totalX));
                                     
                                                  }
                                                  completion:^(BOOL finished) {
                                     
                                                  }];
                             }];
        }
    }
    else // isIPhone
    {
        if (!self.categoryTableViewController)
        {
            self.categoryTableViewController = [[SYNChannelCategoryTableViewController alloc] initWithNibName:@"SYNChannelCategoryTableViewControllerFullscreen~iphone" bundle: [NSBundle mainBundle]];
            self.categoryTableViewController.categoryTableControllerDelegate = self;
            self.categoryTableViewController.showAllCategoriesHeader = NO;
            
            [self.view addSubview:self.categoryTableViewController.view];
            
            BOOL hasACategory = [self.selectedCategoryId length]>0;
            [self.categoryTableViewController setSelectedCategoryForId:hasACategory?self.selectedCategoryId:nil];
            if(!hasACategory)
            {
                // Set the default other/other subgenre
                NSArray* filteredSubcategories = [[self.categoryTableViewController.otherGenre.subgenres array] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isDefault == YES"]];
                 if([filteredSubcategories count] == 1)
                 {
                     SubGenre* otherSubGenre = filteredSubcategories[0];
                     
                     self.selectedCategoryId = otherSubGenre.uniqueId;
                     
                     [self.selectCategoryButton setTitle: [NSString stringWithFormat:@"%@/\n%@", otherSubGenre.genre.name, otherSubGenre.name]
                                                forState: UIControlStateNormal];
                 }
            }
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
        startFrame.size.height = self.view.frame.size.height;
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
                         completion:^(BOOL finished) {
                             [self.categoriesTabViewController.view removeFromSuperview];
                         }];
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


#pragma mark - iPad Category Tab Delegate

- (BOOL) showSubGenres
{
    return YES;
}


- (void) handleNewTabSelectionWithGenre: (Genre*) genre
{
    // the tab selector should alwaysreturn a genre. If no genre is sent, the "Othre" category is missing and we will have to make do with an empty string.
    if (!genre)
    {
        
        self.selectedCategoryId = @"";
        [self updateCategoryButtonText: @"OTHER"];
        return;
    }

    // update the text field with the format "GENRE/SUBGENRE"
    if ([genre isMemberOfClass: [SubGenre class]])
    {
        [self hideCategoryChooser];
        [self updateCategoryButtonText: [NSString stringWithFormat:@"%@/%@", ((SubGenre*)genre).genre.name, genre.name]];
        self.selectedCategoryId = genre.uniqueId;
    }
    else
    {
        NSArray* filteredSubcategories = [[genre.subgenres array] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isDefault == YES"]];
        if ([filteredSubcategories count] == 1)
        {
            SubGenre* otherSubGenre = filteredSubcategories[0];
            
            self.selectedCategoryId = otherSubGenre.uniqueId;
            
            [self updateCategoryButtonText: [NSString stringWithFormat:@"%@/%@", otherSubGenre.genre.name, otherSubGenre.name]];
        }
        else
        {
            self.selectedCategoryId = genre.uniqueId;
            [self updateCategoryButtonText: genre.name];
        }
    }
}


#pragma mark - Channel Creation (3 steps)

- (IBAction) createChannelPressed: (id) sender
{
    self.isLocked = YES; // prevent back button from firing
    
    self.createChannelButton.enabled = NO;
    [self.activityIndicator startAnimating];
    
    [self hideCategoryChooser];
    
    self.channel.title = self.channelTitleTextView.text;
    
    self.channel.channelDescription = self.channel.channelDescription ? self.channel.channelDescription : @"";
    
    NSString* category = [self categoryIdStringForServiceCall];
    
    NSString* cover =  self.selectedCoverId;
    
    if ([cover length]==0)
    {
        cover = @"";
    }
    
    [appDelegate.oAuthNetworkEngine createChannelForUserId: appDelegate.currentOAuth2Credentials.userId
                                                     title: self.channel.title
                                               description: self.channel.channelDescription
                                                  category: category
                                                     cover: cover
                                                  isPublic: YES
                                         completionHandler: ^(NSDictionary* resourceCreated) {
                                             
                                             
                                             NSString* channelId = [resourceCreated objectForKey: @"id"];
                                             
                                             self.createChannelButton.enabled = YES;
                                             self.createChannelButton.hidden = YES;
                                             [self.activityIndicator stopAnimating];
                                             
                                             [self setVideosForChannelById:channelId isUpdated:NO];
                                             
                                         } errorHandler: ^(id error) {
                                             
                                                  self.isLocked = NO;
                                                  
                                                  DebugLog(@"Error @ createChannelPressed:");
                                                  
                                                  NSString *errorTitle = NSLocalizedString(@"channel_creation_screen_error_unknown_title", nil);
                                                  NSString* errorMessage = NSLocalizedString(@"channel_creation_screen_error_unknown_create_description", nil);
                                                  
                                                  NSArray *errorTitleArray =  [[error objectForKey: @"form_errors"] objectForKey :@"title"];
                                                  
                                                  if ([errorTitleArray count] > 0)
                                                  {
                                                      
                                                      NSString* errorType = [errorTitleArray objectAtIndex:0];
                                                      
                                                      if ([errorType isEqualToString:@"Duplicate title."])
                                                      {
                                                          errorTitle = NSLocalizedString(@"channel_creation_screen_error_existing_dialog_title", nil);
                                                          errorMessage = NSLocalizedString(@"channel_creation_screen_error_existing_dialog_description",nil);
                                                      }
                                                      
                                                      else if ([errorType isEqualToString:@"Mind your language!"])
                                                      {
                                                          errorTitle = NSLocalizedString(@"channel_creation_screen_error_inappropriate_dialog_title", nil);
                                                          errorMessage = NSLocalizedString(@"channel_creation_screen_error_inappropriate_dialog_description",nil);
                                                      }
                                                      
                                                      else
                                                      {
                                                          errorTitle = NSLocalizedString(@"channel_creation_screen_error_unknown_title", nil);
                                                          errorMessage = NSLocalizedString(@"channel_creation_screen_error_unknown_create_description",nil);
                                                      }
                                                  };
                                                  
                                                  
                                                  self.createChannelButton.enabled = YES;
                                                  self.cancelEditButton.hidden = YES;
                                                  self.addButton.hidden = YES;
                                             
                                                  [self showError: errorMessage
                                                   showErrorTitle:errorTitle];
                                             
                                              }];
}


- (void) setVideosForChannelById: (NSString*) channelId isUpdated:(BOOL) isUpdated
{
    self.isLocked = YES; // prevent back button from firing
    
    [appDelegate.oAuthNetworkEngine updateVideosForChannelForUserId: appDelegate.currentOAuth2Credentials.userId
                                                          channelId: channelId
                                                   videoInstanceSet: self.channel.videoInstances
                                                      clearPrevious: YES
                                                  completionHandler: ^(id response) {
                                                      
                                                      // a 204 returned
                                                      
                                                      [self fetchAndStoreUpdatedChannelForId:channelId isUpdate:isUpdated];
                                                      
                                                  } errorHandler: ^(id err) {
                                                      
                                                      self.isLocked = NO;
                                                      
                                                      NSString* errorMessage = nil;
                                                      
                                                      NSString* errorTitle = nil;
                                                      
                                                      if ([err isKindOfClass:[NSDictionary class]])
                                                      {
                                                          errorMessage = [err objectForKey:@"message"];
                                                          if (!errorMessage)
                                                          {
                                                              errorMessage = [err objectForKey:@"error"];
                                                          }
                                                      }
                                                      
                                                      self.addButton.hidden = YES;
                                                      
                                                      if(isUpdated)
                                                      {
                                                          
                                                          [self.activityIndicator stopAnimating];
                                                          self.cancelEditButton.hidden = NO;
                                                          self.cancelEditButton.enabled = YES;
                                                          self.createChannelButton.enabled = YES;
                                                          self.createChannelButton.hidden = NO;
                                                          
                                                          if(!errorMessage)
                                                          {
                                                              errorMessage = NSLocalizedString(@"Could not update the channel videos. Please review and try again later.", nil);
                                                          }
                                                          DebugLog(@"Error @ setVideosForChannelById:");
                                                          [self showError: errorMessage showErrorTitle:errorTitle];
                                                          
                                                      }
                                                      else
                                                      {
                                                          [self.activityIndicator stopAnimating];
                                                          self.cancelEditButton.hidden = YES;
                                                          self.cancelEditButton.enabled = YES;
                                                          self.saveChannelButton.enabled = YES;
                                                          self.saveChannelButton.hidden = NO;
                                                          
                                                          if(!errorMessage)
                                                          {
                                                              errorMessage = NSLocalizedString(@"Could not add videos to channel. Please review and try again later.", nil);
                                                          }
                                                          DebugLog(@"Error @ setVideosForChannelById:");
                                                          [self showError: errorMessage showErrorTitle:errorTitle];
                                                        
                                                      }
                                                      
                                                }];
}


- (void) fetchAndStoreUpdatedChannelForId: (NSString*) channelId isUpdate:(BOOL)isUpdate
{
    [appDelegate.oAuthNetworkEngine channelCreatedForUserId: appDelegate.currentOAuth2Credentials.userId
                                                  channelId: channelId
                                          completionHandler: ^(id dictionary) {
                                              
                                              Channel* createdChannel;
                                              
                                       
                                              if (!isUpdate) // its a new creation
                                              {
                                                  
                                                  createdChannel = [Channel instanceFromDictionary:dictionary
                                                                         usingManagedObjectContext:appDelegate.mainManagedObjectContext
                                                                               ignoringObjectTypes:kIgnoreChannelOwnerObject];
                                                  
                                                  
                                                  // this will automatically add the channel to the set of channels of the User
                                                  
                                                  [appDelegate.currentUser.channelsSet addObject:createdChannel];
                                                  
                                                  
                                                  if([createdChannel.categoryId isEqualToString:@""])
                                                      createdChannel.publicValue = NO;
                                                  
                                                  Channel* oldChannel = self.channel;
                                                  
                                                  self.channel = createdChannel;
                                                  
                                                  self.originalChannel = self.channel;
                                                  
                                                  [oldChannel.managedObjectContext deleteObject:oldChannel];
                                                  NSError* error;
                                                  [oldChannel.managedObjectContext save:&error];
                                                  
                                                  DebugLog(@"Channel: %@", createdChannel);
                                                  
                                                  // (the channel that was under creation will be deleted from the kVideoQueueClear notification)
                                                  
                                                  
                                              }
                                              else
                                              {
                                                  [self.channel setAttributesFromDictionary:dictionary
                                                                        ignoringObjectTypes:kIgnoreChannelOwnerObject];
                                                  
                                                  // if editing the user's channel we must update the original
                                                  
                                                  [self.originalChannel  setAttributesFromDictionary:dictionary
                                                                                 ignoringObjectTypes:kIgnoreChannelOwnerObject];
                                                  
                                                  for (VideoInstance* vi in self.channel.videoInstances)
                                                  {
                                                      NSLog(@"> %@", vi.uniqueId);
                                                  }
                                              }
                                              
                                              
                                              
                                              
                                              [appDelegate saveContext:YES];
                                              
                                              
                                              // Complete Channel Creation //
                                              
                                              self.channelOwnerLabel.text = [appDelegate.currentUser.displayName uppercaseString];
                                              
                                              [self displayChannelDetails];
                                              
                                              [self reloadUserImage: nil];
                                              
                                              [self setDisplayControlsVisibility:YES];
                                              
                                              self.mode = kChannelDetailsModeDisplay;
                                              
                                              [[NSNotificationCenter defaultCenter] postNotificationName: kNoteAllNavControlsShow
                                                                                                  object: self
                                                                                                userInfo: nil];
                                              
                                              [self finaliseViewStatusAfterCreateOrUpdate:!_isIPhone];
                                              
                                              [[NSNotificationCenter defaultCenter] postNotificationName: kVideoQueueClear
                                                                                                  object: nil];
                                              
                                              [[NSNotificationCenter defaultCenter] postNotificationName:kNoteChannelSaved
                                                                                                  object:self];
                                              
                                              self.isLocked = NO;
                                              
                                          } errorHandler:^(id err) {
                                              
                                              self.isLocked = NO;
                                              
                                              DebugLog(@"Error @ getNewlyCreatedChannelForId:");
                                              [self showError: NSLocalizedString(@"Could not retrieve the uploaded channel data. Please try accessing it from your profile later.", nil) showErrorTitle:@"Error"];
                                              self.channelOwnerLabel.text = [appDelegate.currentUser.displayName uppercaseString];
                                              
                                              [self displayChannelDetails];
                                              
                                              [self setDisplayControlsVisibility:YES];
                                              
                                              [[NSNotificationCenter defaultCenter] postNotificationName: kNoteAllNavControlsShow
                                                                                                  object: self
                                                                                                userInfo: nil];
                                              
                                              [self finaliseViewStatusAfterCreateOrUpdate:!_isIPhone];
                                            
                                              
                                              [[NSNotificationCenter defaultCenter] postNotificationName: kVideoQueueClear
                                                                                                  object: nil];
                                          }];
}

-(void)finaliseViewStatusAfterCreateOrUpdate:(BOOL)isIPad
{
    if (isIPad)
    {
        self.addButton.hidden = NO;
        self.createChannelButton.hidden = YES;
        
        
    }
    else
    {
        SYNMasterViewController *master = (SYNMasterViewController*) self.presentingViewController;
        if(master)
        {
            //This scenario happens on channel creation only and means this channel is presented modally.
            //After creation want to show it as if it is part of the master view hierarchy.
            //Thus we move the view there.
            
            //This removes the "existing channels view controller"
            [[[[master childViewControllers] lastObject] view] removeFromSuperview];
            
            //Now dimiss self modally (not animated)
            [master dismissViewControllerAnimated:NO completion:nil];
            
            //Change to display mode
            self.mode = kChannelDetailsModeDisplay;
            
            //Don't really like this, but send notification to hide title and dots for a seamless transition.
            [[NSNotificationCenter defaultCenter] postNotificationName: kNoteHideTitleAndDots
                                                                object: self
                                                              userInfo: nil];
            
            //And show as if displayed from the normal master view hierarchy
            SYNAbstractViewController *currentRootViewcontroller = [master showingBaseViewController];
            [currentRootViewcontroller animatedPushViewController:self];
        }
        
        [self setDisplayControlsVisibility:YES];
        [self.activityIndicator stopAnimating];
    }

}

- (void) showError: (NSString*) errorMessage showErrorTitle: (NSString*) errorTitle
{
    self.createChannelButton.hidden = NO;
    [self.activityIndicator stopAnimating];
        
    [[[UIAlertView alloc] initWithTitle: errorTitle
                                message: errorMessage
                               delegate: nil
                      cancelButtonTitle: NSLocalizedString(@"OK", nil)
                      otherButtonTitles: nil] show];
}


#pragma mark - channel and cover id preparation

-(NSString*)categoryIdStringForServiceCall
{
    NSString* category = self.selectedCategoryId;
    if ([category length] == 0)
    {
        category = self.channel.categoryId;
        if ([category length]==0)
        {
            category = @"";
        }
    }
    return category;
}


-(NSString*)coverIdStringForServiceCall
{
    NSString* cover = self.selectedCoverId;
    if ([cover length]==0)
    {
        cover = @"KEEP";
    }
    return cover;
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
    if (_isIPhone)
    {
        self.createChannelButton.hidden = YES;
        self.saveChannelButton.hidden = YES;
        self.cancelTextInputButton.hidden = NO;
    }
    
}


- (void) textViewDidEndEditing: (UITextView *) textView
{
    if (_isIPhone)
    {
        self.createChannelButton.hidden = NO;
        self.saveChannelButton.hidden = NO;
        self.cancelTextInputButton.hidden = YES;
    }
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
            self.reportConcernTableViewController = [[SYNReportConcernTableViewController alloc] initWithSendReportBlock: ^ (NSString *reportString){
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
    self.cameraButton.selected = NO;
    DebugLog(@"width %f, height %f", image.size.width, image.size.height);
    
    self.channelCoverImageView.image = image;
    
    [self uploadChannelImage: image];
    
    [self hideImagePicker];
}


- (void) hideImagePicker
{
    self.cameraButton.selected = NO;
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
    self.createChannelButton.enabled = FALSE;
    self.saveChannelButton.enabled = FALSE;
    [self.activityIndicator startAnimating];
    
    [self.coverChooserController createCoverPlaceholder: imageToUpload];
    
    // Upload the image for this user
    [appDelegate.oAuthNetworkEngine uploadCoverArtForUserId: appDelegate.currentOAuth2Credentials.userId
                                                      image: imageToUpload
                                          completionHandler: ^(NSDictionary *dictionary){
                                              self.createChannelButton.enabled = TRUE;
                                              self.saveChannelButton.enabled = TRUE;
                                              [self.activityIndicator stopAnimating];
                                              
                                              NSString *imageUrl = dictionary [@"thumbnail_url"];

                                              if (imageUrl && [imageUrl isKindOfClass:[NSString class]])
                                              {
                                                  self.channel.channelCover.imageUrl = imageUrl;
//                                                  [self.coverChooserController updateUserArtWithURL: imageUrl];
                                                  DebugLog(@"Success");
                                              }
                                              else
                                              {
                                                  DebugLog(@"Failed to upload wallpaper URL");
                                              }
                                              
                                              self.selectedCoverId = [dictionary objectForKey:@"cover_ref"];
                                          }
                                               errorHandler: ^(NSError* error) {
                                                   self.createChannelButton.enabled = TRUE;
                                                   self.saveChannelButton.enabled = TRUE;
                                                   [self.activityIndicator stopAnimating];
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
                                  forKey: nil];
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
}


- (void) addSubscribeActivityIndicator
{
    self.subscribingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
    CGRect indicatorRect = self.subscribingIndicator.frame;
    indicatorRect.origin.x = self.subscribeButton.frame.origin.x - 32.0;
    indicatorRect.origin.y = self.subscribeButton.frame.origin.y + 10.0;
    self.subscribingIndicator.frame = indicatorRect;
    [self.subscribingIndicator startAnimating];
    [self.view addSubview: self.subscribingIndicator];
}


#pragma mark - iPhone Category Table delegate

- (void) categoryTableController:(SYNChannelCategoryTableViewController *)tableController didSelectCategory:(Genre *)category
{
    if (category)
    {
        NSArray* filteredSubcategories = [[category.subgenres array] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isDefault == YES"]];
        if ([filteredSubcategories count] == 1)
        {
            SubGenre* otherSubGenre = filteredSubcategories[0];
            
            self.selectedCategoryId = otherSubGenre.uniqueId;
            
            [self.selectCategoryButton setTitle: [NSString stringWithFormat:@"%@/\n%@", otherSubGenre.genre.name, otherSubGenre.name]
                                       forState: UIControlStateNormal];
        }
        else
        {
            self.selectedCategoryId = category.uniqueId;
            
            [self.selectCategoryButton setTitle: category.name
                                       forState: UIControlStateNormal];
        }
        [self hideCategoriesTable];
    }
}

- (void) categoryTableController:(SYNChannelCategoryTableViewController *)tableController didSelectSubCategory:(SubGenre *)subCategory
{
    self.selectedCategoryId = subCategory.uniqueId;
    
    [self.selectCategoryButton setTitle: [NSString stringWithFormat:@"%@/\n%@", subCategory.genre.name, subCategory.name]
                               forState: UIControlStateNormal];
    
    [self hideCategoriesTable];
}

- (void) categoryTableControllerDeselectedAll: (SYNChannelCategoryTableViewController *) tableController
{
    
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
    
    self.channel.channelCover.imageUrl = imageUrlString;
    
    NSString* largeImageUrlString = [imageUrlString stringByReplacingOccurrencesOfString:@"thumbnail_medium" withString:@"background"];
    [self.channelCoverImageView setImageWithURL: [NSURL URLWithString: largeImageUrlString]
                               placeholderImage: [UIImage imageNamed: @"PlaceholderChannelCreation.png"]
                                        options: SDWebImageRetryFailed];
    [self closeImageSelector: imageSelector];
}


#pragma mark - ScrollView Delegate

- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    CGFloat fadeSpan = (_isIPhone) ? kChannelDetailsFadeSpaniPhone : kChannelDetailsFadeSpan;
    
    if (scrollView == self.videoThumbnailCollectionView)
    {
        
        if (scrollView.contentOffset.y <= self.originalContentOffset.y)
        {
            self.masterControlsView.alpha = 1.0f;
            CGRect frame = self.masterControlsView.frame;
            frame.origin.y = self.originalMasterControlsViewOrigin.y;
            self.masterControlsView.frame = frame;
        }
        else
        {
            CGFloat differenceInY = - (self.originalContentOffset.y - scrollView.contentOffset.y);
            
            CGRect frame = self.masterControlsView.frame;
            
            frame.origin.y = self.originalMasterControlsViewOrigin.y - (differenceInY / 1.5);
            
            self.masterControlsView.frame = frame;
            
            if (differenceInY < fadeSpan)
            {
                self.masterControlsView.alpha = 1 - (differenceInY / fadeSpan);
            }
            else
            {
                self.masterControlsView.alpha = 0.0f;
            }
        }
    }
}


#pragma mark - Image render

- (UIImage*) croppedImageForOrientation: (UIInterfaceOrientation) orientation
{
    CGRect croppingRect = UIInterfaceOrientationIsLandscape(orientation) ?
    CGRectMake(0.0, 138.0, 1024.0, 886.0) : CGRectMake(69.0, 0.0, 886.0, 1024.0);
    
    if (self.originalBackgroundImage == nil) // set the bg var once
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
                                        
                                        UIImage* croppedImage = [wself croppedImageForOrientation:[SYNDeviceManager.sharedInstance orientation]];
                                        
                                        [UIView transitionWithView: wself.view
                                                          duration: 0.35f
                                                           options: UIViewAnimationOptionTransitionCrossDissolve
                                                        animations: ^{
                                                            wself.channelCoverImageView.image = croppedImage;
                                                        } completion: nil];
                                        
                                        [wself.channelCoverImageView setNeedsLayout];
                                    }];
}


#pragma mark - Tab View Methods

- (void) setChannel: (Channel *) channel
{
    
    self.originalChannel = channel;
    
    NSError *error = nil;
    
    if (!appDelegate)
        appDelegate = UIApplication.sharedApplication.delegate;
    
    if (self.channel)
    {
        
        [[NSNotificationCenter defaultCenter] removeObserver: self
                                                        name: NSManagedObjectContextObjectsDidChangeNotification
                                                      object: self.channel.managedObjectContext];   
    }
    
    _channel = channel;

    if (!self.channel)
        return;

    // create a copy that belongs to this viewId (@"ChannelDetails")
    NSFetchRequest *channelFetchRequest = [[NSFetchRequest alloc] init];
    
    [channelFetchRequest setEntity: [NSEntityDescription entityForName: @"Channel"
                                                inManagedObjectContext: channel.managedObjectContext]];

    [channelFetchRequest setPredicate: [NSPredicate predicateWithFormat: @"uniqueId == %@ AND viewId == %@", channel.uniqueId, self.viewId]];
    
    
    NSArray *matchingChannelEntries = [channel.managedObjectContext executeFetchRequest: channelFetchRequest
                                                                                  error: &error];

    if (matchingChannelEntries.count > 0)
    {
        _channel = (Channel*)matchingChannelEntries[0];
        _channel.markedForDeletionValue = NO;
        
        if(matchingChannelEntries.count > 1) // housekeeping, there can be only one!
            for (int i = 1; i < matchingChannelEntries.count; i++)
                [channel.managedObjectContext deleteObject:(matchingChannelEntries[i])];  
    }
    else
    {
        // the User will be copyed over, but as a ChannelOwner, so "current" will not be set to YES
        _channel = [Channel instanceFromChannel:channel
                                      andViewId:self.viewId
                      usingManagedObjectContext:channel.managedObjectContext
                            ignoringObjectTypes:kIgnoreNothing];

        if(_channel)
        {
            [_channel.managedObjectContext save:&error];
            if(error)
                _channel = nil; // further error code
        }
    }

    if (self.channel)
    {
        // check for subscribed
        self.channel.subscribedByUserValue = NO;
        for (Channel* subscription in appDelegate.currentUser.subscriptions)
            if([subscription.uniqueId isEqualToString:self.channel.uniqueId])
                self.channel.subscribedByUserValue = YES;
        
        if([self.channel.channelOwner.uniqueId isEqualToString:appDelegate.currentUser.uniqueId])
            [self updateChannelOwnerWithUser];
        
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleDataModelChange:)
                                                     name: NSManagedObjectContextDidSaveNotification
                                                   object: self.channel.managedObjectContext];

        if(self.mode == kChannelDetailsModeDisplay)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName: kChannelUpdateRequest
                                                                object: self
                                                              userInfo: @{kChannel: self.channel}];
        }
    }
}

- (void) updateChannelOwnerWithUser
{
    BOOL dateDirty = NO;
    if(![self.channel.channelOwner.displayName isEqualToString: appDelegate.currentUser.displayName])
    {
        self.channel.channelOwner.displayName = appDelegate.currentUser.displayName;
        dateDirty = YES;
        
    }
    if(![self.channel.channelOwner.thumbnailURL isEqualToString: appDelegate.currentUser.thumbnailURL])
    {
        self.channel.channelOwner.thumbnailURL = appDelegate.currentUser.thumbnailURL;
        dateDirty = YES;
        
    }
    
    if(dateDirty) // save
    {
        NSError* error;
        [self.channel.channelOwner.managedObjectContext save:&error];
        if(!error)
        {
            [self displayChannelDetails];
        }
        else
        {
            DebugLog(@"%@", [error description]);
        }
    }
        
    
}


- (BOOL) needsAddButton
{
    return NO;
}


#pragma mark - user avatar image update

- (void) reloadUserImage: (NSNotification*) note
{
    //If this channel is owned by the logged in user we are subscribing to this notification when the user data changes. we therefore re-load the avatar image
    
    UIImage* placeholder = self.avatarImageView.image ? self.avatarImageView.image : [UIImage imageNamed: @"PlaceholderChannelCreation.png"];
    
    NSArray *thumbnailURLItems = [appDelegate.currentUser.thumbnailURL componentsSeparatedByString:@"/"];
    
    if (thumbnailURLItems.count >= 6) // there is a url string with the proper format
    {
        
        // whatever is set to be the default size by the server (ex. 'thumbnail_small') //
        NSString* thumbnailSizeString = thumbnailURLItems[5];
    
        NSString* imageUrlString = [appDelegate.currentUser.thumbnailURL stringByReplacingOccurrencesOfString:thumbnailSizeString withString:@"thumbnail_large"];
    
        [self.avatarImageView setImageWithURL: [NSURL URLWithString:imageUrlString] placeholderImage: placeholder options: SDWebImageRetryFailed];
    }
}


- (void) dealloc
{
    self.channel = nil;
    self.originalChannel = nil;
}

#pragma mark - FAVOURITES WORKAROUND. TO BE REMOVED
-(BOOL) isFavouritesChannel
{
    return ([self.channel.channelOwner.uniqueId isEqualToString:appDelegate.currentUser.uniqueId] && self.channel.favouritesValue);
}

-(void)refreshFavouritesChannel
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kChannelUpdateRequest
                                                       object: self
                                                     userInfo: @{kChannel: self.channel}];
}

@end
