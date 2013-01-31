//
//  SYNADetailViewController.m
//  rockpack
//
//  Created by Nick Banks on 04/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "CCoverflowCollectionViewLayout.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "HPGrowingTextView.h"
#import "LXReorderableCollectionViewFlowLayout.h"
#import "SYNAbstractChannelsDetailViewController.h"
#import "SYNChannelCollectionBackgroundView.h"
#import "SYNChannelHeaderView.h"
#import "SYNChannelSelectorCell.h"
#import "SYNMyRockpackMovieViewController.h"
#import "SYNTextField.h"
#import "SYNVideoThumbnailRegularCell.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "UIFont+SYNFont.h"
#import "Video.h"
#import "VideoInstance.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNAbstractChannelsDetailViewController () <HPGrowingTextViewDelegate,
                                               UICollectionViewDataSource,
                                               UICollectionViewDelegate>

@property (nonatomic, assign) BOOL keyboardShown;
@property (nonatomic, strong) Channel *channel;
@property (nonatomic, strong) IBOutlet SYNTextField *channelTitleTextField;
@property (nonatomic, strong) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UICollectionView *videoThumbnailCollectionView;
@property (nonatomic, strong) IBOutlet UIImageView *channelWallpaperImageView;
@property (nonatomic, strong) IBOutlet UIImageView *userAvatarImageView;
@property (nonatomic, strong) IBOutlet UILabel *followersCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *followersLabel;
@property (nonatomic, strong) IBOutlet UILabel *userNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *videoCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *videosLabel;
@property (nonatomic, strong) IBOutlet UIView *channelChooserView;
@property (nonatomic, strong) IBOutlet UIView *channelDescriptionTextContainerView;
@property (nonatomic, strong) IBOutlet UIView *textPanelView;
@property (nonatomic, strong) NSMutableArray *videoInstancesArray;
@property (nonatomic, strong) UIImageView *channelDescriptionHightlightView;

@end


@implementation SYNAbstractChannelsDetailViewController

- (id) initWithChannel: (Channel *) channel
{
	
	if ((self = [super initWithNibName: @"SYNAbstractChannelsDetailViewController" bundle: nil]))
    {
		self.channel = channel;
        self.videoInstancesArray = [NSMutableArray arrayWithArray: self.channel.videoInstancesSet.array];
	}
    
	return self;
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Set all the labels to use the custom font
    self.channelTitleTextField.font = [UIFont boldRockpackFontOfSize: 29.0f];
    self.userNameLabel.font = [UIFont rockpackFontOfSize: 17.0f];
    self.videosLabel.font = [UIFont rockpackFontOfSize: 12.0f];
    self.followersLabel.font = [UIFont rockpackFontOfSize: 12.0f];
    self.videoCountLabel.font = [UIFont boldRockpackFontOfSize: 18.0f];
    self.followersCountLabel.font = [UIFont boldRockpackFontOfSize: 18.0f];
    

    
    // Add a custom flow layout to our thumbail collection view (with the right size and spacing)
    LXReorderableCollectionViewFlowLayout *layout = [[LXReorderableCollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(256.0f , 179.0f);
    layout.minimumInteritemSpacing = 0.0f;
    layout.minimumLineSpacing = 0.0f;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    self.videoThumbnailCollectionView.collectionViewLayout = layout;

    // Regster video thumbnail cell  
    UINib *videoThumbnailCellNib = [UINib nibWithNibName: @"SYNVideoThumbnailRegularCell"
                                                  bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: videoThumbnailCellNib
                        forCellWithReuseIdentifier: @"SYNVideoThumbnailRegularCell"];
    
    // Set up editable description text view (this is somewhat specialy, as it has a resizeable glow around it
    self.channelDescriptionTextView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.channelDescriptionTextView.text = self.channel.description;
    self.channelDescriptionTextView.font = [UIFont rockpackFontOfSize: 15.0f];
	self.channelDescriptionTextView.minNumberOfLines = 1;
	self.channelDescriptionTextView.maxNumberOfLines = 4;
    self.channelDescriptionTextView.backgroundColor = [UIColor clearColor];
    self.channelDescriptionTextView.textColor = [UIColor colorWithRed: 0.725f green: 0.812f blue: 0.824f alpha: 1.0f];
	self.channelDescriptionTextView.delegate = self;
    self.channelDescriptionTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    
    // Add highlighted box
    UIImage *rawEntryBackground = [UIImage imageNamed: @"MessageEntryInputField.png"];
    
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth: 13
                                                                       topCapHeight: 22];
    
    self.channelDescriptionHightlightView = [[UIImageView alloc] initWithImage: entryBackground];
    self.channelDescriptionHightlightView.frame = CGRectInset(self.channelDescriptionTextView.frame, -10, -10);
    self.channelDescriptionHightlightView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.channelDescriptionTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.channelDescriptionHightlightView.hidden = TRUE;
    
    [self.channelDescriptionTextContainerView addSubview: self.channelDescriptionHightlightView];
    
    // Now use the same assets to create a highlight box for the channel title
//    channelTitleLabel

    self.channelDescriptionTextContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    
    // Now add the long-press gesture recognizers to the custom flow layout
    [layout setUpGestureRecognizersOnCollectionView];
    
    
    // Carousel collection view
    
    // Set carousel collection view to use custom layout algorithm
    CCoverflowCollectionViewLayout *channelCoverCarouselHorizontalLayout = [[CCoverflowCollectionViewLayout alloc] init];
    channelCoverCarouselHorizontalLayout.cellSize = CGSizeMake(341.0f , 190.0f);
    channelCoverCarouselHorizontalLayout.cellSpacing = 40.0f;
    
    self.channelCoverCarouselCollectionView = [[UICollectionView alloc] initWithFrame: CGRectMake(62, 167, 900, 190)
                                                                 collectionViewLayout: channelCoverCarouselHorizontalLayout];
    
    self.channelCoverCarouselCollectionView.delegate = self;
    self.channelCoverCarouselCollectionView.dataSource = self;
    self.channelCoverCarouselCollectionView.backgroundColor = [UIColor clearColor];
    self.channelCoverCarouselCollectionView.showsHorizontalScrollIndicator = FALSE;
    
    // Set up our carousel
    [self.channelCoverCarouselCollectionView registerClass: [SYNChannelSelectorCell class]
                                forCellWithReuseIdentifier: @"SYNChannelSelectorCell"];
    
    self.channelCoverCarouselCollectionView.decelerationRate = UIScrollViewDecelerationRateNormal;

    self.channelCoverCarouselCollectionView.hidden = TRUE;
    
    // Initially hide this view
//    self.channelCoverCarouselCollectionView.alpha = 0.0f;
    [self.view addSubview: self.channelCoverCarouselCollectionView];

    
//    self.channelNameTextField = [[UITextField alloc] initWithFrame: CGRectMake(319, 330, 384, 35)];
//    
//    self.channelNameTextField.textAlignment = NSTextAlignmentCenter;
//    self.channelNameTextField.textColor = [UIColor whiteColor];
//    self.channelNameTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
//    self.channelNameTextField.returnKeyType = UIReturnKeyDone;
//    self.channelNameTextField.font = [UIFont rockpackFontOfSize: 36.0f];
//    self.channelNameTextField.delegate = self;
//    [self.channelChooserView addSubview: self.channelNameTextField];

}


#pragma mark - Growable UITextView delegates

- (void) growingTextViewDidBeginEditing: (HPGrowingTextView *) growingTextView
{
    self.channelDescriptionHightlightView.hidden = FALSE;
    growingTextView.text = @"";
}


- (void) growingTextViewDidEndEditing: (HPGrowingTextView *) growingTextView
{
    self.channelDescriptionHightlightView.hidden = TRUE;
    [self.channelDescriptionTextView scrollRangeToVisible: NSMakeRange (0,0)];
    [self.channelDescriptionTextView resignFirstResponder];
    
    if ([growingTextView.text isEqualToString: @""])
    {
//        growingTextView.text = @"Describe your channel...";
    }
}


- (void) growingTextView: (HPGrowingTextView *) growingTextView
        willChangeHeight: (float) height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect containerViewFrame = self.channelDescriptionTextContainerView.frame;
    containerViewFrame.size.height -= diff;
//    containerViewFrame.origin.y += diff;
	self.channelDescriptionTextContainerView.frame = containerViewFrame;
}

//Code from Brett Schumann
- (void) keyboardWillShow: (NSNotification *) notification
{
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[notification.userInfo valueForKey: UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey: UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey: UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect: keyboardBounds
                                     toView: nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = self.channelDescriptionTextContainerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    
	// animations settings
	[UIView beginAnimations: nil
                    context: NULL];
    
	[UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: [duration doubleValue]];
    [UIView setAnimationCurve: [curve intValue]];
	
	// set views with new info
	self.channelDescriptionTextContainerView.frame = containerFrame;
	
	// commit animations
	[UIView commitAnimations];
}

- (void) keyboardWillHide: (NSNotification *) notification
{
    NSNumber *duration = [notification.userInfo objectForKey: UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey: UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
	CGRect containerFrame = self.channelDescriptionTextContainerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
	
	// animations settings
	[UIView beginAnimations: nil
                    context: NULL];
    
	[UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: [duration doubleValue]];
    [UIView setAnimationCurve: [curve intValue]];
    
	// set views with new info
	self.channelDescriptionTextContainerView.frame = containerFrame;
	
	// commit animations
	[UIView commitAnimations];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    // Set all labels and images to correspond to the selected channel
    self.channelTitleTextField.text = self.channel.title;
    self.userNameLabel.text = self.channel.channelOwner.name;
    
    // set User's avatar picture
    [self.userAvatarImageView setImageFromURL: [NSURL URLWithString: self.channel.channelOwner.thumbnailURL]
                                   placeHolderImage: nil];
    
    // Set wallpaper
    [self.channelWallpaperImageView setImageFromURL: [NSURL URLWithString: self.channel.wallpaperURL]
                                   placeHolderImage: nil];
    
    // Refresh our view
    [self.videoThumbnailCollectionView reloadData];
}


#pragma mark - Collection view support

- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger) section
{
    if (collectionView == self.channelCoverCarouselCollectionView)
    {
        return 13;
    }
    else
    {
        NSLog (@"Number of items %d", self.videoInstancesArray.count);
        return self.videoInstancesArray.count;
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
    
    if (collectionView == self.channelCoverCarouselCollectionView)
    {
#ifdef SOUND_ENABLED
        // Play a suitable sound
        NSString *soundPath = [[NSBundle mainBundle] pathForResource: @"Scroll"
                                                              ofType: @"aif"];
        
        if (self.shouldPlaySound == TRUE)
        {
            NSURL *soundURL = [NSURL fileURLWithPath: soundPath];
            SystemSoundID sound;
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
            AudioServicesPlaySystemSound(sound);
        }
#endif
        
//    http://demo.dev.rockpack.com.s3.amazonaws.com/images/ChannelCreationCoverBackground1.png
//    http://demo.dev.rockpack.com.s3.amazonaws.com/images/ChannelCreationCoverThumb1.png
        
        SYNChannelSelectorCell *channelCarouselCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelSelectorCell"
                                                                                    forIndexPath: indexPath];
        

        
        NSString *imageURLString = [NSString stringWithFormat: @"http://demo.dev.rockpack.com.s3.amazonaws.com/images/ChannelCreationCoverThumb%d.png", (indexPath.row % 13) + 1];
        
        channelCarouselCell.channelImageViewImage = imageURLString;
        
        cell = channelCarouselCell;
    }
    else
    {
        SYNVideoThumbnailRegularCell *videoThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNVideoThumbnailRegularCell"
                                                                           forIndexPath: indexPath];
        
        VideoInstance *videoInstance = self.videoInstancesArray[indexPath.item];
        videoThumbnailCell.videoImageViewImage = videoInstance.video.thumbnailURL;
        videoThumbnailCell.titleLabel.text = videoInstance.title;
        
        cell = videoThumbnailCell;
    }
    
    return cell;
}


- (void) collectionView: (UICollectionView *) collectionView
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (collectionView == self.channelCoverCarouselCollectionView)
    {
        //#warning "Need to select wallpack here"
        DebugLog (@"Selecting channel cover cell does nothing");
    }
    else
    {
        VideoInstance *videoInstance = self.videoInstancesArray[indexPath.row];
        [self displayVideoViewer: videoInstance];
        
//        SYNMyRockpackMovieViewController *movieVC = [[SYNMyRockpackMovieViewController alloc] initWithVideo: videoInstance.video];
//        
//        [self animatedPushViewController: movieVC];
    }
}


- (void) collectionView: (UICollectionView *) collectionView
                 layout: (UICollectionViewLayout *) layout
        itemAtIndexPath: (NSIndexPath *) fromIndexPath
    willMoveToIndexPath: (NSIndexPath *) toIndexPath
{
    // Actually swap the video thumbnails around in the visible list
    id fromItem = self.videoInstancesArray[fromIndexPath.item];
    id fromObject = self.channel.videoInstances[fromIndexPath.item];
    
    [self.videoInstancesArray removeObjectAtIndex: fromIndexPath.item];
    [self.channel.videoInstancesSet removeObjectAtIndex: fromIndexPath.item];
    
    [self.videoInstancesArray insertObject: fromItem atIndex: toIndexPath.item];
    [self.channel.videoInstancesSet insertObject: fromObject atIndex: toIndexPath.item];
    
    [self saveDB];
}

@end