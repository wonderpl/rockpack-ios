//
//  SYNChannelsTopTabViewController.m
//  rockpack
//
//  Created by Nick Banks on 01/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "Channel.h"
#import "Genre.h"
#import "ChannelOwner.h"
#import "SYNAppDelegate.h"
#import "ChannelCover.h"
#import "SYNChannelCategoryTableViewController.h"
#import "SYNChannelDetailViewController.h"
#import "SYNChannelFooterMoreView.h"
#import "SYNChannelThumbnailCell.h"
#import "SYNChannelsRootViewController.h"
#import "SYNDeviceManager.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNMainRegistry.h"
#import "SYNNetworkEngine.h"
#import "SubGenre.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import "Video.h"
#import "VideoInstance.h"

#define STANDARD_LENGTH 50
#define kChannelsCache @"ChannelsCache"

@interface SYNChannelsRootViewController () <UIScrollViewDelegate, SYNChannelCategoryTableViewDelegate>

#ifdef ALLOWS_PINCH_GESTURES

@property (nonatomic, assign) BOOL userPinchedOut;
@property (nonatomic, strong) NSIndexPath *pinchedIndexPath;
@property (nonatomic, strong) UIImageView *pinchedView;

#endif

@property (getter = hasTouchedChannelButton) BOOL touchedChannelButton;
@property (nonatomic) NSInteger currentTotal;
@property (nonatomic) NSRange currentRange;
@property (nonatomic, assign) BOOL ignoreRefresh;
@property (nonatomic, strong) NSString* currentCategoryId;
@property (nonatomic, weak) Genre* currentGenre;
@property (nonatomic, weak) SYNMainRegistry* mainRegistry;

@property (nonatomic, strong) SYNChannelCategoryTableViewController* categoryTableViewController;
@property (nonatomic, strong) UIButton* categorySelectButton;
@property (nonatomic, strong) UIControl* categorySelectDismissControl;
@property (nonatomic, strong) UILabel* categoryNameLabel;
@property (nonatomic, strong) UILabel* subCategoryNameLabel;
@property (nonatomic, strong) UIImageView* arrowImage;
@property (nonatomic, strong) NSMutableArray* channels;

@property (nonatomic, strong) Genre* allGenre;
@end

@implementation SYNChannelsRootViewController

@synthesize currentCategoryId;
@synthesize currentGenre;
@synthesize currentRange;
@synthesize currentTotal;
@synthesize mainRegistry;
@synthesize channels;

#pragma mark - View lifecycle

- (id) initWithViewId: (NSString *) vid
{
    if ((self = [super initWithViewId: vid]))
    {
        self.title = kChannelsTitle;
    }
    
    return self;
}


- (void) loadView
{
    // Google Analytics support
    self.trackedViewName = @"Channels - Root";
    
    BOOL isIPhone = [[SYNDeviceManager sharedInstance] isIPhone];
    
    SYNIntegralCollectionViewFlowLayout* flowLayout;
    if(isIPhone)
    {
        flowLayout = [SYNIntegralCollectionViewFlowLayout layoutWithItemSize:CGSizeMake(152.0f, 167.0f) minimumInterItemSpacing:0.0 minimumLineSpacing:6.0 scrollDirection:UICollectionViewScrollDirectionVertical sectionInset:UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)];
        flowLayout.footerReferenceSize = [self footerSize];
    }
    else
    {
        flowLayout = [SYNIntegralCollectionViewFlowLayout layoutWithItemSize:[self itemSize] minimumInterItemSpacing:0.0 minimumLineSpacing:0.0 scrollDirection:UICollectionViewScrollDirectionVertical sectionInset:UIEdgeInsetsMake(6.0, 6.0, 5.0, 6.0)];
        flowLayout.footerReferenceSize = [self footerSize];
    }
    
    // Work out how hight the inital tab bar is
    CGFloat topTabBarHeight = [UIImage imageNamed: @"CategoryBar"].size.height;
    
    CGRect channelCollectionViewFrame;
    if(isIPhone)
    {
        channelCollectionViewFrame = CGRectMake(0.0f, 103.0f, [[SYNDeviceManager sharedInstance] currentScreenWidth],[[SYNDeviceManager sharedInstance] currentScreenHeight] - 123.0f);
    }
    else
    {
        channelCollectionViewFrame = [[SYNDeviceManager sharedInstance] isLandscape] ?
        CGRectMake(0.0, kStandardCollectionViewOffsetY + topTabBarHeight, kFullScreenWidthLandscape, kFullScreenHeightLandscapeMinusStatusBar - kStandardCollectionViewOffsetY - topTabBarHeight) :
        CGRectMake(0.0f, kStandardCollectionViewOffsetY + topTabBarHeight, kFullScreenWidthPortrait, kFullScreenHeightPortraitMinusStatusBar  - kStandardCollectionViewOffsetY - topTabBarHeight);
    }
    
    self.channelThumbnailCollectionView = [[UICollectionView alloc] initWithFrame: channelCollectionViewFrame
                                                             collectionViewLayout: flowLayout];
    self.channelThumbnailCollectionView.dataSource = self;
    self.channelThumbnailCollectionView.delegate = self;
    self.channelThumbnailCollectionView.backgroundColor = [UIColor clearColor];
    self.channelThumbnailCollectionView.showsVerticalScrollIndicator = NO;
    self.channelThumbnailCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    CGRect newFrame;
    if(isIPhone)
    {
        newFrame = CGRectMake(0.0f, 59.0f, [[SYNDeviceManager sharedInstance] currentScreenWidth],[[SYNDeviceManager sharedInstance] currentScreenHeight] - 20.0f);
    }
    else
    {
        newFrame = [[SYNDeviceManager sharedInstance] isLandscape] ?
        CGRectMake(0.0, 0.0, kFullScreenWidthLandscape, kFullScreenHeightLandscapeMinusStatusBar) :
        CGRectMake(0.0f, 0.0f, kFullScreenWidthPortrait, kFullScreenHeightPortraitMinusStatusBar);
    }

    
    self.view = [[UIView alloc] initWithFrame:newFrame];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.channelThumbnailCollectionView];
    
    startAnimationDelay = 0.0;
    
    
    
    
    currentRange = NSMakeRange(0, 50);
    
    if(self.enableCategoryTable)
    {
        [self layoutChannelsCategoryTable];
    }
    
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.mainRegistry = appDelegate.mainRegistry;
    
    self.channels = [NSMutableArray array];
    
    // Register Cells
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNChannelThumbnailCell"
                                             bundle: nil];
    
    [self.channelThumbnailCollectionView registerNib: thumbnailCellNib
                          forCellWithReuseIdentifier: @"SYNChannelThumbnailCell"];
    
    // Register Footer
    UINib *footerViewNib = [UINib nibWithNibName: @"SYNChannelFooterMoreView"
                                          bundle: nil];
    
    [self.channelThumbnailCollectionView registerNib: footerViewNib
                          forSupplementaryViewOfKind: UICollectionElementKindSectionFooter
                                 withReuseIdentifier: @"SYNChannelFooterMoreView"];

#ifdef ALLOWS_PINCH_GESTURES
    UIPinchGestureRecognizer *pinchOnChannelView = [[UIPinchGestureRecognizer alloc] initWithTarget: self
                                                                                             action: @selector(handlePinchGesture:)];
    
    [self.view addGestureRecognizer: pinchOnChannelView];
#endif
    

    
    currentGenre = nil;
    
    [self loadChannelsForGenre:nil];
    
    
}

#pragma mark - Load Channels

-(void)loadChannelsForGenre:(Genre*)genre
{
    [self loadChannelsForGenre:genre byAppending:NO];
}

-(void)loadChannelsForGenre:(Genre*)genre byAppending:(BOOL)append
{
    
    
    [appDelegate.networkEngine updateChannelsScreenForCategory: (genre ? genre.uniqueId : @"all")
                                                      forRange: currentRange
                                                 ignoringCache: NO
                                                  onCompletion: ^(NSDictionary* response) {
                                                      
                                                      NSDictionary *channelsDictionary = [response objectForKey: @"channels"];
                                                      if (!channelsDictionary || ![channelsDictionary isKindOfClass: [NSDictionary class]])
                                                          return;
                                                      
                                                      NSNumber *totalNumber = [channelsDictionary objectForKey: @"total"];
                                                      if (![totalNumber isKindOfClass: [NSNumber class]])
                                                          return;
                                                      
                                                      currentTotal = [totalNumber integerValue];
                                                      
                                                      BOOL registryResultOk = [appDelegate.mainRegistry registerChannelsFromDictionary:response
                                                                                                                                       forGenre:genre
                                                                                                                                    byAppending:append];
                                                      if (!registryResultOk)
                                                      {
                                                          DebugLog(@"Registration of Channel Failed for: %@", currentCategoryId);
                                                          return;
                                                      }
                                                      
                                                      [self displayChannelsForGenre:genre];
                                                      
                                                  } onError: ^(NSDictionary* errorInfo) {
                                                      DebugLog(@"Could not load channels: %@", errorInfo);
                                                  }];
}

-(void)displayChannelsForGenre:(Genre*)genre
{
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Channel"
                                   inManagedObjectContext:appDelegate.mainManagedObjectContext]];
    
    
    
    
    NSPredicate* genrePredicate;
    
    if(!genre) // all category
    {
        genrePredicate = [NSPredicate predicateWithFormat:@"popular == TRUE"];
    }
    else
    {
        if([genre isMemberOfClass:[Genre class]]) // no isKindOfClass: which will always return true in this case
        {
            genrePredicate = [NSPredicate predicateWithFormat:@"categoryId IN %@", [genre getSubGenreIdArray]];
        }
        else
        {
            genrePredicate = [NSPredicate predicateWithFormat:@"categoryId == %@", genre.uniqueId];
        }
    }
    
    NSPredicate* notOwnedByUserPredicate = [NSPredicate predicateWithFormat:@"channelOwner.uniqueId != %@", appDelegate.currentUser.uniqueId];
    
    NSPredicate* finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[genrePredicate, notOwnedByUserPredicate]];
    
    
    
    [request setPredicate:finalPredicate];
    
    NSSortDescriptor *positionDescriptor = [[NSSortDescriptor alloc] initWithKey:@"position"
                                                                       ascending:YES];
    
    [request setSortDescriptors:@[positionDescriptor]];
    
    NSError *error = nil;
    NSArray *resultsArray = [appDelegate.mainManagedObjectContext executeFetchRequest:request error:&error];
    if (!resultsArray)
        return;
    
    self.channels = [NSMutableArray arrayWithArray:resultsArray];
    
    [self.channelThumbnailCollectionView reloadData];
    
    
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    
    self.touchedChannelButton = NO;
}

-(void)viewCameToScrollFront
{
    //NSLog(@"Current Genre: %@", currentGenre);
    //[self loadChannelsForGenre:currentGenre];
}


#pragma mark - Helper methods


-(CGSize)itemSize
{
    return [[SYNDeviceManager sharedInstance] isIPhone]? CGSizeMake(152.0f, 152.0f) : CGSizeMake(251.0, 274.0);
}

-(CGSize)footerSize
{
    return [[SYNDeviceManager sharedInstance] isIPhone]? CGSizeMake(320.0f, 64.0f) : CGSizeMake(1024.0, 64.0);
}






#pragma mark - CollectionView Delegate

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}

- (NSInteger) collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section
{
    return self.channels.count;

}



- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    Channel *channel = self.channels[indexPath.row];
    
    SYNChannelThumbnailCell *channelThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelThumbnailCell"
                                                                                              forIndexPath: indexPath];

    [channelThumbnailCell.imageView setImageWithURL: [NSURL URLWithString: channel.channelCover.imageLargeUrl]
                                   placeholderImage: [UIImage imageNamed: @"PlaceholderChannelThumbnail.png"]
                                            options: SDWebImageRetryFailed];
    
    [channelThumbnailCell setChannelTitle: channel.title];
    channelThumbnailCell.displayNameLabel.text = [NSString stringWithFormat: @"%@", channel.channelOwner.displayName];
    channelThumbnailCell.viewControllerDelegate = self;
    


    return channelThumbnailCell;
}

- (void)displayNameButtonPressed: (UIButton*) button
{
    
    
    SYNChannelThumbnailCell* parent = (SYNChannelThumbnailCell*)[[button superview] superview];
    
    NSIndexPath* indexPath = [self.channelThumbnailCollectionView indexPathForCell: parent];
    
    Channel *channel = (Channel*)self.channels[indexPath.row];
    
    [self viewProfileDetails:channel.channelOwner];
    
}



- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
    if (collectionView != self.channelThumbnailCollectionView)
        return nil;
    
    SYNChannelFooterMoreView *channelMoreFooter;
    
    UICollectionReusableView* supplementaryView;
    
    if (kind == UICollectionElementKindSectionHeader)
    {
        // nothing yet
    }
    
    if (kind == UICollectionElementKindSectionFooter)
    {
        channelMoreFooter = [self.channelThumbnailCollectionView dequeueReusableSupplementaryViewOfKind: kind
                                                                                    withReuseIdentifier: @"SYNChannelFooterMoreView"
                                                                                           forIndexPath: indexPath];
        
        [channelMoreFooter.loadMoreButton addTarget: self
                                             action: @selector(loadMoreChannels:)
                                   forControlEvents: UIControlEventTouchUpInside];
        
        supplementaryView = channelMoreFooter;
    }
    
    return supplementaryView;
}


- (void) collectionView: (UICollectionView *) collectionView
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (self.hasTouchedChannelButton == NO)
    {
        self.touchedChannelButton = YES;
        
        Channel *channel = (Channel*)self.channels[indexPath.row];
        
        
        [self viewChannelDetails:channel];
    }
}


#pragma mark - Button Actions

- (void) loadMoreChannels: (UIButton*) sender
{
    NSInteger nextStart = currentRange.location + currentRange.length;
    NSInteger nextSize = (nextStart + STANDARD_LENGTH) > currentTotal ? (currentTotal - nextStart) : STANDARD_LENGTH;
    
    currentRange = NSMakeRange(nextStart, nextSize);
    
    
    [self loadChannelsForGenre:currentGenre byAppending:YES];
}


#ifdef ALLOWS_PINCH_GESTURES

- (void) handlePinchGesture: (UIPinchGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        
        
        // At this stage, we don't know whether the user is pinching in or out
        self.userPinchedOut = FALSE;
        
        DebugLog (@"UIGestureRecognizerStateBegan");
        // figure out which item in the table was selected
        NSIndexPath *indexPath = [self.channelThumbnailCollectionView indexPathForItemAtPoint: [sender locationInView: self.channelThumbnailCollectionView]];
        
        if (!indexPath)
        {
            return;
        }
        
        self.pinchedIndexPath = indexPath;
        
        Channel *channel = (Channel*)self.channels[indexPath.row];
        SYNChannelThumbnailCell *channelCell = (SYNChannelThumbnailCell *)[self.channelThumbnailCollectionView cellForItemAtIndexPath: indexPath];
        
        // Get the various frames we need to calculate the actual position
        CGRect imageViewFrame = channelCell.imageView.frame;
        CGRect viewFrame = channelCell.superview.frame;
        CGRect cellFrame = channelCell.frame;
        
        CGPoint offset = self.channelThumbnailCollectionView.contentOffset;
        
        // Now add them together to get the real pos in the top view
        imageViewFrame.origin.x += cellFrame.origin.x + viewFrame.origin.x - offset.x;
        imageViewFrame.origin.y += cellFrame.origin.y + viewFrame.origin.y - offset.y;
        
        
        self.pinchedView = [[UIImageView alloc] initWithFrame: imageViewFrame];
        self.pinchedView.alpha = 0.7f;
        
        [self.pinchedView setImageWithURL: [NSURL URLWithString: channel.coverThumbnailLargeURL]
                         placeholderImage: nil
                                  options: SDWebImageRetryFailed];
        
        // now add the item to the view
        [self.view addSubview: self.pinchedView];
    }
    else if (sender.state == UIGestureRecognizerStateChanged)
    {
        DebugLog (@"UIGestureRecognizerStateChanged");
        float scale = sender.scale;
        
        if (scale < 1.0)
        {
            return;
        }
        else
        {
            self.userPinchedOut = TRUE;
            
            // we zoomed it, so let's update the coordinates of the dragged view
            self.pinchedView.transform = CGAffineTransformMakeScale(scale, scale);
        }
    }
    else if (sender.state == UIGestureRecognizerStateEnded)
    {
        DebugLog (@"UIGestureRecognizerStateEnded");
        
        if (self.userPinchedOut == TRUE)
        {
            [self transitionToItemAtIndexPath: self.pinchedIndexPath];
        }
    }
    else if (sender.state == UIGestureRecognizerStateCancelled)
    {
        DebugLog (@"UIGestureRecognizerStateCancelled");
        [self.pinchedView removeFromSuperview];
    }
}


// Custom zoom out transition
- (void) transitionToItemAtIndexPath: (NSIndexPath *) indexPath
{
    Channel *channel = (Channel*)self.channels[indexPath.row];
    
    SYNChannelDetailViewController *channelVC = [[SYNChannelDetailViewController alloc] initWithChannel: channel
                                                                                              usingMode: kChannelDetailsModeDisplay];
    
    channelVC.view.alpha = 0.0f;
    
    [self.navigationController pushViewController: channelVC
                                         animated: NO];
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         // Contract thumbnail view
         self.view.alpha = 0.0f;
         channelVC.view.alpha = 1.0f;
         
         // TODO: Put the correct code to hide the top bar (was removed when the implementation started)
         
         self.pinchedView.alpha = 0.0f;
         self.pinchedView.transform = CGAffineTransformMakeScale(10.0f, 10.0f);
         
     }
                     completion: ^(BOOL finished)
     {
         [self.pinchedView removeFromSuperview];
     }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteBackButtonShow
                                                        object: self];
}

#endif


- (void) handleMainTap: (UITapGestureRecognizer *) recogniser
{
    [super handleMainTap:recogniser];
    
    if (!recogniser)
    {
        // then home button was pressed
        if (tabExpanded)
        {
            [UIView animateWithDuration: 0.3
                                  delay: 0.0
                                options: UIViewAnimationCurveEaseInOut
                             animations: ^{
                                 CGPoint currentCenter = self.channelThumbnailCollectionView.center;
                                 [self.channelThumbnailCollectionView setCenter: CGPointMake(currentCenter.x, currentCenter.y - kCategorySecondRowHeight)];
                             }  completion: ^(BOOL result) {
                                 tabExpanded = NO;
                             }];
        }
        
        return;
    }
    
    if (tabExpanded)
        return;
    
    tabExpanded = YES;
    
    [UIView animateWithDuration: 0.3
                          delay: 0.0
                        options: UIViewAnimationCurveEaseInOut
                     animations: ^{
                         CGPoint currentCenter = self.channelThumbnailCollectionView.center;
                         [self.channelThumbnailCollectionView setCenter: CGPointMake(currentCenter.x, currentCenter.y + kCategorySecondRowHeight)];
                     }
                     completion: ^(BOOL result) {
                         tabExpanded = YES;
                     }];
}


- (void) handleNewTabSelectionWithId: (NSString *) selectionId
{

     
}

- (void) handleNewTabSelectionWithGenre: (Genre *) genre
{
    

    if([currentGenre.uniqueId isEqualToString:genre.uniqueId])
    {
        return;
    }
    
    
    
    currentCategoryId = genre.uniqueId;

    currentRange = NSMakeRange(0, 50);
    
    
    
    if(genre == nil)
    {
        // all category chosen
        currentCategoryId = @"all";
        currentGenre = nil;
    }
    else
    {
        currentCategoryId = genre.uniqueId;
        currentGenre = genre;
        
            
    }
    
    
    [self loadChannelsForGenre:genre];
    

}


#pragma mark - categories tableview

-(void)layoutChannelsCategoryTable
{
    self.categorySelectDismissControl = [[UIControl alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.categorySelectDismissControl];
    [self.categorySelectDismissControl addTarget:self action:@selector(toggleChannelsCategoryTable:) forControlEvents:UIControlEventTouchDown];
    self.categorySelectDismissControl.hidden = YES;
    
    
    self.categoryTableViewController = [[SYNChannelCategoryTableViewController alloc] init];
    CGRect newFrame = self.channelThumbnailCollectionView.frame;
    newFrame.size.width = self.categoryTableViewController.view.frame.size.width;
    self.categoryTableViewController.view.frame = newFrame;
    [self.view addSubview:self.categoryTableViewController.view];
    self.categoryTableViewController.categoryTableControllerDelegate= self;
    self.categoryTableViewController.view.hidden = YES;
    
    
    newFrame.origin.y -= 44.0f;
    newFrame.size.height = 44.0f;
    newFrame.size.width = 320.0f;
    self.categorySelectButton = [[UIButton alloc] initWithFrame:newFrame];
    [self.categorySelectButton setBackgroundImage:[UIImage imageNamed:@"CategoryBar"] forState:UIControlStateNormal];
    [self.categorySelectButton setBackgroundImage:[UIImage imageNamed:@"CategoryBarHighlighted"] forState:UIControlStateHighlighted];
    [self.categorySelectButton addTarget:self action:@selector(toggleChannelsCategoryTable:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.categorySelectButton];
    
    newFrame.origin.x = 40.0f;
    newFrame.origin.y += 3.0f;
    newFrame.size.width = 280.0f;
    
    UILabel* newLabel = [[UILabel alloc] initWithFrame:newFrame];
    newLabel.font = [UIFont boldRockpackFontOfSize:18.0f];
    newLabel.textColor = [UIColor colorWithRed:106.0f/255.0f green:114.0f/255.0f blue:122.0f/255.0f alpha:1.0f];
    newLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.75f];
    newLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    newLabel.text = NSLocalizedString(@"ALL CATEGORIES",nil);
    newLabel.backgroundColor = [UIColor clearColor];
    CGPoint center = newLabel.center;
    [newLabel sizeToFit];
    center.x = newLabel.center.x;
    newLabel.center = center;
    self.categoryNameLabel = newLabel;
    [self.view addSubview:self.categoryNameLabel];
    
    
    newLabel = [[UILabel alloc] initWithFrame:self.categoryNameLabel.frame];
    newLabel.font = self.categoryNameLabel.font;
    newLabel.textColor = self.categoryNameLabel.textColor;
    newLabel.shadowColor = self.categoryNameLabel.shadowColor;
    newLabel.shadowOffset = self.categoryNameLabel.shadowOffset;
    newLabel.backgroundColor = self.categoryNameLabel.backgroundColor;
    newLabel.hidden = YES;
    newLabel.center = center;

    self.subCategoryNameLabel = newLabel;
    [self.view addSubview:self.subCategoryNameLabel];
    
    self.arrowImage =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconCategoryBarChevron~iphone"]];
    center.y -= 4.0f;
    self.arrowImage.center = center;
    self.arrowImage.hidden = YES;
    [self.view addSubview:self.arrowImage];
    
    
    
    
}

-(void)toggleChannelsCategoryTable:(id)sender
{
    if(self.categoryTableViewController.view.hidden)
    {
        CGRect startFrame = self.categoryTableViewController.view.frame;
        startFrame.origin.x = -startFrame.size.width;
        self.categoryTableViewController.view.frame = startFrame;
        self.categoryTableViewController.view.hidden = NO;
        self.categorySelectDismissControl.hidden = NO;
        
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGRect endFrame = self.categoryTableViewController.view.frame;
            endFrame.origin.x = 0;
            self.categoryTableViewController.view.frame = endFrame;
        } completion:nil];
     }
    else
    {
        self.categorySelectDismissControl.hidden = YES;
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            CGRect endFrame = self.categoryTableViewController.view.frame;
            endFrame.origin.x = -endFrame.size.width;
            self.categoryTableViewController.view.frame = endFrame;
        } completion:^(BOOL finished) {
            self.categoryTableViewController.view.hidden = YES;
        }];
    }
}



-(void)categoryTableController:(SYNChannelCategoryTableViewController *)tableController didSelectCategory:(Genre *)category
{
    if(category)
    {
        self.categoryNameLabel.text = category.name;
        [self.categoryNameLabel sizeToFit];
        self.subCategoryNameLabel.hidden = YES;
        self.arrowImage.hidden = YES;
        [self handleNewTabSelectionWithGenre:category];
    }
    else
    {
        self.categoryNameLabel.text = @"ALL CATEGORIES";
        [self.categoryNameLabel sizeToFit];
        self.subCategoryNameLabel.hidden = YES;
        self.arrowImage.hidden = YES;
        [self handleNewTabSelectionWithGenre:nil];
    }
}

-(void)categoryTableController:(SYNChannelCategoryTableViewController *)tableController didSelectSubCategory:(SubGenre *)subCategory
{
    self.categoryNameLabel.text = subCategory.genre.name;
    [self.categoryNameLabel sizeToFit];
    self.subCategoryNameLabel.text = subCategory.name;
    self.subCategoryNameLabel.hidden = NO;
    [self.subCategoryNameLabel sizeToFit];
    self.arrowImage.hidden = NO;
    
    CGRect newFrame = self.arrowImage.frame;
    newFrame.origin.x = self.categoryNameLabel.frame.origin.x + self.categoryNameLabel.frame.size.width + 5.0f;
    self.arrowImage.frame = newFrame;
    
    newFrame = self.subCategoryNameLabel.frame;
    newFrame.origin.x = self.arrowImage.frame.origin.x + self.arrowImage.frame.size.width + 5.0f;
    self.subCategoryNameLabel.frame = newFrame;
    

    [self handleNewTabSelectionWithId:subCategory.uniqueId];
    [self handleNewTabSelectionWithGenre: subCategory];

    [self toggleChannelsCategoryTable:nil];
}

-(void)categoryTableControllerDeselectedAll:(SYNChannelCategoryTableViewController *)tableController
{
    self.categoryNameLabel.text = NSLocalizedString(@"ALL CATEGORIES",nil);
    [self.categoryNameLabel sizeToFit];
    self.subCategoryNameLabel.hidden = YES;
    self.arrowImage.hidden = YES;
    
    [self handleNewTabSelectionWithId: @"all"];
    [self handleNewTabSelectionWithGenre: nil];
    
    [self toggleChannelsCategoryTable:nil];
}



@end
