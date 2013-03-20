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

@interface SYNChannelsRootViewController () <UIScrollViewDelegate>

@property (nonatomic, assign) BOOL userPinchedOut;

@property (nonatomic, strong) NSIndexPath *pinchedIndexPath;
@property (nonatomic, strong) UIImageView *pinchedView;

@end

@implementation SYNChannelsRootViewController

#pragma mark - View lifecycle

- (void) loadView
{
    SYNIntegralCollectionViewFlowLayout* flowLayout = [[SYNIntegralCollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.headerReferenceSize = CGSizeMake(0.0, 0.0);
    flowLayout.footerReferenceSize = CGSizeMake(0.0, 0.0);
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
    

    // Init collection view
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNChannelThumbnailCell"
                                             bundle: nil];
    
    [self.channelThumbnailCollectionView registerNib: thumbnailCellNib
                          forCellWithReuseIdentifier: @"SYNChannelThumbnailCell"];

    UIPinchGestureRecognizer *pinchOnChannelView = [[UIPinchGestureRecognizer alloc] initWithTarget: self
                                                                                             action: @selector(handlePinchGesture:)];
    
    [self.view addGestureRecognizer: pinchOnChannelView];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [appDelegate.networkEngine updateChannelsScreenForCategory:@"all"];
}





- (void) reloadCollectionViews
{
    [self.channelThumbnailCollectionView reloadData];
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
    channelThumbnailCell.displayNameLabel.text = channel.channelOwner.displayName;
    channelThumbnailCell.rockItNumberLabel.text = [NSString stringWithFormat: @"%@", channel.rockCount];
    channelThumbnailCell.rockItButton.selected = channel.rockedByUserValue;
    
    // Wire the Done button up to the correct method in the sign up controller
    [channelThumbnailCell.rockItButton removeTarget: nil
                                             action: @selector(toggleChannelRockItButton:)
                                   forControlEvents: UIControlEventTouchUpInside];
    
    [channelThumbnailCell.rockItButton addTarget: self
                                          action: @selector(toggleChannelRockItButton:)
                                forControlEvents: UIControlEventTouchUpInside];
    
    return channelThumbnailCell;

}


- (void) collectionView: (UICollectionView *) collectionView
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    Channel *channel = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    SYNChannelsDetailViewController *channelVC = [[SYNChannelsDetailViewController alloc] initWithChannel: channel];
    
    [self animatedPushViewController: channelVC];
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
}


// Buttons activated from scrolling list of thumbnails
- (IBAction) toggleChannelRockItButton: (UIButton *) rockItButton
{
    // Get to cell it self (from button subview)
    UIView *v = rockItButton.superview.superview;
    NSIndexPath *indexPath = [self.channelThumbnailCollectionView indexPathForItemAtPoint: v.center];
    
    // Bail if we don't have an index path
    if (!indexPath)
    {
        return;
    }
    
    [self toggleChannelRockItAtIndex: indexPath];
    
    Channel *channel = [self.fetchedResultsController objectAtIndexPath: indexPath];
    SYNChannelThumbnailCell *cell = (SYNChannelThumbnailCell *)[self.channelThumbnailCollectionView cellForItemAtIndexPath: indexPath];
    
    cell.rockItButton.selected = channel.rockedByUserValue;
    cell.rockItNumberLabel.text = [NSString stringWithFormat: @"%@", channel.rockCount];
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
    
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
        CGPoint currentCenter = self.channelThumbnailCollectionView.center;
        [self.channelThumbnailCollectionView setCenter:CGPointMake(currentCenter.x, currentCenter.y + kCategorySecondRowHeight)];
    }  completion:^(BOOL result){
        tabExpanded = YES;
    }];
}

-(void)handleNewTabSelectionWithId:(NSString *)selectionId
{
    [appDelegate.networkEngine updateChannelsScreenForCategory:selectionId];
}

@end
