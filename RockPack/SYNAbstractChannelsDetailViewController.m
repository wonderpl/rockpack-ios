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
#import "SYNNetworkEngine.h"
#import "SYNAppDelegate.h"  
#import "SYNAbstractChannelsDetailViewController.h"
#import "SYNChannelCollectionBackgroundView.h"
#import "SYNChannelHeaderView.h"
#import "SYNChannelSelectorCell.h"
#import "SYNMyRockpackMovieViewController.h"
#import "SYNTextField.h"
#import "SYNVideoThumbnailRegularCell.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+MKNetworkKitAdditions.h"
#import "Video.h"
#import "VideoInstance.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNAbstractChannelsDetailViewController () <HPGrowingTextViewDelegate,
                                               UICollectionViewDataSource,
                                               UICollectionViewDelegate,
                                               UITextFieldDelegate>

@property (nonatomic, assign) BOOL keyboardShown;
@property (nonatomic, strong) Channel *channel;
@property (nonatomic, strong) IBOutlet SYNTextField *channelTitleTextField;
@property (nonatomic, strong) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UICollectionView *videoThumbnailCollectionView;
@property (nonatomic, strong) IBOutlet UIImageView *userAvatarImageView;
@property (nonatomic, strong) IBOutlet UILabel *userNameLabel;
@property (nonatomic, strong) IBOutlet UIView *channelChooserView;
@property (nonatomic, strong) IBOutlet UIView *textPanelView;
@property (nonatomic, strong) NSMutableArray *videoInstancesArray;
@property (nonatomic, strong) SYNChannelHeaderView *supplementaryView;
@property (nonatomic, strong) MKNetworkOperation *imageLoadingOperation;

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
    
    // Register collection view header view
    UINib *headerViewNib = [UINib nibWithNibName: @"SYNChannelHeaderView"
                                          bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: headerViewNib
                        forSupplementaryViewOfKind: UICollectionElementKindSectionHeader
                               withReuseIdentifier: @"SYNChannelHeaderView"];
    
    // Now add the long-press gesture recognizers to the custom flow layout
    [layout setUpGestureRecognizersOnCollectionView];
    
    
    // Carousel collection view
    // Register our coverview style cell
    [self.channelCoverCarouselCollectionView registerClass: [SYNChannelSelectorCell class]
                                forCellWithReuseIdentifier: @"SYNChannelSelectorCell"];
    
    // Set carousel collection view to use custom layout algorithm
    CCoverflowCollectionViewLayout *channelCoverCarouselHorizontalLayout = [[CCoverflowCollectionViewLayout alloc] init];
    channelCoverCarouselHorizontalLayout.cellSize = CGSizeMake(345.0f , 195.0f);
    channelCoverCarouselHorizontalLayout.cellSpacing = 40.0f;
    
    self.channelCoverCarouselCollectionView.collectionViewLayout = channelCoverCarouselHorizontalLayout;

    self.channelTitleTextField.textAlignment = NSTextAlignmentLeft;
    self.channelTitleTextField.textColor = [UIColor whiteColor];
    self.channelTitleTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.channelTitleTextField.returnKeyType = UIReturnKeyDone;
    self.channelTitleTextField.font = [UIFont boldRockpackFontOfSize: 29.0f];
    self.channelTitleTextField.delegate = self;
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



#pragma mark - Growable UITextView delegates

- (void) growingTextViewDidBeginEditing: (HPGrowingTextView *) growingTextView
{
    self.supplementaryView.channelDescriptionHightlightView.hidden = FALSE;
    growingTextView.text = @"";
}


- (void) growingTextViewDidEndEditing: (HPGrowingTextView *) growingTextView
{
    self.supplementaryView.channelDescriptionHightlightView.hidden = TRUE;
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
    
	CGRect containerViewFrame = self.supplementaryView.channelDescriptionTextContainerView.frame;
    containerViewFrame.size.height -= diff;
//    containerViewFrame.origin.y += diff;
	self.supplementaryView.channelDescriptionTextContainerView.frame = containerViewFrame;
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
	CGRect containerFrame = self.supplementaryView.channelDescriptionTextContainerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    
	// animations settings
	[UIView beginAnimations: nil
                    context: NULL];
    
	[UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: [duration doubleValue]];
    [UIView setAnimationCurve: [curve intValue]];
	
	// set views with new info
	self.supplementaryView.channelDescriptionTextContainerView.frame = containerFrame;
	
	// commit animations
	[UIView commitAnimations];
}

- (void) keyboardWillHide: (NSNotification *) notification
{
    NSNumber *duration = [notification.userInfo objectForKey: UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey: UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
	CGRect containerFrame = self.supplementaryView.channelDescriptionTextContainerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
	
	// animations settings
	[UIView beginAnimations: nil
                    context: NULL];
    
	[UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: [duration doubleValue]];
    [UIView setAnimationCurve: [curve intValue]];
    
	// set views with new info
	self.supplementaryView.channelDescriptionTextContainerView.frame = containerFrame;
	
	// commit animations
	[UIView commitAnimations];
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
        
        //http://demo.dev.rockpack.com.s3.amazonaws.com/images/75/ChannelCreationCoverThumb1.jpg
        
        NSString *imageURLString = [NSString stringWithFormat: @"http://demo.dev.rockpack.com.s3.amazonaws.com/images/75/ChannelCreationCoverThumb%d.jpg", (indexPath.row % 13) + 1];
        
//        channelCarouselCell.channelImageViewImage = imageURLString;
        SYNAppDelegate *appDelegate = UIApplication.sharedApplication.delegate;
        
        self.imageLoadingOperation = [appDelegate.networkEngine imageAtURL: [NSURL URLWithString: imageURLString]
                                                                      size: CGSizeMake (341, 190)
                                                         completionHandler: ^(UIImage *fetchedImage, NSURL *url, BOOL isInCache)
                                 {
                                     if([imageURLString isEqualToString: [url absoluteString]])
                                     {
                                         if (isInCache)
                                         {
                                             channelCarouselCell.imageView.image = fetchedImage;
                                         }
                                         else
                                         {
                                             [UIView transitionWithView: channelCarouselCell.imageView
                                                               duration: 0.4f
                                                                options: UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                                                             animations: ^
                                              {
                                                  // Crafty aliasing fix
                                                  UIImage *image = fetchedImage;

                                                  CGRect imageRect = CGRectMake( 0 , 0 , fetchedImage.size.width + 4 , fetchedImage.size.height + 4 );
                                                  UIGraphicsBeginImageContext(imageRect.size);
                                                  [fetchedImage drawInRect: CGRectMake(imageRect.origin.x + 2, imageRect.origin.y + 2, imageRect.size.width - 4, imageRect.size.height - 4)];
                                                  CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationHigh);
                                                  image = UIGraphicsGetImageFromCurrentImageContext();
                                                  UIGraphicsEndImageContext();
                                                  
                                                  channelCarouselCell.imageView.image = fetchedImage;
                                                  
                                                  channelCarouselCell.imageView.layer.shouldRasterize = YES;
                                                  channelCarouselCell.imageView.layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;
                                                  channelCarouselCell.imageView.clipsToBounds = NO;
                                                  channelCarouselCell.imageView.layer.masksToBounds = NO;
                                                  
                                                  // End of clever jaggie reduction
                                              }
                                                             completion: nil];
                                         }
                                     }
                                 }
                                                         errorHandler:^(MKNetworkOperation *completedOperation, NSError *error)
                                 {
                                     channelCarouselCell.imageView.image = nil;;
                                 }];

        
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
        // Display the video viewer
        VideoInstance *videoInstance = self.videoInstancesArray[indexPath.row];
        [self displayVideoViewer: videoInstance];
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


- (CGSize) collectionView: (UICollectionView *) collectionView
           layout: (UICollectionViewLayout*) collectionViewLayout
           referenceSizeForHeaderInSection: (NSInteger) section
{
    if (collectionView == self.videoThumbnailCollectionView)
    {
        return CGSizeMake(1024, 390);
    }
    else
    {
        return CGSizeMake(0, 0);
    }
}


// Used for the collection view header
- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
    UICollectionReusableView *sectionSupplementaryView = nil;
    
    if (collectionView == self.videoThumbnailCollectionView)
    {
        SYNChannelHeaderView *headerSupplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind: kind
                                                                                               withReuseIdentifier: @"SYNChannelHeaderView"
                                                                                                      forIndexPath: indexPath];
        // Special case, remember the first section view
        headerSupplementaryView.viewControllerDelegate = self;
        headerSupplementaryView.channelDescriptionTextView.text = self.channel.channelDescription;
        sectionSupplementaryView = headerSupplementaryView;
    }
    
    return sectionSupplementaryView;
}

//
- (void) scrollViewDidEndDecelerating: (UICollectionView *) cv
{
    CGFloat pointX = 450 + self.channelCoverCarouselCollectionView.contentOffset.x;
    CGFloat pointY = 70 + self.channelCoverCarouselCollectionView.contentOffset.y;
    
    NSIndexPath *indexPath = [self.channelCoverCarouselCollectionView indexPathForItemAtPoint: CGPointMake (pointX, pointY)]; 
    
    NSString *imageURLString = [NSString stringWithFormat: @"http://demo.dev.rockpack.com.s3.amazonaws.com/images/75/ChannelCreationCoverBackground%d.jpg", (indexPath.row % 13) + 1];
    
    [self.channelWallpaperImageView setImageFromURL: [NSURL URLWithString: imageURLString]
                                   placeHolderImage: nil];
}

@end