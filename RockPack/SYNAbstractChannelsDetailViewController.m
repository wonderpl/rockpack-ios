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
#import "SYNTextField.h"
#import "SYNVideoThumbnailRegularCell.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+MKNetworkKitAdditions.h"
#import "Video.h"
#import "VideoInstance.h"
#import <QuartzCore/QuartzCore.h>
#import "SYNSoundPlayer.h"

@interface SYNAbstractChannelsDetailViewController () <HPGrowingTextViewDelegate,
                                               UICollectionViewDataSource,
                                               UICollectionViewDelegate,
                                               UITextFieldDelegate>

@property (nonatomic, assign) BOOL keyboardShown;
@property (nonatomic, strong) Channel *channel;
@property (nonatomic, strong) IBOutlet UICollectionView *videoThumbnailCollectionView;
@property (nonatomic, strong) IBOutlet UIView *channelChooserView;
@property (nonatomic, strong) IBOutlet UIView *textPanelView;
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
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillShow:)
                                                 name: UIKeyboardWillShowNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillHide:)
                                                 name: UIKeyboardWillHideNotification
                                               object: nil];
    
    // Set all the labels to use the custom font
    self.channelTitleTextField.font = [UIFont boldRockpackFontOfSize: 29.0f];
    self.userNameLabel.font = [UIFont rockpackFontOfSize: 17.0f];
    self.saveOrDoneButtonLabel.font = [UIFont boldRockpackFontOfSize: 14.0f];
    self.changeCoverLabel.font = [UIFont boldRockpackFontOfSize: 24.0f];
    
    UIColor *color = [UIColor blackColor];
    self.changeCoverLabel.layer.shadowColor = [color CGColor];
    self.changeCoverLabel.layer.shadowRadius = 7.0f;
    self.changeCoverLabel.layer.shadowOpacity = 1.0;
    self.changeCoverLabel.layer.shadowOffset = CGSizeZero;
    self.changeCoverLabel.layer.masksToBounds = NO;
    
    self.selectACoverLabel.font = [UIFont boldRockpackFontOfSize: 24.0f];
    
    self.selectACoverLabel.layer.shadowColor = [color CGColor];
    self.selectACoverLabel.layer.shadowRadius = 7.0f;
    self.selectACoverLabel.layer.shadowOpacity = 1.0;
    self.selectACoverLabel.layer.shadowOffset = CGSizeZero;
    self.selectACoverLabel.layer.masksToBounds = NO;
    
    //Kish & Gregory woz ere: Aligning the SELECT A COVER text to centre and spacing the Y-Axis correctly!
    self.selectACoverLabel.textAlignment = NSTextAlignmentCenter;
    self.selectACoverLabel.layer.position = CGPointMake( 512.0 , 88.0 );

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
    
    // Init collection view
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNChannelSelectorCell"
                                             bundle: nil];
    
    [self.channelCoverCarouselCollectionView registerNib: thumbnailCellNib
                          forCellWithReuseIdentifier: @"SYNChannelSelectorCell"];
    
    // Set carousel collection view to use custom layout algorithm
    CCoverflowCollectionViewLayout *channelCoverCarouselHorizontalLayout = [[CCoverflowCollectionViewLayout alloc] init];
    channelCoverCarouselHorizontalLayout.cellSize = CGSizeMake(345.0f , 195.0f);
    channelCoverCarouselHorizontalLayout.cellSpacing = 40.0f;
    
    self.channelCoverCarouselCollectionView.collectionViewLayout = channelCoverCarouselHorizontalLayout;
    
    //Kish & Gregory woz ere: Aligning the carousel to centre and spacing the Y-Axis correctly in relation to the label
    self.channelCoverCarouselCollectionView.frame = CGRectMake(80.0, 77.0, 864.0, 300.0);

    self.channelTitleTextField.textAlignment = NSTextAlignmentLeft;
    self.channelTitleTextField.textColor = [UIColor whiteColor];
    self.channelTitleTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.channelTitleTextField.returnKeyType = UIReturnKeyDone;
    self.channelTitleTextField.font = [UIFont boldRockpackFontOfSize: 29.0f];
    self.channelTitleTextField.delegate = self;
    
    // Set all labels and images to correspond to the selected channel
    self.channelTitleTextField.text = self.channel.title;
    self.userNameLabel.text = self.channel.channelOwner.name;
    
    // set User's avatar picture
    [self.userAvatarImageView setImageFromURL: [NSURL URLWithString: self.channel.channelOwner.thumbnailURL]
                             placeHolderImage: nil];
    
    // Set wallpaper
    [self.channelWallpaperImageView setImageFromURL: [NSURL URLWithString: self.channel.wallpaperURL]
                                   placeHolderImage: nil];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];

    // Refresh our view
    [self.videoThumbnailCollectionView reloadData];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}



#pragma mark - Growable UITextView delegates

- (void) growingTextViewDidBeginEditing: (HPGrowingTextView *) growingTextView
{
    self.collectionHeaderView.channelDescriptionHightlightView.hidden = FALSE;
//    growingTextView.text = @"";
}


- (void) growingTextViewDidEndEditing: (HPGrowingTextView *) growingTextView
{
    self.collectionHeaderView.channelDescriptionHightlightView.hidden = TRUE;
    [self.collectionHeaderView.channelDescriptionTextView scrollRangeToVisible: NSMakeRange (0,0)];
    [self.collectionHeaderView.channelDescriptionTextView resignFirstResponder];
    
    if ([growingTextView.text isEqualToString: @""])
    {
//        growingTextView.text = @"Describe your channel...";
    }
}


- (void) growingTextView: (HPGrowingTextView *) growingTextView
        willChangeHeight: (float) height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect containerViewFrame = self.collectionHeaderView.channelDescriptionTextContainerView.frame;
    containerViewFrame.size.height -= diff;
//    containerViewFrame.origin.y += diff;
	self.collectionHeaderView.channelDescriptionTextContainerView.frame = containerViewFrame;
}


//Code from Brett Schumann
- (void) keyboardWillShow: (NSNotification *) notification
{
    if (self.channelTitleTextField.isFirstResponder == FALSE)
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
        CGRect containerFrame = self.slideView.frame;
        containerFrame.origin.y -= 120;
        
        // animations settings
        [UIView beginAnimations: nil
                        context: NULL];
        
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: [duration doubleValue]];
        [UIView setAnimationCurve: [curve intValue]];
        
        // set views with new info
        self.slideView.frame = containerFrame;
        
        // commit animations
        [UIView commitAnimations];
    }
}

- (void) keyboardWillHide: (NSNotification *) notification
{
    if (self.channelTitleTextField.isFirstResponder == FALSE)
    {
        NSNumber *duration = [notification.userInfo objectForKey: UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curve = [notification.userInfo objectForKey: UIKeyboardAnimationCurveUserInfoKey];
        
        // get a rect for the textView frame
        CGRect containerFrame = self.slideView.frame;
        containerFrame.origin.y += 120;
        
        // animations settings
        [UIView beginAnimations: nil
                        context: NULL];
        
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: [duration doubleValue]];
        [UIView setAnimationCurve: [curve intValue]];
        
        // set views with new info
        self.slideView.frame = containerFrame;
        
        // commit animations
        [UIView commitAnimations];
    }
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

        [[SYNSoundPlayer sharedInstance] playSoundByName:kSoundScroll];
        
        SYNChannelSelectorCell *channelCarouselCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelSelectorCell"
                                                                                    forIndexPath: indexPath];
        
        //http://demo.dev.rockpack.com.s3.amazonaws.com/images/75/ChannelCreationCoverThumb1.jpg
        
        NSString *imageURLString = [NSString stringWithFormat: @"http://demo.dev.rockpack.com.s3.amazonaws.com/images/75/ChannelCreationCoverThumb%d@2x.jpg", (indexPath.row % 13) + 1];
        
        
        self.imageLoadingOperation = [appDelegate.networkEngine imageAtURL: [NSURL URLWithString: imageURLString]
                                                                      size: CGSizeMake (341, 190)
                                                         completionHandler: ^(UIImage *fetchedImage, NSURL *url, BOOL isInCache)
                                 {
                                     if([imageURLString isEqualToString: [url absoluteString]])
                                     {
                                         if (isInCache)
                                         {
                                             [self addTransparentBorderFromSourceImage: fetchedImage
                                                                              intoView: channelCarouselCell.imageView];
                                         }
                                         else
                                         {
                                             [UIView transitionWithView: channelCarouselCell.imageView
                                                               duration: 0.4f
                                                                options: UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                                                             animations: ^
                                              {
                                                  [self addTransparentBorderFromSourceImage: fetchedImage
                                                                                   intoView: channelCarouselCell.imageView];
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

- (void) addTransparentBorderFromSourceImage: (UIImage *) sourceImage
                                    intoView: (UIImageView *) destinationView
{
    CGRect imageRect = CGRectMake( 0 , 0 , sourceImage.size.width + 4 , sourceImage.size.height + 4 );
    UIGraphicsBeginImageContext(imageRect.size);
    [sourceImage drawInRect: CGRectMake(imageRect.origin.x + 2, imageRect.origin.y + 2, imageRect.size.width - 4, imageRect.size.height - 4)];
    CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationHigh);
    sourceImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    destinationView.image = sourceImage;
    
    destinationView.layer.shouldRasterize = YES;
    destinationView.layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;
    destinationView.clipsToBounds = NO;
    destinationView.layer.masksToBounds = NO;
    
    // End of clever jaggie reduction
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
    SYNChannelHeaderView *sectionSupplementaryView = nil;
    
    if (collectionView == self.videoThumbnailCollectionView)
    {
        sectionSupplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind: kind
                                                                      withReuseIdentifier: @"SYNChannelHeaderView"
                                                                             forIndexPath: indexPath];
        // Special case, remember the first section view
        sectionSupplementaryView.viewControllerDelegate = self;
        sectionSupplementaryView.channelDescriptionTextView.text = self.channel.channelDescription;
        self.collectionHeaderView = sectionSupplementaryView;
        
        UIImage *rawEntryBackground = [UIImage imageNamed: @"MessageEntryInputField.png"];
        
        UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth: 13
                                                                           topCapHeight: 22];
        
        self.channelDescriptionHightlightView = [[UIImageView alloc] initWithImage: entryBackground];
        self.channelDescriptionHightlightView.frame = CGRectInset(self.collectionHeaderView.channelDescriptionTextView.frame, -10, -10);
        self.channelDescriptionHightlightView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.channelDescriptionHightlightView.hidden = self.hideChannelDescriptionHighlight;
        self.collectionHeaderView.channelDescriptionTextView.editable = !self.hideChannelDescriptionHighlight;
        [self.collectionHeaderView.channelDescriptionTextContainerView addSubview: self.channelDescriptionHightlightView];
    }
    
    return sectionSupplementaryView;
}

- (BOOL) hideChannelDescriptionHighlight
{
    return TRUE;
}

//
- (void) scrollViewDidEndDecelerating: (UICollectionView *) collectionView
{
    if (collectionView == self.channelCoverCarouselCollectionView)
    {
        CGFloat pointX = 450 + self.channelCoverCarouselCollectionView.contentOffset.x;
        CGFloat pointY = 70 + self.channelCoverCarouselCollectionView.contentOffset.y;
        
        NSIndexPath *indexPath = [self.channelCoverCarouselCollectionView indexPathForItemAtPoint: CGPointMake (pointX, pointY)]; 
        
        NSString *imageURLString = [NSString stringWithFormat: @"http://demo.dev.rockpack.com.s3.amazonaws.com/images/75/ChannelCreationCoverBackground%d.jpg", (indexPath.row % 13) + 1];
        
        [self.channelWallpaperImageView setImageFromURL: [NSURL URLWithString: imageURLString]
                                       placeHolderImage: nil];
    }
}

- (IBAction) userTouchedSaveButton: (id) sender
{
    NSLog (@"User touched save button");
}

- (IBAction) userTouchedDoneButton: (id) sender
{
    NSLog (@"User touched done button");
}

- (IBAction) userTouchedChangeCoverButton: (id) sender;
{
    NSLog (@"User touched change cover button");
}

- (IBAction) userTouchedEditButton: (id) sender
{
    NSLog (@"User touched edit button");
}

- (IBAction) userTouchedShareButton: (id) sender
{
    NSLog (@"User touched share button");
}

@end