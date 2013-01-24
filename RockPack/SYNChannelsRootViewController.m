//
//  SYNChannelsTopTabViewController.m
//  rockpack
//
//  Created by Nick Banks on 01/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "Channel.h"
#import "ChannelOwner.h"
#import "MBProgressHUD.h"
#import "SYNChannelThumbnailCell.h"
#import "SYNChannelsDetailViewController.h"
#import "SYNChannelsRootViewController.h"
#import "SYNMyRockpackCell.h"
#import "SYNVideoDB.h"
#import "UIFont+SYNFont.h"
#import "Video.h"

@interface SYNChannelsRootViewController () <UICollectionViewDelegate,
                                               UICollectionViewDataSource,
                                               UIScrollViewDelegate>

@property (nonatomic, assign) BOOL userPinchedOut;
@property (nonatomic, strong) IBOutlet UICollectionView *channelThumbnailCollection;
@property (nonatomic, strong) NSIndexPath *pinchedIndexPath;
@property (nonatomic, strong) UIImageView *pinchedView;

@end

@implementation SYNChannelsRootViewController

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];

    // Init collection view
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNChannelThumbnailCell"
                                             bundle: nil];
    
    [self.channelThumbnailCollection registerNib: thumbnailCellNib
                      forCellWithReuseIdentifier: @"SYNChannelThumbnailCell"];

    UIPinchGestureRecognizer *pinchOnChannelView = [[UIPinchGestureRecognizer alloc] initWithTarget: self
                                                                                             action: @selector(handlePinchGesture:)];
    
    [self.view addGestureRecognizer: pinchOnChannelView];
}


#pragma mark - Core Data Support

- (NSPredicate *) channelFetchedResultsControllerPredicate
{
    return [NSPredicate predicateWithFormat: @"viewId == \"Channels\""];
}

- (NSArray *) channelFetchedResultsControllerSortDescriptors
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"title"
                                                                   ascending: YES];
    return @[sortDescriptor];
}


#pragma mark - Collection view support

- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.channelFetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];

}

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{

    Channel *channel = [self.channelFetchedResultsController objectAtIndexPath: indexPath];
    
    SYNChannelThumbnailCell *channelThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelThumbnailCell"
                                                                                              forIndexPath: indexPath];
    
    channelThumbnailCell.channelImageViewImage = channel.thumbnailURL;
    
    channelThumbnailCell.titleLabel.text = channel.title;
    
    channelThumbnailCell.userNameLabel.text = channel.channelOwner.name;
    
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
    Channel *channel = [self.channelFetchedResultsController objectAtIndexPath: indexPath];
    
    SYNChannelsDetailViewController *channelVC = [[SYNChannelsDetailViewController alloc] initWithChannel: channel];
    
    [self animatedPushViewController: channelVC];
}


// Custom zoom out transition
- (void) transitionToItemAtIndexPath: (NSIndexPath *) indexPath
{
    Channel *channel = [self.channelFetchedResultsController objectAtIndexPath: indexPath];
    
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
         self.topTabView.alpha = 0.0f;
         self.topTabHighlightedView.alpha = 0.0f;
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
    NSIndexPath *indexPath = [self.channelThumbnailCollection indexPathForItemAtPoint: v.center];
    
    // Bail if we don't have an index path
    if (!indexPath)
    {
        return;
    }
    
    [self toggleChannelRockItAtIndex: indexPath];
    
    Channel *channel = [self.channelFetchedResultsController objectAtIndexPath: indexPath];
    SYNChannelThumbnailCell *cell = (SYNChannelThumbnailCell *)[self.channelThumbnailCollection cellForItemAtIndexPath: indexPath];
    
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
        NSIndexPath *indexPath = [self.channelThumbnailCollection indexPathForItemAtPoint: [sender locationInView: self.channelThumbnailCollection]];
        
        if (!indexPath)
        {
            return;
        }
        
        self.pinchedIndexPath = indexPath;
        
        Channel *channel = [self.channelFetchedResultsController objectAtIndexPath: indexPath];
        SYNChannelThumbnailCell *channelCell = (SYNChannelThumbnailCell *)[self.channelThumbnailCollection cellForItemAtIndexPath: indexPath];
        
        // Get the various frames we need to calculate the actual position
        CGRect imageViewFrame = channelCell.imageView.frame;
        CGRect viewFrame = channelCell.superview.frame;
        CGRect cellFrame = channelCell.frame;
        
        CGPoint offset = self.channelThumbnailCollection.contentOffset;
        
        // Now add them together to get the real pos in the top view
        imageViewFrame.origin.x += cellFrame.origin.x + viewFrame.origin.x - offset.x;
        imageViewFrame.origin.y += cellFrame.origin.y + viewFrame.origin.y - offset.y;
        
        // Now create a new UIImageView to overlay
        UIImage *cellImage = channel.thumbnailImage;
        
        self.pinchedView = [[UIImageView alloc] initWithFrame: imageViewFrame];
        self.pinchedView.alpha = 0.7f;
        self.pinchedView.image = cellImage;
        
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

@end
