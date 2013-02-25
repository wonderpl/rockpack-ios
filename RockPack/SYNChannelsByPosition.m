//
//  SYNChannelsByPosition.m
//  rockpack
//
//  Created by Michael Michailidis on 25/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNChannelsByPosition.h"
#import "Channel.h"
#import "SYNChannelThumbnailCell.h"
#import "ChannelOwner.h"

@implementation SYNChannelsByPosition

-(NSString*)dataType;
{
    return kDataProxyTypeChannel;
}


#pragma mark - UICollectionViewDelegate

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    Channel *channel = [fetchedRequestController objectAtIndexPath:indexPath];
    
    SYNChannelThumbnailCell *channelThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelThumbnailCell"
                                                                                              forIndexPath: indexPath];
    
    channelThumbnailCell.channelImageViewImage = channel.coverThumbnailLargeURL;
    channelThumbnailCell.titleLabel.text = channel.title;
    channelThumbnailCell.userNameLabel.text = channel.channelOwner.name;
    channelThumbnailCell.rockItNumberLabel.text = [NSString stringWithFormat: @"%@", channel.rockCount];
    channelThumbnailCell.rockItButton.selected = channel.rockedByUserValue;
    
    // Wire the Done button up to the correct method in the sign up controller
    // TODO: Add notification for Rock it button
//    [channelThumbnailCell.rockItButton removeTarget: nil
//                                             action: @selector(toggleChannelRockItButton:)
//                                   forControlEvents: UIControlEventTouchUpInside];
//    
//    [channelThumbnailCell.rockItButton addTarget: self
//                                          action: @selector(toggleChannelRockItButton:)
//                                forControlEvents: UIControlEventTouchUpInside];
    
    return channelThumbnailCell;
    
}

@end
