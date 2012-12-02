//
//  SYNChannelsTopTabViewController.m
//  rockpack
//
//  Created by Nick Banks on 01/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

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

@property (nonatomic, assign) BOOL userPinchedIn;
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

    return self.channelsDB.numberOfThumbnails;

}

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) cv
{
    return 1;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{

    SYNChannelThumbnailCell *cell = [cv dequeueReusableCellWithReuseIdentifier: @"ChannelThumbnailCell"
                                                                  forIndexPath: indexPath];
    
    cell.imageView.image = [self.channelsDB thumbnailForIndex: indexPath.row
                                                   withOffset: self.currentOffset];
    
    cell.maintitle.text = [self.channelsDB titleForIndex: indexPath.row
                                              withOffset: self.currentOffset];
    
    cell.subtitle.text = [self.channelsDB subtitleForIndex: indexPath.row
                                                withOffset: self.currentOffset];
    
    cell.packItNumber.text = [NSString stringWithFormat: @"%d", [self.channelsDB packItNumberForIndex: indexPath.row
                                                                                           withOffset: self.currentOffset]];
    
    cell.rockItNumber.text = [NSString stringWithFormat: @"%d", [self.channelsDB rockItNumberForIndex: indexPath.row
                                                                                           withOffset: self.currentOffset]];
    cell.packItButton.selected = ([self.channelsDB packItForIndex: indexPath.row
                                                       withOffset: self.currentOffset]) ? TRUE : FALSE;
    
    cell.rockItButton.selected = ([self.channelsDB rockItForIndex: indexPath.row
                                                       withOffset: self.currentOffset]) ? TRUE : FALSE;
    
    // Wire the Done button up to the correct method in the sign up controller
    [cell.packItButton removeTarget: nil
                             action: @selector(toggleThumbnailPackItButton:)
                   forControlEvents: UIControlEventTouchUpInside];
    
    [cell.packItButton addTarget: self
                          action: @selector(toggleThumbnailPackItButton:)
                forControlEvents: UIControlEventTouchUpInside];
    
    [cell.rockItButton removeTarget: nil
                             action: @selector(toggleThumbnailRockItButton:)
                   forControlEvents: UIControlEventTouchUpInside];
    
    [cell.rockItButton addTarget: self
                          action: @selector(toggleThumbnailRockItButton:)
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


- (void) transitionToItemAtIndexPath: (NSIndexPath *) indexPath
{
    self.fullTitle.text = [NSString stringWithFormat: @"%@ - %@", [self.channelsDB titleForIndex: indexPath.row withOffset: self.currentOffset], [self.channelsDB subtitleForIndex: indexPath.row withOffset: self.currentOffset]];
    
    self.wallpaper.image = [self.channelsDB wallpaperForIndex: indexPath.row
                                                   withOffset: self.currentOffset];
    
    self.biogTitle.text = [self.channelsDB titleForIndex: indexPath.row
                                              withOffset: self.currentOffset];
    
    self.biogBody.text = [NSString stringWithFormat: @"%@\n\n\n", [self.channelsDB biogForIndex: indexPath.row
                                                                                     withOffset: self.currentOffset]];
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         // Contract thumbnail view
         self.drillDownView.alpha = 1.0f;
         self.channelThumbnailCollection.alpha = 0.0f;
         self.topTabView.alpha = 0.0f;
         self.topTabHighlightedView.alpha = 0.0f;
         self.pinchedView.alpha = 0.0f;
         self.pinchedView.transform = CGAffineTransformMakeScale(10.0f, 10.0f);
         self.pinchedView.alpha = 0.0f;
         
     }
                     completion: ^(BOOL finished)
     {
         [self.pinchedView removeFromSuperview];
         self.topLevel = FALSE;
     }];
}


// Buttons activated from scrolling list of thumbnails

- (IBAction) toggleThumbnailRockItButton: (UIButton *) rockItButton
{
    // Get to cell it self (from button subview)
    UIView *v = rockItButton.superview.superview;
    NSIndexPath *indexPath = [self.channelThumbnailCollection indexPathForItemAtPoint: v.center];
    
    if (!indexPath)
    {
        return;
    }
    
    int number = [self.channelsDB rockItNumberForIndex: indexPath.row
                                            withOffset: self.currentOffset];
    
    BOOL isTrue = [self.channelsDB rockItForIndex: indexPath.row
                                       withOffset: self.currentOffset];
    
    if (isTrue)
    {
        number--;
        
        [self.channelsDB setRockIt: FALSE
                          forIndex: indexPath.row
                        withOffset: self.currentOffset];
    }
    else
    {
        number++;
        
        [self.channelsDB setRockIt: TRUE
                          forIndex: indexPath.row
                        withOffset: self.currentOffset];
    }
    
    [self.channelsDB setRockItNumber: number
                            forIndex: indexPath.row
                          withOffset: self.currentOffset];
    
    SYNChannelThumbnailCell *cell = (SYNChannelThumbnailCell *)[self.channelThumbnailCollection cellForItemAtIndexPath: indexPath];
    
    cell.rockItButton.selected = ([self.channelsDB rockItForIndex: indexPath.row
                                                       withOffset: self.currentOffset]) ? TRUE : FALSE;
    
    cell.rockItNumber.text = [NSString stringWithFormat: @"%d", [self.channelsDB rockItNumberForIndex: indexPath.row
                                                                                           withOffset: self.currentOffset]];
}

- (IBAction) toggleThumbnailPackItButton: (UIButton *) packItButton
{
    UIView *v = packItButton.superview.superview;
    NSIndexPath *indexPath = [self.channelThumbnailCollection indexPathForItemAtPoint: v.center];
    
    int number = [self.channelsDB packItNumberForIndex: indexPath.row
                                            withOffset: self.currentOffset];
    
    BOOL isTrue = [self.channelsDB packItForIndex: indexPath.row
                                       withOffset: self.currentOffset];
    
    if (isTrue)
    {
        number--;
        
        [self.channelsDB setPackIt: FALSE
                          forIndex: indexPath.row
                        withOffset: self.currentOffset];
    }
    else
    {
        number++;
        
        [self.channelsDB setPackIt: TRUE
                          forIndex: indexPath.row
                        withOffset: self.currentOffset];
    }
    
    [self.channelsDB setPackItNumber: number
                            forIndex: indexPath.row
                          withOffset: self.currentOffset];
    
    SYNChannelThumbnailCell *cell = (SYNChannelThumbnailCell *)[self.channelThumbnailCollection cellForItemAtIndexPath: indexPath];
    
    cell.packItButton.selected = ([self.channelsDB packItForIndex: indexPath.row
                                                       withOffset: self.currentOffset]) ? TRUE : FALSE;
    
    cell.packItNumber.text = [NSString stringWithFormat: @"%d", [self.channelsDB packItNumberForIndex: indexPath.row
                                                                                           withOffset: self.currentOffset]];
}


- (void) handlePinchGesture: (UIPinchGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        // At this stage, we don't know whether the user is pinching in or out
        self.userPinchedIn = FALSE;
        
        NSLog (@"UIGestureRecognizerStateBegan");
        // figure out which item in the table was selected
        NSIndexPath *indexPath = [self.channelThumbnailCollection indexPathForItemAtPoint: [sender locationInView: self.channelThumbnailCollection]];
        
        if (!indexPath)
        {
            return;
        }
        
        if (self.isTopLevel == TRUE)
        {
            self.pinchedIndexPath = indexPath;
            
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
            UIImage *cellImage = [self.channelsDB thumbnailForIndex: indexPath.row
                                                         withOffset: self.currentOffset];
            
            self.pinchedView = [[UIImageView alloc] initWithFrame: imageViewFrame];
            self.pinchedView.alpha = 0.7f;
            self.pinchedView.image = cellImage;
            
            // now add the item to the view
            [self.view addSubview: self.pinchedView];
        }
    }
    else if (sender.state == UIGestureRecognizerStateChanged)
    {
        NSLog (@"UIGestureRecognizerStateChanged");
        float scale = sender.scale;
        
        if (self.isTopLevel == TRUE)
        {
            if (scale < 1.0)
            {
                return;
            }
            else
            {
                // we zoomed it, so let's update the coordinates of the dragged view
                self.pinchedView.transform = CGAffineTransformMakeScale(scale, scale);
            }
        }
        else
        {
            if (scale < 1.0)
            {
                if (self.userPinchedIn == FALSE)
                {
                    self.userPinchedIn = TRUE;
                    [self transitionBackToTopLevel];
                }
            }
        }
    }
    else if (sender.state == UIGestureRecognizerStateEnded)
    {
        NSLog (@"UIGestureRecognizerStateEnded");
        if (self.isTopLevel == TRUE && self.userPinchedIn == FALSE)
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
