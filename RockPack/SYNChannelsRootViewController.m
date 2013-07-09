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
#import "GAI.h"
#import "SYNChannelCategoryTableViewController.h"
#import "SYNChannelDetailViewController.h"
#import "SYNChannelThumbnailCell.h"
#import "SYNChannelsRootViewController.h"
#import "SYNDeviceManager.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNMainRegistry.h"
#import "SYNNetworkEngine.h"
#import "SubGenre.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import "SYNGenreItemView.h"
#import "Video.h"
#import "VideoInstance.h"
#import "SYNFeedMessagesView.h"


#define kChannelsCache @"ChannelsCache"

@interface SYNChannelsRootViewController () <UIScrollViewDelegate, SYNChannelCategoryTableViewDelegate>

@property (nonatomic, assign) BOOL ignoreRefresh;
@property (nonatomic, strong) Genre* allGenre;
@property (nonatomic, strong) Genre* currentGenre;
@property (nonatomic, strong) NSMutableArray* channels;
@property (nonatomic, strong) NSString* currentCategoryId;
@property (nonatomic, strong) SYNChannelCategoryTableViewController* categoryTableViewController;
@property (nonatomic, strong) SYNFeedMessagesView* emptyGenreMessageView;
@property (nonatomic, strong) UIButton* categorySelectButton;
@property (nonatomic, strong) UIControl* categorySelectDismissControl;
@property (nonatomic, strong) UIImageView* arrowImage;
@property (nonatomic, strong) UILabel* categoryNameLabel;
@property (nonatomic, strong) UILabel* subCategoryNameLabel;
@property (nonatomic, weak) SYNMainRegistry* mainRegistry;

@end

@implementation SYNChannelsRootViewController

@synthesize currentCategoryId;
@synthesize currentGenre;
@synthesize dataRequestRange;
@synthesize dataItemsAvailable;
@synthesize mainRegistry;
@synthesize isAnimating;
@synthesize channels;
@synthesize runningNetworkOperation = _runningNetworkOperation;


#pragma mark - Object lifecycle

- (void) dealloc
{
    // Defensive programming
    self.channelThumbnailCollectionView.delegate = nil;
}


#pragma mark - View lifecycle

- (void) loadView
{
    BOOL isIPhone = IS_IPHONE;
    
    SYNIntegralCollectionViewFlowLayout* flowLayout;
    
    if (isIPhone)
    {
        flowLayout = [SYNIntegralCollectionViewFlowLayout layoutWithItemSize: CGSizeMake(158.0f, 169.0f)
                                                     minimumInterItemSpacing: 0.0
                                                          minimumLineSpacing: 6.0
                                                             scrollDirection: UICollectionViewScrollDirectionVertical
                                                                sectionInset: UIEdgeInsetsMake(2.0, 2.0, 46.0, 2.0)];
    }
    else
    {
        flowLayout = [SYNIntegralCollectionViewFlowLayout layoutWithItemSize: [self itemSize]
                                                     minimumInterItemSpacing: 0.0
                                                          minimumLineSpacing: 2.0
                                                             scrollDirection: UICollectionViewScrollDirectionVertical
                                                                sectionInset: UIEdgeInsetsMake(6.0, 6.0, 5.0, 6.0)];
    }

    flowLayout.footerReferenceSize = [self footerSize];
    
    // Work out how hight the inital tab bar is
    CGFloat topTabBarHeight = [UIImage imageNamed: @"CategoryBar"].size.height;
    
    CGRect channelCollectionViewFrame;
    if (isIPhone)
    {
        channelCollectionViewFrame = CGRectMake(0.0f, 103.0f, [SYNDeviceManager.sharedInstance currentScreenWidth], [SYNDeviceManager.sharedInstance currentScreenHeight] - 123.0f);
    }
    else
    {
        channelCollectionViewFrame = [SYNDeviceManager.sharedInstance isLandscape] ?
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
    self.channelThumbnailCollectionView.scrollsToTop = NO;
    
    CGRect newFrame;
    
    if (isIPhone)
    {
        newFrame = CGRectMake(0.0f, 59.0f, [SYNDeviceManager.sharedInstance currentScreenWidth], [SYNDeviceManager.sharedInstance currentScreenHeight] - 20.0f);
    }
    else
    {
        newFrame = [SYNDeviceManager.sharedInstance isLandscape] ?
        CGRectMake(0.0, 0.0, kFullScreenWidthLandscape, kFullScreenHeightLandscapeMinusStatusBar) :
        CGRectMake(0.0f, 0.0f, kFullScreenWidthPortrait, kFullScreenHeightPortraitMinusStatusBar);
    }
    
    self.view = [[UIView alloc] initWithFrame:newFrame];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.channelThumbnailCollectionView];
    
    if (self.enableCategoryTable)
    {
        [self layoutChannelsCategoryTable];
    }
    
    self.channelThumbnailCollectionView.showsVerticalScrollIndicator = YES;
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

    
    currentGenre = nil;
    
    [self displayChannelsForGenre:currentGenre];
    
    [self loadChannelsForGenre:currentGenre];
}


- (void) viewDidScrollToFront
{
    [self updateAnalytics];
    
    // On Boarding
    
    self.channelThumbnailCollectionView.scrollsToTop = YES;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasShownSubscribeOnBoarding = [defaults boolForKey:kUserDefaultsChannels];
    if(!hasShownSubscribeOnBoarding)
    {
        NSString* message = NSLocalizedString(@"onboarding_channels", nil);
        
        CGFloat fontSize = IS_IPAD ? 19.0 : 15.0 ;
        CGSize size = IS_IPAD ? CGSizeMake(340.0, 164.0) : CGSizeMake(260.0, 144.0);
        SYNOnBoardingPopoverView* subscribePopover = [SYNOnBoardingPopoverView withMessage:message
                                                                                  withSize:size
                                                                               andFontSize:fontSize
                                                                                pointingTo:CGRectZero
                                                                             withDirection:PointingDirectionNone];
        
        
        [appDelegate.onBoardingQueue addPopover:subscribePopover];
        
        [defaults setBool:YES forKey:kUserDefaultsChannels];
        
        [appDelegate.onBoardingQueue present];
    }
    

    
    // if the user has requested 'Load More' channels then dont refresh the page cause he is in the middle of a search
    if(self.dataRequestRange.location == 0)
        [self loadChannelsForGenre:currentGenre];
}

-(void)viewDidScrollToBack
{
    self.channelThumbnailCollectionView.scrollsToTop = NO;
}

- (void) updateAnalytics
{
    // Google analytics support
    [GAI.sharedInstance.defaultTracker sendView: @"Channels - Root"];
}



#pragma mark - Loading of Channels

- (void) loadChannelsForGenre: (Genre*) genre
{
    [self loadChannelsForGenre: genre
                   byAppending: NO];
}


- (void) loadChannelsForGenre: (Genre*) genre
                  byAppending: (BOOL) append
{
    
//    DebugLog(@"Next request: %i - %i", self.dataRequestRange.location, self.dataRequestRange.length + self.dataRequestRange.location - 1);
    
    self.runningNetworkOperation = [appDelegate.networkEngine updateChannelsScreenForCategory: (genre ? genre.uniqueId : @"all")
                                                                                     forRange: self.dataRequestRange
                                                                                ignoringCache: NO
                                                                                 onCompletion: ^(NSDictionary* response) {
                                                      
                                                      NSDictionary *channelsDictionary = response[@"channels"];
                                                      if (!channelsDictionary || ![channelsDictionary isKindOfClass: [NSDictionary class]])
                                                          return;
                                                      
                                                      NSArray *itemArray = channelsDictionary[@"items"];
                                                      if (![itemArray isKindOfClass: [NSArray class]])
                                                          return;
                                                      
                                                      dataRequestRange.length = itemArray.count;
                                                      
                                                      
                                                      
                                                      NSNumber *totalNumber = channelsDictionary[@"total"];
                                                      if (![totalNumber isKindOfClass: [NSNumber class]])
                                                          return;
                                                      
                                                      self.dataItemsAvailable = [totalNumber integerValue];
                                                      
                                                      
                                                      BOOL registryResultOk = [appDelegate.mainRegistry registerChannelsFromDictionary: response
                                                                                                                              forGenre: genre
                                                                                                                           byAppending: append];
                                                       self.loadingMoreContent = NO;
                                                      
                                                      if (!registryResultOk)
                                                      {
                                                          DebugLog(@"Registration of Channel Failed for: %@", currentCategoryId);
                                                          return;
                                                      }
                                                      
                                                      [self displayChannelsForGenre:genre];
                                                      
                                                      if (self.emptyGenreMessageView)
                                                      {
                                                          [self.emptyGenreMessageView removeFromSuperview];
                                                          self.emptyGenreMessageView = nil;
                                                      }
                                                      
                                                      if (self.channels.count == 0)
                                                      {
                                                          [self displayEmptyGenreMessage:@"NO CHANNELS FOUND"];
                                                      }
                                                      
                                                      
                                                      
                                                  } onError: ^(NSDictionary* errorInfo) {
                                                      DebugLog(@"Could not load channels: %@", errorInfo);
                                                      self.loadingMoreContent = NO;

                                                  }];
}


- (void) loadMoreChannels
{
    // Check to see if we have loaded all items already
    if (self.moreItemsToLoad == TRUE)
    {
        self.loadingMoreContent = YES;
        
        [self incrementRangeForNextRequest];
        
        [self loadChannelsForGenre: currentGenre
                       byAppending: YES];
    }
}


- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    // when reaching far right hand side, load a new page
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height - kLoadMoreFooterViewHeight
        && self.isLoadingMoreContent == NO)
    {
        [self loadMoreChannels];
    }
}


- (void) displayChannelsForGenre: (Genre*) genre
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName: @"Channel"
                                   inManagedObjectContext: appDelegate.mainManagedObjectContext]];
    
    NSPredicate* genrePredicate;
    
    if (!genre) // @"all" category
    {
        genrePredicate = [NSPredicate predicateWithFormat: @"popular == YES"];
    }
    else
    {
        if ([genre isMemberOfClass:[Genre class]]) // no isKindOfClass: which will always return true in this case
        {
            genrePredicate = [NSPredicate predicateWithFormat: @"categoryId IN %@", [genre getSubGenreIdArray]];
        }
        else
        {
            genrePredicate = [NSPredicate predicateWithFormat: @"categoryId == %@", genre.uniqueId];
        }
    }
    
    NSPredicate* viewIdPredicate = [NSPredicate predicateWithFormat: @"viewId == %@", kChannelsViewId];
    
    // only get the channels marked as fresh //
    
    NSPredicate* isFreshPredicate = [NSPredicate predicateWithFormat: @"fresh == YES"];
    
    
    
    NSPredicate* finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:
                                   @[genrePredicate, isFreshPredicate, viewIdPredicate]];

    [request setPredicate:finalPredicate];
    
    NSSortDescriptor *positionDescriptor = [[NSSortDescriptor alloc] initWithKey:@"position"  ascending:YES];
    
    [request setSortDescriptors:@[positionDescriptor]];
    
    NSError *error = nil;
    
    NSArray *resultsArray = [appDelegate.mainManagedObjectContext executeFetchRequest: request error: &error];
    if (!resultsArray)
        return;

    self.channels = [NSMutableArray arrayWithArray: resultsArray];
    
    // We shouldn't wait until the animation is over, as this will result in crashes if the user is scrolling
    [self.channelThumbnailCollectionView reloadData];
}


- (void) displayEmptyGenreMessage:(NSString*)message
{
    
    if (self.emptyGenreMessageView) // add no more than one
        return;
    
    self.emptyGenreMessageView = [SYNFeedMessagesView withMessage:message];
    
    self.emptyGenreMessageView.center = CGPointMake(self.view.center.x, 280.0);
    self.emptyGenreMessageView.frame = CGRectIntegral(self.emptyGenreMessageView.frame);
   
    [self.view insertSubview:self.emptyGenreMessageView belowSubview:self.categoryTableViewController.view];
}


#pragma mark - Helper Methods


- (CGSize) itemSize
{
    return IS_IPHONE ? CGSizeMake(152.0f, 152.0f) : CGSizeMake(251.0, 274.0);
}




#pragma mark - CollectionView Delegate

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}

- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    return self.channels.count;

}



- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    Channel *channel = self.channels[indexPath.row];
    
    SYNChannelThumbnailCell *channelThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelThumbnailCell"
                                                                                              forIndexPath: indexPath];
    
    
    if(channel.favouritesValue)
    {
        if([appDelegate.currentUser.uniqueId isEqualToString:channel.channelOwner.uniqueId])
        {
            [channelThumbnailCell setChannelTitle: [NSString stringWithFormat:@"MY %@", NSLocalizedString(@"FAVORITES", nil)] ];
        }
        else
        {
            [channelThumbnailCell setChannelTitle:
             [NSString stringWithFormat:@"%@'S %@", [channel.channelOwner.displayName uppercaseString], NSLocalizedString(@"FAVORITES", nil)]];
        }
        
    }
    else
    {
        
        [channelThumbnailCell setChannelTitle: channel.title];
    }
    
    
    channelThumbnailCell.imageUrlString = channel.channelCover.imageLargeUrl;
    channelThumbnailCell.displayNameLabel.text = [NSString stringWithFormat: @"%@", channel.channelOwner.displayName];
    channelThumbnailCell.viewControllerDelegate = self;
    
    
    return channelThumbnailCell;
}

- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [((SYNChannelThumbnailCell*)cell).imageView cancelCurrentImageLoad];
    
}
- (void) displayNameButtonPressed: (UIButton*) button
{
    
    
    SYNChannelThumbnailCell* parent = (SYNChannelThumbnailCell*)[[button superview] superview];
    
    NSIndexPath* indexPath = [self.channelThumbnailCollectionView indexPathForCell: parent];
    
    Channel *channel = (Channel*)self.channels[indexPath.row];
    
    [appDelegate.viewStackManager viewProfileDetails:channel.channelOwner];
    
}



- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
    if (collectionView != self.channelThumbnailCollectionView)
        return nil;

    UICollectionReusableView* supplementaryView;
    
    if (kind == UICollectionElementKindSectionHeader)
    {
        // nothing yet
    }
    
    if (kind == UICollectionElementKindSectionFooter)
    {
        if (self.channels.count == 0)
        {
            return supplementaryView;
        }
        
        self.footerView = [self.channelThumbnailCollectionView dequeueReusableSupplementaryViewOfKind: kind
                                                                                  withReuseIdentifier: @"SYNChannelFooterMoreView"
                                                                                         forIndexPath: indexPath];
        self.footerView.showsLoading = self.isLoadingMoreContent;

        supplementaryView = self.footerView;
    }
    
    return supplementaryView;
}


- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout*) collectionViewLayout
                  referenceSizeForFooterInSection: (NSInteger) section
{
    CGSize footerSize;
    
    if (collectionView == self.channelThumbnailCollectionView)
    {
        footerSize = [self footerSize];
        
        
        // Now set to zero anyway if we have already read in all the items
        NSInteger nextStart = self.dataRequestRange.location + self.dataRequestRange.length; // one is subtracted when the call happens for 0 indexing
        
        // FIXME: Is this comparison correct?  Should it just be self.dataRequestRange.location >= self.dataItemsAvailable?
        if (nextStart >= self.dataItemsAvailable)
        {
            DebugLog(@"Set footer size to border");
            footerSize = CGSizeMake(1.0f, 5.0f);
        }
        else
        {
            DebugLog(@"Normal footer size");
        }
    }
    else
    {
        footerSize = CGSizeZero;
    }
    
    return footerSize;
}


- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (self.isAnimating) // prevent double clicking
        return;
    
    Channel *channel = (Channel*)self.channels[indexPath.row];
    
    [appDelegate.viewStackManager viewChannelDetails:channel];
}



- (void) handleMainTap: (UIView *) tab
{
    [super handleMainTap:tab];
    
    
    if (!tab || tab.tag == 0)
    {
        // then home button was pressed in either its icon or "all" mode respectively
        if (tabExpanded && !isAnimating)
            [self animateCollectionViewDown:NO];
        
        return;
    }
    
    if (tabExpanded || isAnimating)
        return;
    
    [self animateCollectionViewDown:YES];
    
    
}

#pragma mark - Pushing UICollectionView up and down

-(void)animateCollectionViewDown:(BOOL)down
{
    
    if (down && !tabExpanded)
    {
        
        
        isAnimating = YES;
        
        [UIView animateWithDuration: 0.4
                              delay: 0.0
                            options: UIViewAnimationCurveEaseInOut
                         animations: ^{
                             CGRect currentCollectionViewFrame = self.channelThumbnailCollectionView.frame;
                             currentCollectionViewFrame.origin.y += kCategorySecondRowHeight;
                             //
                             self.channelThumbnailCollectionView.frame = currentCollectionViewFrame;
                         }
                         completion: ^(BOOL result) {
                             
                             tabExpanded = YES;
                             isAnimating = NO;
                             [self.channelThumbnailCollectionView reloadData];
                             CGRect currentCollectionViewFrame = self.channelThumbnailCollectionView.frame;
                             currentCollectionViewFrame.size.height -= kCategorySecondRowHeight;
                             self.channelThumbnailCollectionView.frame = currentCollectionViewFrame;
                         }];
    }
    else if (tabExpanded)
    {
        
        isAnimating = YES;
        
        [UIView animateWithDuration: 0.4
                              delay: 0.1
                            options: UIViewAnimationCurveEaseInOut
                         animations: ^{
                             
                             CGRect currentCollectionViewFrame = self.channelThumbnailCollectionView.frame;
                             currentCollectionViewFrame.origin.y -= kCategorySecondRowHeight;
                             //
                             self.channelThumbnailCollectionView.frame = currentCollectionViewFrame;
                             
                             
                         }  completion: ^(BOOL result) {
                             
                             tabExpanded = NO;
                             isAnimating = NO;
                             
                             [self.channelThumbnailCollectionView reloadData];
                             
                             CGRect currentCollectionViewFrame = self.channelThumbnailCollectionView.frame;
                             currentCollectionViewFrame.size.height += kCategorySecondRowHeight;
                             self.channelThumbnailCollectionView.frame = currentCollectionViewFrame;
                         }];
    }
}

-(void)collapseToParentCategory
{
    [((SYNGenreTabView*)self.tabViewController.tabView) hideSecondaryTabs];
    [self animateCollectionViewDown:NO];
}


- (void) handleNewTabSelectionWithId: (NSString *) selectionId
{

     
}

- (void) handleNewTabSelectionWithGenre: (Genre *) genre
{
    [appDelegate.viewStackManager hideSideNavigator];
    
    if ([currentGenre.uniqueId isEqualToString: genre.uniqueId])
    {
        return;
    }

    currentCategoryId = genre.uniqueId;

    dataRequestRange = NSMakeRange(0, STANDARD_REQUEST_LENGTH);

    if (genre == nil)
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
    
    CGPoint currentOffset = self.channelThumbnailCollectionView.contentOffset;
    currentOffset.y = 0;
    
    // Need to do this immediately, as opposed to animated or we may get strange offsets //
    
    [self.channelThumbnailCollectionView setContentOffset: currentOffset
                                                 animated: NO];
    
    // display what is already in the DB and then load and display again
    
    [self displayChannelsForGenre:genre];
    
    if (self.channels.count > 0)
    {
        if (self.emptyGenreMessageView)
        {
            [self.emptyGenreMessageView removeFromSuperview];
            self.emptyGenreMessageView = nil;
        }
    }
    else
    {
        [self displayEmptyGenreMessage:@"LOADING CHANNELS"];
    }
    
    [self loadChannelsForGenre: genre];
}

- (void) clearedLocationBoundData
{
    [self animateCollectionViewDown:NO];
    
    self.dataRequestRange = NSMakeRange(0, STANDARD_REQUEST_LENGTH);
    
    self.currentGenre = nil;
    
    [self loadChannelsForGenre: nil];
}


#pragma mark - categories tableview

- (void) layoutChannelsCategoryTable
{
    self.categorySelectDismissControl = [[UIControl alloc] initWithFrame: self.view.bounds];
    [self.view addSubview: self.categorySelectDismissControl];
    
    [self.categorySelectDismissControl addTarget: self
                                          action: @selector(toggleChannelsCategoryTable:)
                                forControlEvents: UIControlEventTouchDown];
    
    self.categorySelectDismissControl.hidden = YES;
    
    
    self.categoryTableViewController = [[SYNChannelCategoryTableViewController alloc] init];
    CGRect newFrame = self.channelThumbnailCollectionView.frame;
    newFrame.size.width = self.categoryTableViewController.view.frame.size.width;
    self.categoryTableViewController.view.frame = newFrame;
    [self.view addSubview:self.categoryTableViewController.view];
    [self addChildViewController:self.categoryTableViewController];
    self.categoryTableViewController.categoryTableControllerDelegate= self;
    self.categoryTableViewController.view.hidden = YES;
    
    
    newFrame.origin.y -= 44.0f;
    newFrame.size.height = 44.0f;
    newFrame.size.width = 320.0f;
    self.categorySelectButton = [[UIButton alloc] initWithFrame: newFrame];
    
    [self.categorySelectButton setBackgroundImage: [UIImage imageNamed: @"CategoryBar"]
                                         forState: UIControlStateNormal];
    
    [self.categorySelectButton setBackgroundImage: [UIImage imageNamed: @"CategoryBarHighlighted"]
                                         forState: UIControlStateHighlighted];
    
    [self.categorySelectButton addTarget: self
                                  action: @selector(toggleChannelsCategoryTable:)
                        forControlEvents: UIControlEventTouchUpInside];
    
    [self.view addSubview: self.categorySelectButton];
    
    newFrame.origin.x = 40.0f;
    newFrame.origin.y += 3.0f;
    newFrame.size.width = 280.0f;
    
    UILabel* newLabel = [[UILabel alloc] initWithFrame:newFrame];
    newLabel.font = [UIFont boldRockpackFontOfSize:18.0f];
    newLabel.textColor = [UIColor colorWithRed: 106.0f/255.0f green: 114.0f/255.0f blue: 122.0f/255.0f alpha: 1.0f];
    newLabel.shadowColor = [UIColor colorWithWhite: 1.0f alpha: 0.75f];
    newLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    newLabel.text = NSLocalizedString(@"ALL CATEGORIES",nil);
    newLabel.backgroundColor = [UIColor clearColor];
    CGPoint center = newLabel.center;
    [newLabel sizeToFit];
    center.x = newLabel.center.x;
    newLabel.center = center;
    self.categoryNameLabel = newLabel;
    [self.view addSubview: self.categoryNameLabel];
    
    
    newLabel = [[UILabel alloc] initWithFrame: self.categoryNameLabel.frame];
    newLabel.font = self.categoryNameLabel.font;
    newLabel.textColor = self.categoryNameLabel.textColor;
    newLabel.shadowColor = self.categoryNameLabel.shadowColor;
    newLabel.shadowOffset = self.categoryNameLabel.shadowOffset;
    newLabel.backgroundColor = self.categoryNameLabel.backgroundColor;
    newLabel.hidden = YES;
    newLabel.center = center;

    self.subCategoryNameLabel = newLabel;
    [self.view addSubview:self.subCategoryNameLabel];
    
    self.arrowImage =[[UIImageView alloc] initWithImage: [UIImage imageNamed: @"IconCategoryBarChevron~iphone"]];
    center.y -= 4.0f;
    self.arrowImage.center = center;
    self.arrowImage.hidden = YES;
    [self.view addSubview: self.arrowImage];
    
    
    
    
}

- (void) toggleChannelsCategoryTable: (id) sender
{
    if (self.categoryTableViewController.view.hidden)
    {
        CGRect startFrame = self.categoryTableViewController.view.frame;
        startFrame.origin.x = -startFrame.size.width;
        self.categoryTableViewController.view.frame = startFrame;
        self.categoryTableViewController.view.hidden = NO;
        self.categorySelectDismissControl.hidden = NO;
        
        [UIView animateWithDuration: 0.2f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             CGRect endFrame = self.categoryTableViewController.view.frame;
                             endFrame.origin.x = 0;
                             self.categoryTableViewController.view.frame = endFrame;
                         }
                         completion: nil];
    }
    else
    {
        self.categorySelectDismissControl.hidden = YES;
        [UIView animateWithDuration: 0.2f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseIn
                         animations: ^{
                             CGRect endFrame = self.categoryTableViewController.view.frame;
                             endFrame.origin.x = -endFrame.size.width;
                             self.categoryTableViewController.view.frame = endFrame;
                         }
                         completion: ^(BOOL finished) {
                             self.categoryTableViewController.view.hidden = YES;
                         }];
    }
}



- (void) categoryTableController: (SYNChannelCategoryTableViewController *) tableController
               didSelectCategory: (Genre *) category
{
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker sendEventWithCategory: @"uiAction"
                        withAction: @"categoryItemClick"
                         withLabel: category.name
                         withValue: nil];
    if (category)
    {
        self.categoryNameLabel.text = category.name;
        [self.categoryNameLabel sizeToFit];
        self.subCategoryNameLabel.hidden = YES;
        self.arrowImage.hidden = YES;
        [self handleNewTabSelectionWithGenre: category];
    }
    else
    {
        self.categoryNameLabel.text = @"ALL CATEGORIES";
        [self.categoryNameLabel sizeToFit];
        self.subCategoryNameLabel.hidden = YES;
        self.arrowImage.hidden = YES;
        [self handleNewTabSelectionWithGenre: nil];
    }
}


- (void) categoryTableController: (SYNChannelCategoryTableViewController *) tableController
            didSelectSubCategory: (SubGenre *) subCategory
{
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker sendEventWithCategory: @"uiAction"
                        withAction: @"categoryItemClick"
                         withLabel: subCategory.name
                         withValue: nil];
    
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
    
    [self handleNewTabSelectionWithGenre: subCategory];

    [self toggleChannelsCategoryTable:nil];
}

-(void)setRunningNetworkOperation:(MKNetworkOperation *)runningNetworkOperation
{
    if(_runningNetworkOperation)
        [_runningNetworkOperation cancel];
    
    _runningNetworkOperation = runningNetworkOperation;
}

- (void) categoryTableControllerDeselectedAll: (SYNChannelCategoryTableViewController *) tableController
{
    self.categoryNameLabel.text = NSLocalizedString(@"ALL CATEGORIES",nil);
    [self.categoryNameLabel sizeToFit];
    self.subCategoryNameLabel.hidden = YES;
    self.arrowImage.hidden = YES;
    
    [self handleNewTabSelectionWithGenre: nil];
    
    [self toggleChannelsCategoryTable: nil];
}

-(void)headerTapped
{
    [self.channelThumbnailCollectionView setContentOffset:CGPointZero animated:YES];
}



@end
