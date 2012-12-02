//
//  SYNChannelsTopTabViewController.m
//  rockpack
//
//  Created by Nick Banks on 01/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "Channel.h"
#import "MBProgressHUD.h"
#import "SYNChannelThumbnailCell.h"
#import "SYNChannelsChannelViewController.h"
#import "SYNChannelsDB.h"
#import "SYNChannelsTopTabViewController.h"
#import "SYNMyRockpackCell.h"
#import "SYNVideoDB.h"
#import "UIFont+SYNFont.h"
#import "Video.h"

@interface SYNChannelsTopTabViewController ()

@property (nonatomic, assign) BOOL userPinchedOut;
@property (nonatomic, strong) IBOutlet UICollectionView *channelThumbnailCollection;
@property (nonatomic, strong) NSIndexPath *pinchedIndexPath;
@property (nonatomic, strong) UIImageView *pinchedView;

@end

@implementation SYNChannelsTopTabViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Init collection view
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNChannelThumbnailCell"
                                             bundle: nil];
    
    [self.channelThumbnailCollection registerNib: thumbnailCellNib
                      forCellWithReuseIdentifier: @"ChannelThumbnailCell"];

    UIPinchGestureRecognizer *pinchOnChannelView = [[UIPinchGestureRecognizer alloc] initWithTarget: self
                                                                                             action: @selector(handlePinchGesture:)];
    
    [self.view addGestureRecognizer: pinchOnChannelView];
}

#pragma mark - Collection view support

- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.channelFetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];

}

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) cv
{
    return 1;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{

    Channel *channel = [self.channelFetchedResultsController objectAtIndexPath: indexPath];
    
    SYNChannelThumbnailCell *cell = [cv dequeueReusableCellWithReuseIdentifier: @"ChannelThumbnailCell"
                                                                  forIndexPath: indexPath];
    
    cell.imageView.image = channel.keyframeImage;
    
    cell.maintitle.text = channel.title;
    
    cell.subtitle.text = channel.subtitle;
    
    cell.packItNumber.text = [NSString stringWithFormat: @"%@", channel.totalPacks];
    
    cell.rockItNumber.text = [NSString stringWithFormat: @"%@", channel.totalRocks];
    
    cell.packItButton.selected = channel.packedByUserValue;
    
    cell.rockItButton.selected = channel.rockedByUserValue;
    
    // Wire the Done button up to the correct method in the sign up controller
    [cell.packItButton removeTarget: nil
                             action: @selector(toggleChannelThumbnailPackItButton:)
                   forControlEvents: UIControlEventTouchUpInside];
    
    [cell.packItButton addTarget: self
                          action: @selector(toggleTChannelhumbnailPackItButton:)
                forControlEvents: UIControlEventTouchUpInside];
    
    [cell.rockItButton removeTarget: nil
                             action: @selector(toggleChannelThumbnailRockItButton:)
                   forControlEvents: UIControlEventTouchUpInside];
    
    [cell.rockItButton addTarget: self
                          action: @selector(toggleChannelThumbnailRockItButton:)
                forControlEvents: UIControlEventTouchUpInside];
    
    return cell;

}


- (void) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    Channel *channel = [self.channelFetchedResultsController objectAtIndexPath: indexPath];
    
    SYNChannelsChannelViewController *channelVC = [[SYNChannelsChannelViewController alloc] initWithChannel: channel];
    
    [self animatedPushViewController: channelVC];
}


// Custom zoom out transition
- (void) transitionToItemAtIndexPath: (NSIndexPath *) indexPath
{
    Channel *channel = [self.channelFetchedResultsController objectAtIndexPath: indexPath];
    
    SYNChannelsChannelViewController *channelVC = [[SYNChannelsChannelViewController alloc] initWithChannel: channel];
    
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
- (void) toggleChannelRockItAtIndex: (NSIndexPath *) indexPath
{
    Channel *channel = [self.channelFetchedResultsController objectAtIndexPath: indexPath];
    
    if (channel.rockedByUserValue == TRUE)
    {
        // Currently highlighted, so decrement
        channel.rockedByUserValue = FALSE;
        channel.totalRocksValue -= 1;
    }
    else
    {
        // Currently highlighted, so increment
        channel.rockedByUserValue = TRUE;
        channel.totalRocksValue += 1;
    }
    
    [self saveDB];
}


- (void) toggleChannelPackItAtIndex: (NSIndexPath *) indexPath
{
    Channel *channel = [self.channelFetchedResultsController objectAtIndexPath: indexPath];
    
    if (channel.packedByUserValue == TRUE)
    {
        // Currently highlighted, so decrement
        channel.packedByUserValue = FALSE;
        channel.totalPacksValue -= 1;
    }
    else
    {
        // Currently highlighted, so increment
        channel.packedByUserValue = TRUE;
        channel.totalPacksValue += 1;
    }
    
    [self saveDB];
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
    cell.rockItNumber.text = [NSString stringWithFormat: @"%@", channel.totalRocks];
}

- (IBAction) toggleChannelPackItButton: (UIButton *) packItButton
{
    UIView *v = packItButton.superview.superview;
    NSIndexPath *indexPath = [self.channelThumbnailCollection indexPathForItemAtPoint: v.center];
    
    // Bail if we don't have an index path
    if (!indexPath)
    {
        return;
    }
    
    [self toggleChannelPackItAtIndex: indexPath];
    
    // We don't need to update the UI as this cell can only be deselected
    // (Otherwise a race-condition will occur if deleting the last cell)
    Channel *channel = [self.channelFetchedResultsController objectAtIndexPath: indexPath];
    SYNChannelThumbnailCell *cell = (SYNChannelThumbnailCell *)[self.channelThumbnailCollection cellForItemAtIndexPath: indexPath];
    
    cell.packItButton.selected = channel.packedByUserValue;
    cell.packItNumber.text = [NSString stringWithFormat: @"%@", channel.totalPacks];
}

- (void) handlePinchGesture: (UIPinchGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        // At this stage, we don't know whether the user is pinching in or out
        self.userPinchedOut = FALSE;
        
        NSLog (@"UIGestureRecognizerStateBegan");
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
        UIImage *cellImage = channel.keyframeImage;
        
        self.pinchedView = [[UIImageView alloc] initWithFrame: imageViewFrame];
        self.pinchedView.alpha = 0.7f;
        self.pinchedView.image = cellImage;
        
        // now add the item to the view
        [self.view addSubview: self.pinchedView];
    }
    else if (sender.state == UIGestureRecognizerStateChanged)
    {
        NSLog (@"UIGestureRecognizerStateChanged");
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
        NSLog (@"UIGestureRecognizerStateEnded");
        
        if (self.userPinchedOut == TRUE)
        {
            [self transitionToItemAtIndexPath: self.pinchedIndexPath];
        }
    }
    else if (sender.state == UIGestureRecognizerStateCancelled)
    {
        NSLog (@"UIGestureRecognizerStateCancelled");
        [self.pinchedView removeFromSuperview];
    }
}


#pragma mark - Core Data Support

- (NSPredicate *) channelFetchedResultsControllerPredicate
{
    return [NSPredicate predicateWithFormat: @"userGenerated == FALSE"];
}

- (NSArray *) channelFetchedResultsControllerSortDescriptors
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"title"
                                                                   ascending: YES];
    return @[sortDescriptor];
}



@end
