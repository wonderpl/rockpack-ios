//
//  SYNSubscriptionsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 17/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSubscriptionsViewController.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "AppConstants.h"
#import "SYNChannelMidCell.h"
#import "Channel.h"

@interface SYNSubscriptionsViewController ()


@end


@implementation SYNSubscriptionsViewController

@synthesize user = _user;

- (void) loadView
{
    [super loadView];
    
    self.channelThumbnailCollectionView.backgroundColor = [UIColor clearColor];
    self.channelThumbnailCollectionView.showsVerticalScrollIndicator = NO;
}


- (CGSize) itemSize
{
    return CGSizeMake(184.0, 184.0);
}


- (CGSize) footerSize
{
    return CGSizeMake(0.0, 0.0);
}


- (void) viewDidLoad
{
    // FIXME: Why no call to super, is this a mistake?
    //[super viewDidLoad];
    
    appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
    
    // Register Footer
    UINib *footerViewNib = [UINib nibWithNibName: @"SYNChannelFooterMoreView"
                                          bundle: nil];
    
    [self.channelThumbnailCollectionView registerNib: footerViewNib
                          forSupplementaryViewOfKind: UICollectionElementKindSectionFooter
                                 withReuseIdentifier: @"SYNChannelFooterMoreView"];
    
    // Register Cells
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNChannelMidCell"
                                             bundle: nil];
    
    [self.channelThumbnailCollectionView registerNib: thumbnailCellNib
                          forCellWithReuseIdentifier: @"SYNChannelMidCell"];
}


#pragma mark - UICollectionView Delegate Methods

- (NSInteger) collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section
{
    return self.user.subscriptions.count;
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) cv cellForItemAtIndexPath: (NSIndexPath *) indexPath {
    
    Channel *channel = self.user.subscriptions[indexPath.row];
    
    SYNChannelMidCell *channelThumbnailCell = [cv dequeueReusableCellWithReuseIdentifier: @"SYNChannelMidCell"
                                                                            forIndexPath: indexPath];
    
    channelThumbnailCell.channelImageViewImage = channel.coverThumbnailLargeURL;
    [channelThumbnailCell setChannelTitle: channel.title];
    
    return channelThumbnailCell;
}


- (void) reloadCollectionViews
{
    [super reloadCollectionViews];
    
    if (self.headerView)
    {
        NSInteger totalChannels = self.user.subscriptions.count;
        
        [self.headerView setTitle: @"SUBSCRIPTIONS"
                        andNumber: totalChannels];
    }
}


- (void) setViewFrame: (CGRect) frame
{
    self.view.frame = frame;
    self.channelThumbnailCollectionView.frame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
}

#pragma mark - Accessors

- (UICollectionView *) collectionView
{
    return self.channelThumbnailCollectionView;
}



-(void)setUser:(ChannelOwner*)user
{
    if(user == _user)
        return;
    
    if([user.uniqueId isEqual:_user.uniqueId])
        return;
    
    _user = user;
    
    
    [self.channelThumbnailCollectionView reloadData];
}
-(ChannelOwner*)user
{
    return _user;
}


@end
