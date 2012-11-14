//
//  SYNChannelsTopTabViewController.m
//  rockpack
//
//  Created by Nick Banks on 11/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNChannelThumbnailCell.h"
#import "SYNChannelsDB.h"
#import "SYNVideoDB.h"
#import "SYNChannelsTopTabViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNMyRockpackCell.h"

@interface SYNChannelsTopTabViewController ()

@property (nonatomic, assign) int currentIndex;
@property (nonatomic, assign) int currentOffset;
@property (nonatomic, strong) IBOutlet UICollectionView *thumbnailView;
@property (nonatomic, strong) IBOutlet UICollectionView *thumbnailView2;
@property (nonatomic, strong) IBOutlet UILabel *biogBody;
@property (nonatomic, strong) IBOutlet UIImageView *wallpaper;
@property (nonatomic, strong) IBOutlet UILabel *biogTitle;
@property (nonatomic, strong) IBOutlet UILabel *coolFactor;
@property (nonatomic, strong) IBOutlet UILabel *cute;
@property (nonatomic, strong) IBOutlet UILabel *scary;
@property (nonatomic, strong) IBOutlet UILabel *strength;
@property (nonatomic, strong) IBOutlet UILabel *superPowers;
@property (nonatomic, strong) IBOutlet UILabel *wallpackTitle;
@property (nonatomic, strong) IBOutlet UIView *drillDownView;
@property (nonatomic, strong) SYNChannelsDB *channelsDB;
@property (nonatomic, strong) SYNVideoDB *videoDB;

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
    
    UINib *thumbnailCellNib2 = [UINib nibWithNibName: @"SYNMyRockpackCell"
                                             bundle: nil];
    
    [self.thumbnailView2 registerNib: thumbnailCellNib2
         forCellWithReuseIdentifier: @"MyRockpackCell"];
    
    // Cache the channels DB to make the code clearer
    self.channelsDB = [SYNChannelsDB sharedChannelsDBManager];
    self.videoDB = [SYNVideoDB sharedVideoDBManager];
    
    self.biogTitle.font = [UIFont boldRockpackFontOfSize: 24.0f];
    self.biogBody.font = [UIFont rockpackFontOfSize: 17.0f];
    self.coolFactor.font = [UIFont rockpackFontOfSize: 15.0f];
    self.scary.font = [UIFont rockpackFontOfSize: 15.0f];
    self.cute.font = [UIFont rockpackFontOfSize: 15.0f];
    self.strength.font = [UIFont rockpackFontOfSize: 15.0f];
    self.superPowers.font = [UIFont rockpackFontOfSize: 15.0f];
}


#pragma mark - Collection view support

- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    if (view == self.thumbnailView)
    {
        return self.channelsDB.numberOfThumbnails;
    }
    else
    {
        return self.channelsDB.numberOfThumbnails;
    }
}

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) cv
{
    return 1;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (cv == self.thumbnailView)
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
    else
    {
        SYNMyRockpackCell *cell = [cv dequeueReusableCellWithReuseIdentifier: @"MyRockpackCell"
                                                                forIndexPath: indexPath];
        
        UIImage *image = [self.videoDB thumbnailForIndex: indexPath.row
                                              withOffset: self.currentOffset];
        cell.imageView.image = image;
        
        //    NSString *imageName = [NSString stringWithFormat: @"Wallpack_%d.png", selection.index];
        //    UIImage *image = [UIImage imageNamed: imageName];
        //    cell.imageView.image = image;
        
        return cell;
    }
}


- (void) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (cv == self.thumbnailView)
    {
        self.wallpaper.image = [self.channelsDB wallpaperForIndex: indexPath.row
                                                       withOffset: self.currentOffset];
        
        self.biogTitle.text = [self.channelsDB titleForIndex: indexPath.row
                                                  withOffset: self.currentOffset];
        
        self.biogBody.text = [self.channelsDB biogForIndex: indexPath.row
                                                    withOffset: self.currentOffset];
        [UIView animateWithDuration: 0.5f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^
         {
             // Contract thumbnail view
             self.drillDownView.alpha = 1.0f;
             self.thumbnailView.alpha = 0.0f;
             self.topTabView.alpha = 0.0f;
             
         }
                         completion: ^(BOOL finished)
         {
         }];
    }
    else
    {
        
    }
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

- (IBAction) userTouchedBackButton: (id) sender
{
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         // Contract thumbnail view
         self.drillDownView.alpha = 0.0f;
         self.thumbnailView.alpha = 1.0f;
         self.topTabView.alpha = 1.0f;
         
     }
                     completion: ^(BOOL finished)
     {
     }];
}


@end
