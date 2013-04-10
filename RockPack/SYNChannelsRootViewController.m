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
#import "SYNChannelsDetailViewController.h"
#import "SYNChannelsRootViewController.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNNetworkEngine.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+ImageProcessing.h"
#import "Video.h"
#import "SYNChannelFooterMoreView.h"
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

#pragma mark - View lifecycle

-(id)initWithViewId:(NSString *)vid
{
    if(self = [super initWithViewId:vid])
    {
        self.title = @"Channels";
    }
    return self;
}

- (void) loadView
{
    SYNIntegralCollectionViewFlowLayout* flowLayout = [[SYNIntegralCollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.headerReferenceSize = CGSizeMake(0.0, 0.0);
    flowLayout.footerReferenceSize = CGSizeMake(1024.0, 64.0);
    flowLayout.itemSize = CGSizeMake(251.0, 302.0);
    flowLayout.sectionInset = UIEdgeInsetsMake(10.0, 3.0, 5.0, 3.0);
    flowLayout.minimumLineSpacing = 3.0;
    flowLayout.minimumInteritemSpacing = 0.0;
    
    CGRect collectionViewFrame = CGRectMake(0.0, 86.0, 1024.0, 600.0);
    
    self.channelThumbnailCollectionView = [[UICollectionView alloc] initWithFrame: collectionViewFrame
                                                             collectionViewLayout: flowLayout];
    self.channelThumbnailCollectionView.dataSource = self;
    self.channelThumbnailCollectionView.delegate = self;
    self.channelThumbnailCollectionView.backgroundColor = [UIColor clearColor];
    
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1024.0, 748.0)];
    
    [self.view addSubview:self.channelThumbnailCollectionView];
    
    
    currentCategoryId = @"all";
}


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
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                               managedObjectContext: appDelegate.mainManagedObjectContext
                                                                                 sectionNameKeyPath: nil
                                                                                          cacheName: nil];
    fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    ZAssert([fetchedResultsController performFetch: &error], @"Channels FetchedResultsController Failed: %@\n%@", [error localizedDescription], [error userInfo]);
    
    return fetchedResultsController;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    currentRange = NSMakeRange(0, 50);
    

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
    
    self.mainRegistry = appDelegate.mainRegistry;
    
    
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
                                                      
                                                      
                                                      BOOL registryResultOk = [self.mainRegistry registerNewChannelScreensFromDictionary:response
                                                                                                                         byAppending:NO];
                                                      if (!registryResultOk) {
                                                          DebugLog(@"Update Channel Screens Request Failed");
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
    channelThumbnailCell.titleLabel.text = channel.title;
    channelThumbnailCell.displayNameLabel.text = [NSString stringWithFormat:@"BY %@", channel.channelOwner.displayName];
    channelThumbnailCell.subscribersNumberLabel.text = [NSString stringWithFormat: @"%@", channel.subscribersCount];
    channelThumbnailCell.subscribeButton.selected = channel.subscribedByUserValue;
    channelThumbnailCell.viewControllerDelegate = self;
    
    
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
        
        SYNChannelsDetailViewController *channelVC = [[SYNChannelsDetailViewController alloc] initWithChannel: channel];
        
        [self animatedPushViewController: channelVC];
    }
}


// Custom zoom out transition
- (void) transitionToItemAtIndexPath: (NSIndexPath *) indexPath
{
    Channel *channel = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    SYNChannelsDetailViewController *channelVC = [[SYNChannelsDetailViewController alloc] initWithChannel: channel];
    
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
                                                          DebugLog(@"Update Channel Screens Request Failed");
                                                          return;
                                                      }
                                                      
                                                  } onError:^(NSDictionary* errorInfo) {
                                                      
                                                  }];
}


// Buttons activated from scrolling list of thumbnails
- (IBAction) toggleChannelSubscribeButton: (UIButton *) subscribeButton
{
    // Get to cell it self (from button subview)
    UIView *v = subscribeButton.superview.superview;
    NSIndexPath *indexPath = [self.channelThumbnailCollectionView indexPathForItemAtPoint: v.center];
    
    // Bail if we don't have an index path
    if (!indexPath)
    {
        return;
    }
    
    // Prevent any changes refreshing the whole collection
    self.ignoreRefresh = TRUE;

    [self toggleChannelSubscribeAtIndex: indexPath];
    
    Channel *channel = [self.fetchedResultsController objectAtIndexPath: indexPath];
    SYNChannelThumbnailCell *cell = (SYNChannelThumbnailCell *)[self.channelThumbnailCollectionView cellForItemAtIndexPath: indexPath];
    
    cell.subscribeButton.selected = channel.subscribedByUserValue;
    cell.subscribersNumberLabel.text = [NSString stringWithFormat: @"%@", channel.subscribersCount];
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
        
        // Now create a new UIImageView to overlay
//        UIImage *cellImage = channel.thumbnailImage;
        
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
    
    if(tabExpanded)
        return;
    
    tabExpanded = YES;
    
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
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
                                                          DebugLog(@"Update Channel Screens Request Failed");
                                                          return;
                                                      }
                                                      
                                                  } onError:^(NSDictionary* errorInfo) {
                                                      
                                                  }];
}

@end
