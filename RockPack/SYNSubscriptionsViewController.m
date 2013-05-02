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

@property (nonatomic, weak) User* user;


@end

@implementation SYNSubscriptionsViewController

@synthesize collectionView;
@synthesize headerView;
@synthesize user;

- (void) loadView
{
    [super loadView];
    
    
    self.channelThumbnailCollectionView.backgroundColor = [UIColor clearColor];
    self.channelThumbnailCollectionView.showsVerticalScrollIndicator = NO;
    
}

-(CGSize)itemSize
{
    return CGSizeMake(184.0, 138.0);
}

-(CGSize)footerSize
{
    return CGSizeMake(0.0, 0.0);
}


- (void) viewDidLoad
{

    //[super viewDidLoad];
    
    appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    user = appDelegate.currentUser;
    
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
    return user.subscriptions.count;
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) cv cellForItemAtIndexPath: (NSIndexPath *) indexPath {
    
    Channel *channel = user.subscriptions[indexPath.row];
    
    SYNChannelMidCell *channelThumbnailCell = [cv dequeueReusableCellWithReuseIdentifier: @"SYNChannelMidCell"
                                                                            forIndexPath: indexPath];
    
    channelThumbnailCell.channelImageViewImage = channel.coverThumbnailLargeURL;
    [channelThumbnailCell setChannelTitle:channel.title];
    
    
    return channelThumbnailCell;
    
}

-(void)reloadCollectionViews
{
    [super reloadCollectionViews];
    
    
    if(self.headerView)
    {
        NSInteger totalChannels = user.subscriptions.count;
        [self.headerView setTitle:@"SUBSCRIPTIONS" andNumber:totalChannels];
    }
    
}

-(void)setViewFrame:(CGRect)frame
{
    self.view.frame = frame;
    self.channelThumbnailCollectionView.frame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);


}

-(UICollectionView*)collectionView
{
    return self.channelThumbnailCollectionView;
}


@end
