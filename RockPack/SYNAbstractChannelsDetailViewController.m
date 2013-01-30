//
//  SYNADetailViewController.m
//  rockpack
//
//  Created by Nick Banks on 04/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "Channel.h"
#import "HPGrowingTextView.h"
#import "LXReorderableCollectionViewFlowLayout.h"
#import "SYNAbstractChannelsDetailViewController.h"
#import "SYNChannelCollectionBackgroundView.h"
#import "SYNChannelHeaderView.h"
#import "SYNAbstractChannelsDetailViewController.h"
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
@property (nonatomic, strong) IBOutlet UICollectionView *videoThumbnailCollectionView;
@property (nonatomic, strong) IBOutlet UIImageView *channelWallpaperImageView;
@property (nonatomic, strong) IBOutlet HPGrowingTextView *channelDescriptionTextView;
@property (nonatomic, strong) UIImageView *channelDescriptionHightlightView;
@property (nonatomic, strong) IBOutlet UIView *channelDescriptionTextContainerView;
@property (nonatomic, strong) IBOutlet UIView *textPanelView;
@property (nonatomic, strong) IBOutlet UILabel *userNameLabel;
@property (nonatomic, strong) IBOutlet SYNTextField *channelTitleTextField;
@property (nonatomic, strong) IBOutlet UILabel *videosLabel;
@property (nonatomic, strong) IBOutlet UILabel *followersLabel;
@property (nonatomic, strong) IBOutlet UILabel *videoCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *followersCountLabel;
@property (nonatomic, strong) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *videoInstancesArray;

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
    layout.itemSize = CGSizeMake(258.0f , 179.0f);
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
    self.channelDescriptionTextView.text = @"test";
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
}


#pragma mark - Growable UITextView delegates

- (void) growingTextViewDidBeginEditing: (HPGrowingTextView *) growingTextView
{
    self.channelDescriptionHightlightView.hidden = FALSE;
}


- (void) growingTextViewDidEndEditing: (HPGrowingTextView *) growingTextView
{
    self.channelDescriptionHightlightView.hidden = TRUE;
    [self.channelDescriptionTextView scrollRangeToVisible: NSMakeRange (0,0)];
    [self.channelDescriptionTextView resignFirstResponder];
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
    [self.channelWallpaperImageView setImageFromURL: [NSURL URLWithString: self.channel.wallpaperURL]
                                   placeHolderImage: nil];
    
    // Refresh our view
    [self.videoThumbnailCollectionView reloadData];
}


#pragma mark - Collection view support

- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    NSLog (@"Number of items %d", self.videoInstancesArray.count);
    return self.videoInstancesArray.count;
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) cv
{
    return 1;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNVideoThumbnailRegularCell *cell = [cv dequeueReusableCellWithReuseIdentifier: @"SYNVideoThumbnailRegularCell"
                                                                       forIndexPath: indexPath];
    
    VideoInstance *videoInstance = self.videoInstancesArray[indexPath.item];
    cell.videoImageViewImage = videoInstance.video.thumbnailURL;
    cell.titleLabel.text = videoInstance.title;
    
    return cell;
}


- (void) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    VideoInstance *videoInstance = self.videoInstancesArray[indexPath.row];
    
    SYNMyRockpackMovieViewController *movieVC = [[SYNMyRockpackMovieViewController alloc] initWithVideo: videoInstance.video];
    
    [self animatedPushViewController: movieVC];
    
}


- (void) collectionView: (UICollectionView *) cv
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