//
//  SYNChannelsTopTabViewController.m
//  rockpack
//
//  Created by Nick Banks on 11/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNChannelThumbnailCell.h"
#import "SYNChannelsDB.h"
#import "SYNChannelsTopTabViewController.h"
#import "UIFont+SYNFont.h"

@interface SYNChannelsTopTabViewController ()

@property (nonatomic, assign) int currentIndex;
@property (nonatomic, assign) int currentOffset;
@property (nonatomic, strong) IBOutlet UICollectionView *thumbnailView;
@property (nonatomic, strong) SYNChannelsDB *channelsDB;

@end

@implementation SYNChannelsTopTabViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Init collection view
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNChannelThumbnailCell"
                                             bundle: nil];
    
    [self.thumbnailView registerNib: thumbnailCellNib
         forCellWithReuseIdentifier: @"ChannelThumbnailCell"];
    
    // Cache the channels DB to make the code clearer
    self.channelsDB = [SYNChannelsDB sharedChannelsDBManager];
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
#ifdef FULL_SCREEN_THUMBNAILS
    if (self.isLargeVideoViewExpanded == FALSE)
    {
        [self animateLargeVideoViewRight: nil];
        self.largeVideoViewExpanded = TRUE;
    }
#endif
    self.currentIndex = indexPath.row;
    
//    [self setLargeVideoIndex: self.currentIndex
//                  withOffset: self.currentOffset];
}

// Buttons activated from scrolling list of thumbnails

- (IBAction) toggleThumbnailRockItButton: (UIButton *) rockItButton
{
    // Get to cell it self (from button subview)
    UIView *v = rockItButton.superview.superview;
    NSIndexPath *indexPath = [self.thumbnailView indexPathForItemAtPoint: v.center];
    
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
    
    SYNChannelThumbnailCell *cell = (SYNChannelThumbnailCell *)[self.thumbnailView cellForItemAtIndexPath: indexPath];
    
    cell.rockItButton.selected = ([self.channelsDB rockItForIndex: indexPath.row
                                                    withOffset: self.currentOffset]) ? TRUE : FALSE;
    
    cell.rockItNumber.text = [NSString stringWithFormat: @"%d", [self.channelsDB rockItNumberForIndex: indexPath.row
                                                                                        withOffset: self.currentOffset]];
}

- (IBAction) toggleThumbnailPackItButton: (UIButton *) packItButton
{
    UIView *v = packItButton.superview.superview;
    NSIndexPath *indexPath = [self.thumbnailView indexPathForItemAtPoint: v.center];
    
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
    
    SYNChannelThumbnailCell *cell = (SYNChannelThumbnailCell *)[self.thumbnailView cellForItemAtIndexPath: indexPath];
    
    cell.packItButton.selected = ([self.channelsDB packItForIndex: indexPath.row
                                                    withOffset: self.currentOffset]) ? TRUE : FALSE;
    
    cell.packItNumber.text = [NSString stringWithFormat: @"%d", [self.channelsDB packItNumberForIndex: indexPath.row
                                                                                        withOffset: self.currentOffset]];
}


@end
