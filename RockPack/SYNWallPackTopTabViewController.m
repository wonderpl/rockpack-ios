//
//  SYNWallPackTopTabViewController.m
//  rockpack
//
//  Created by Nick Banks on 12/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNWallPackTopTabViewController.h"
#import "SYNWallpackThumbnailCell.h"
#import "SYNWallpacksDB.h"
#import "UIFont+SYNFont.h"

@interface SYNWallPackTopTabViewController ()

@property (nonatomic, assign) int currentIndex;
@property (nonatomic, assign) int currentOffset;
@property (nonatomic, strong) IBOutlet UICollectionView *thumbnailView;
@property (nonatomic, strong) SYNWallpacksDB *wallpacksDB;

@end

@implementation SYNWallPackTopTabViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Init collection view
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNWallpackThumbnailCell"
                                             bundle: nil];
    
    [self.thumbnailView registerNib: thumbnailCellNib
         forCellWithReuseIdentifier: @"ChannelWallpackCell"];
    
    // Cache the channels DB to make the code clearer
    self.wallpacksDB = [SYNWallpacksDB sharedWallpacksDBManager];

}


#pragma mark - Collection view support

- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    return self.wallpacksDB.numberOfThumbnails;
}

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) cv
{
    return 1;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNWallpackThumbnailCell *cell = [cv dequeueReusableCellWithReuseIdentifier: @"ChannelWallpackCell"
                                                                  forIndexPath: indexPath];
    
    cell.imageView.image = [self.wallpacksDB thumbnailForIndex: indexPath.row
                                                   withOffset: self.currentOffset];
    
    cell.title.text = [self.wallpacksDB titleForIndex: indexPath.row
                                              withOffset: self.currentOffset];
    
    cell.price.text = [self.wallpacksDB priceForIndex: indexPath.row
                                          withOffset: self.currentOffset];
    
    // Wire the Done button up to the correct method in the sign up controller
    
    return cell;
}


- (void) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    self.currentIndex = indexPath.row;
}

@end
