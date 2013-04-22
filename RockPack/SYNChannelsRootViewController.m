//
//  SYNChannelsTopTabViewController.m
//  rockpack
//
//  Created by Nick Banks on 01/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "SYNAppDelegate.h"
#import "SYNChannelThumbnailCell.h"
#import "SYNChannelDetailViewController.h"
#import "SYNChannelsRootViewController.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNNetworkEngine.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+ImageProcessing.h"
#import "Video.h"
#import "SYNChannelFooterMoreView.h"
#import "SYNDeviceManager.h"
#import "SYNMainRegistry.h"

#define STANDARD_LENGTH 50

@interface SYNChannelsRootViewController () <UIScrollViewDelegate>

@property (nonatomic, assign) BOOL userPinchedOut;
@property (nonatomic, assign) BOOL ignoreRefresh;
@property (getter = hasTouchedChannelButton) BOOL touchedChannelButton;
@property (nonatomic, strong) NSIndexPath *pinchedIndexPath;
@property (nonatomic, strong) UIImageView *pinchedView;
@property (nonatomic, strong) NSString* currentCategoryId;

@property (nonatomic, weak) SYNMainRegistry* mainRegistry;


@property (nonatomic) NSRange currentRange;
@property (nonatomic) NSInteger currentTotal;

@end

@implementation SYNChannelsRootViewController

@synthesize currentCategoryId;
@synthesize currentRange;
@synthesize currentTotal;
@synthesize mainRegistry;

#pragma mark - View lifecycle

-(id)initWithViewId:(NSString *)vid
{
    if ((self = [super initWithViewId:vid]))
    {
        self.title = kChannelsTitle;
    }
    return self;
}

-(CGSize)itemSize
{
    return CGSizeMake(251.0, 212.0);
}

-(CGSize)footerSize
{
    return CGSizeMake(1024.0, 64.0);
}

- (void) loadView
{
    SYNIntegralCollectionViewFlowLayout* flowLayout = [[SYNIntegralCollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.headerReferenceSize = CGSizeMake(0.0, 0.0);
    flowLayout.footerReferenceSize = [self footerSize];
    flowLayout.itemSize = [self itemSize];
    flowLayout.sectionInset = UIEdgeInsetsMake(30.0, 6.0, 5.0, 6.0);
    flowLayout.minimumLineSpacing = 30.0;
    flowLayout.minimumInteritemSpacing = 0.0;
    
    // Work out how hight the inital tab bar is
    CGFloat topTabBarHeight = [UIImage imageNamed: @"CategoryBar"].size.height;
    
    CGRect channelCollectionViewFrame = [[SYNDeviceManager sharedInstance] isLandscape] ?
    CGRectMake(0.0, kStandardCollectionViewOffsetY + topTabBarHeight, kFullScreenWidthLandscape, kFullScreenHeightLandscapeMinusStatusBar - kStandardCollectionViewOffsetY - topTabBarHeight) :
    CGRectMake(0.0f, kStandardCollectionViewOffsetY + topTabBarHeight, kFullScreenWidthPortrait, kFullScreenHeightPortraitMinusStatusBar  - kStandardCollectionViewOffsetY - topTabBarHeight);
    
    self.channelThumbnailCollectionView = [[UICollectionView alloc] initWithFrame: channelCollectionViewFrame
                                                             collectionViewLayout: flowLayout];
    self.channelThumbnailCollectionView.dataSource = self;
    self.channelThumbnailCollectionView.delegate = self;
    self.channelThumbnailCollectionView.backgroundColor = [UIColor clearColor];
    self.channelThumbnailCollectionView.showsVerticalScrollIndicator = NO;
    self.channelThumbnailCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.view = [[UIView alloc] initWithFrame:[[SYNDeviceManager sharedInstance] isLandscape] ?
                 CGRectMake(0.0, 0.0, kFullScreenWidthLandscape, kFullScreenHeightLandscapeMinusStatusBar) :
                 CGRectMake(0.0f, 0.0f, kFullScreenWidthPortrait, kFullScreenHeightPortraitMinusStatusBar)];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.channelThumbnailCollectionView];
    
    startAnimationDelay = 0.0;
    
    currentCategoryId = @"all";
    
    currentRange = NSMakeRange(0, 50);
    
    // Google Analytics support
    self.trackedViewName = @"Channels - Root";
    
    
    
    
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.mainRegistry = appDelegate.mainRegistry;
    
    // Register Cells
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNChannelThumbnailCell"
                                             bundle: nil];
    
    [self.channelThumbnailCollectionView registerNib: thumbnailCellNib
                          forCellWithReuseIdentifier: @"SYNChannelThumbnailCell"];
    
    // Register Footer
    UINib *footerViewNib = [UINib nibWithNibName: @"SYNChannelFooterMoreView"
                                          bundle: nil];
    
    [self.channelThumbnailCollectionView registerNib:footerViewNib
                          forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                 withReuseIdentifier:@"SYNChannelFooterMoreView"];
    
    UIPinchGestureRecognizer *pinchOnChannelView = [[UIPinchGestureRecognizer alloc] initWithTarget: self
                                                                                             action: @selector(handlePinchGesture:)];
    
    [self.view addGestureRecognizer: pinchOnChannelView];
    
    __weak SYNChannelsRootViewController *weakSelf = self;
    
    [appDelegate.networkEngine updateChannelsScreenForCategory:currentCategoryId
                                                      forRange:currentRange
                                                  onCompletion:^(NSDictionary* response) {
                                                      
                                                      NSDictionary *channelsDictionary = [response objectForKey: @"channels"];
                                                      if (!channelsDictionary || ![channelsDictionary isKindOfClass: [NSDictionary class]])
                                                          return;
                                                      
                                                      NSNumber *totalNumber = [channelsDictionary objectForKey: @"total"];
                                                      if (![totalNumber isKindOfClass: [NSNumber class]])
                                                          return;
                                                      
                                                      currentTotal = [totalNumber integerValue];
                                                    
                                                      
                                                  
                                                      
                                                      BOOL registryResultOk = [weakSelf.mainRegistry registerNewChannelScreensFromDictionary:response
                                                                                                                             byAppending:NO];
                                                      if (!registryResultOk) {
                                                          DebugLog(@"Registration of Channel Failed for: %@", currentCategoryId);
                                                          return;
                                                      }
        
                                                  } onError:^(NSDictionary* errorInfo) {
        
                                                  }];
    
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    self.touchedChannelButton = NO;
    
    
    
}


- (void) reloadCollectionViews
{
    // Don't refresh whole collection if we are just updating a value
    if (self.ignoreRefresh == TRUE)
    {
        self.ignoreRefresh = FALSE;
    }
    else
    {
        [self.channelThumbnailCollectionView reloadData];
    }
}


#pragma mark - Fetched Results Controller

- (NSFetchedResultsController *) fetchedResultsController
{
    if (fetchedResultsController)
        return fetchedResultsController;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    fetchRequest.entity = [NSEntityDescription entityForName: @"Channel"
                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"viewId == \"%@\"", viewId]];
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"position" ascending: YES]];
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                        managedObjectContext: appDelegate.mainManagedObjectContext
                                                                          sectionNameKeyPath: nil
                                                                                   cacheName: nil];
    fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    ZAssert([fetchedResultsController performFetch: &error],
            @"Channels FetchedResultsController Failed: %@\n%@", [error localizedDescription], [error userInfo]);
    
    return fetchedResultsController;
}


#pragma mark - CollectionView Delegate

- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return sectionInfo.numberOfObjects;

}

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{

    Channel *channel = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    SYNChannelThumbnailCell *channelThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelThumbnailCell"
                                                                                              forIndexPath: indexPath];
    
    
    
    channelThumbnailCell.channelImageViewImage = channel.coverThumbnailLargeURL;
    [channelThumbnailCell setChannelTitle: channel.title];
    channelThumbnailCell.displayNameLabel.text = [NSString stringWithFormat:@"%@", channel.channelOwner.displayName];
    channelThumbnailCell.viewControllerDelegate = self;
    
//    if(channelThumbnailCell.shouldAnimate)
//    {
//        channelThumbnailCell.alpha = 0.0;
//        [UIView animateWithDuration:0.3 delay:(startAnimationDelay + 0.5) options:UIViewAnimationCurveEaseInOut animations:^{
//            channelThumbnailCell.alpha = 1.0;
//            
//        } completion:^(BOOL finished) {
//            
//        }];
//        startAnimationDelay += 0.08;
//        channelThumbnailCell.shouldAnimate = NO;
//    }
    
    
    
    return channelThumbnailCell;
}

-(void)displayNameButtonPressed:(UIButton*)button
{
    SYNChannelThumbnailCell* parent = (SYNChannelThumbnailCell*)[[button superview] superview];
    
    NSIndexPath* indexPath = [self.channelThumbnailCollectionView indexPathForCell:parent];
    
    Channel *channel = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowUserChannels
                                                        object:self userInfo:@{@"ChannelOwner":channel.channelOwner}];
    
}



- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    
    if(collectionView != self.channelThumbnailCollectionView)
        return nil;
    
    SYNChannelFooterMoreView *channelMoreFooter;
    
    UICollectionReusableView* supplementaryView;
    
    if (kind == UICollectionElementKindSectionHeader)
    {
        // nothing yet
    }
    
    
    if (kind == UICollectionElementKindSectionFooter)
    {
        channelMoreFooter = [self.channelThumbnailCollectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                    withReuseIdentifier:@"SYNChannelFooterMoreView"
                                                                                           forIndexPath:indexPath];
        
        [channelMoreFooter.loadMoreButton addTarget:self
                                             action:@selector(loadMoreChannels:)
                                   forControlEvents:UIControlEventTouchUpInside];
        
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
        
        Channel *channel = [self.fetchedResultsController objectAtIndexPath: indexPath];
        
        SYNChannelDetailViewController *channelVC = [[SYNChannelDetailViewController alloc] initWithChannel: channel];
        
        [self animatedPushViewController: channelVC];
    }
}


// Custom zoom out transition
- (void) transitionToItemAtIndexPath: (NSIndexPath *) indexPath
{
    Channel *channel = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    SYNChannelDetailViewController *channelVC = [[SYNChannelDetailViewController alloc] initWithChannel: channel];
    
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


#pragma mark - Button Actions

-(void)loadMoreChannels:(UIButton*)sender
{
    
    
    NSInteger nextStart = currentRange.location + currentRange.length;
    NSInteger nextSize = (nextStart + STANDARD_LENGTH) > currentTotal ? (currentTotal - nextStart) : STANDARD_LENGTH;
    
    currentRange = NSMakeRange(nextStart, nextSize);
    
    
    [appDelegate.networkEngine updateChannelsScreenForCategory:currentCategoryId
                                                      forRange:currentRange
                                                  onCompletion:^(NSDictionary* response) {
                                                      BOOL registryResultOk = [self.mainRegistry registerNewChannelScreensFromDictionary:response
                                                                                                                             byAppending:YES];
                                                      if (!registryResultOk) {
                                                          DebugLog(@"Registration of Channels Failed");
                                                          return;
                                                      }
                                                      
                                                  } onError:^(NSDictionary* errorInfo) {
                                                      
                                                  }];
}



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
        
        Channel *channel = [self.fetchedResultsController objectAtIndexPath: indexPath];
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
        [self.pinchedView setAsynchronousImageFromURL: [NSURL URLWithString: channel.coverThumbnailLargeURL]
                                     placeHolderImage: nil];
        
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

-(void)handleMainTap:(UITapGestureRecognizer *)recogniser
{
    [super handleMainTap:recogniser];
    
    if(!recogniser) {
        // then home button was pressed
        
        if(tabExpanded) {
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
                CGPoint currentCenter = self.channelThumbnailCollectionView.center;
                [self.channelThumbnailCollectionView setCenter:CGPointMake(currentCenter.x, currentCenter.y - kCategorySecondRowHeight)];
            }  completion:^(BOOL result) {
                tabExpanded = NO;
            }];
        }
        
        
        return;
        
    }
    
    if(tabExpanded)
        return;
    
    tabExpanded = YES;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
        CGPoint currentCenter = self.channelThumbnailCollectionView.center;
        [self.channelThumbnailCollectionView setCenter:CGPointMake(currentCenter.x, currentCenter.y + kCategorySecondRowHeight)];
    }  completion:^(BOOL result) {
        tabExpanded = YES;
    }];
}


-(void)handleNewTabSelectionWithId:(NSString *)selectionId
{
    currentCategoryId = selectionId;
    currentRange = NSMakeRange(0, 50);
    [appDelegate.networkEngine updateChannelsScreenForCategory:currentCategoryId
                                                      forRange:currentRange
                                                  onCompletion:^(NSDictionary* response) {
                                                      
                                                      

                                                      BOOL registryResultOk = [self.mainRegistry registerNewChannelScreensFromDictionary:response
                                                                                                                             byAppending:NO];
                                                      
                                                      
                                                      if (!registryResultOk) {
                                                          DebugLog(@"Registration of Channel Failed");
                                                          return;
                                                      }
                                                      
                                                  } onError:^(NSDictionary* errorInfo) {
                                                      
                                                  }];
}

@end
