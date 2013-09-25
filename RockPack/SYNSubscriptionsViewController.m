//
//  SYNSubscriptionsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 17/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "AppConstants.h"
#import "Channel.h"
#import "ChannelCover.h"
#import "SYNChannelMidCell.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNSubscriptionsViewController.h"
#import "UIImageView+WebCache.h"
#import "SYNDeviceManager.h"

@implementation SYNSubscriptionsViewController

- (void) loadView
{
    [super loadView];
}


- (CGSize) itemSize
{
    return CGSizeMake(192.0, 192.0);
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
    
    [self.channelCollectionView registerNib: footerViewNib
                 forSupplementaryViewOfKind: UICollectionElementKindSectionFooter
                        withReuseIdentifier: @"SYNChannelFooterMoreView"];
    
    // Register Cells
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNChannelMidCell"
                                             bundle: nil];
    
    [self.channelCollectionView registerNib: thumbnailCellNib
                 forCellWithReuseIdentifier: @"SYNChannelMidCell"];

    CGRect correntFrame = self.channelCollectionViewController.view.frame;
    correntFrame.size.width = 20.0;
    self.channelCollectionViewController.view.frame = correntFrame;
}


// Override implementation in super
- (void) setupGestureRecognizerCallbackBlocks
{
    // Add the recogniser blocks for this collection view
    __weak typeof(self) weakself = self;
    
    TapRecognizedBlock tapRecognizedBlock = ^(UICollectionViewCell *cell) {
        [weakself channelTapped: cell];
    };
    
    self.channelCollectionViewController.tapRecognizedBlock = tapRecognizedBlock;
    
    LongPressRecognizedBlock longPressRecognizedBlock = ^(UIGestureRecognizer *recognizer) {
        [weakself arcMenuUpdateState: recognizer];
    };
    
    self.channelCollectionViewController.longPressRecognizedBlock = longPressRecognizedBlock;
}

#pragma mark - Add UIView if there are no channels

- (void) isCurrentUserProfile
{
    if (self.user == appDelegate.currentUser)
    {
        if (self.user.subscriptions.count <= 0)
        {
            [self displayNoSubscriptionsMessage];
        }
        
        else
        {
            [self hideNoSubscriptionsMessage];
        }
    }
    else
    {
        [self.noChannelsMessage removeFromSuperview];
    }
    

}

- (void) displayNoSubscriptionsMessage
{
    if (self.noChannelsMessage)
    {
        [self.noChannelsMessage removeFromSuperview];
        self.noChannelsMessage = nil;
    }
    
    self.noChannelsMessage = [[SYNNoChannelsMessageView alloc] initWithMessage:@"Need a little inspiration?\nTry browsing our popular packs."];
    
    CGRect messageFrame = self.noChannelsMessage.frame;
    messageFrame.origin.x = (self.view.bounds.size.width * 0.5) - (messageFrame.size.width * 0.5);
    messageFrame.origin.y = IS_IPAD ? 60.0f : (self.view.frame.size.height * 0.5) - (messageFrame.size.height * 0.5) - 20.0f;
    messageFrame = CGRectIntegral(messageFrame);
    self.noChannelsMessage.frame = messageFrame;
    self.noChannelsMessage.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;

    [self.channelCollectionView addSubview: self.noChannelsMessage];
}

- (void) hideNoSubscriptionsMessage
{
    [self.noChannelsMessage removeFromSuperview];
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


- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    Channel *channel = self.user.subscriptions[indexPath.item];
    
    SYNChannelMidCell *channelThumbnailCell = [cv dequeueReusableCellWithReuseIdentifier: @"SYNChannelMidCell"
                                                                            forIndexPath: indexPath];

    [channelThumbnailCell.imageView setImageWithURL: [NSURL URLWithString: channel.channelCover.imageLargeUrl]
                                   placeholderImage: [UIImage imageNamed: @"PlaceholderChannelMid.png"]
                                            options: SDWebImageRetryFailed];
    
    if (channel.favouritesValue)
    {
        if ([appDelegate.currentUser.uniqueId isEqualToString:channel.channelOwner.uniqueId])
        {
            [channelThumbnailCell setChannelTitle: [NSString stringWithFormat:@"MY %@", NSLocalizedString(@"FAVORITES", nil)] ];
        }
        else
        {
            [channelThumbnailCell setChannelTitle:
             [NSString stringWithFormat:@"%@'S %@", [channel.channelOwner.displayName uppercaseString], NSLocalizedString(@"FAVORITES", nil)]];
        }  
    }
    else
    {
        [channelThumbnailCell setChannelTitle: channel.title];
    }

    return channelThumbnailCell;
}


- (void) reloadCollectionViews
{
    if (self.headerView)
    {
        NSInteger totalChannels = self.user.subscriptions.count;
        
        if (self.user == appDelegate.currentUser)
        {
            [self.headerView setTitle: NSLocalizedString(@"profile_screen_section_owner_subscription_title", nil)
                            andNumber: totalChannels];
        }
        else
        {
            [self.headerView setTitle: NSLocalizedString(@"profile_screen_section_user_subscription_title", nil)
                            andNumber: totalChannels];
        }
    }
    
    [self isCurrentUserProfile];
    [self.channelCollectionView reloadData];
}


- (void) setViewFrame: (CGRect) frame
{
    self.view.frame = frame;
    self.channelCollectionViewController.view.frame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
}


#pragma mark - Accessors

- (UICollectionView *) channelCollectionView
{
    return self.channelCollectionViewController.collectionView;
}


- (void) headerTapped
{
    [self.channelCollectionView setContentOffset: CGPointZero
                                                                 animated: YES];
}


- (void) setUser: (ChannelOwner*) user
{
    // no additional checks because it is done above
    _user = user;
    
    [self.channelCollectionView reloadData];
}


- (void) channelTapped: (UICollectionViewCell *) cell
{
    SYNChannelMidCell *selectedCell = (SYNChannelMidCell *) cell;
    NSIndexPath *indexPath = [self.channelCollectionView indexPathForItemAtPoint: selectedCell.center];
    
    Channel *channel = self.user.subscriptions[indexPath.item];
    
    [appDelegate.viewStackManager viewChannelDetails: channel];
}

//- (void) channelTapped: (UICollectionViewCell *) cell
//{
//    SYNChannelThumbnailCell *selectedCell = (SYNChannelThumbnailCell *) cell;
//    NSIndexPath *indexPath = [self.channelCollectionViewController.collectionView indexPathForItemAtPoint: selectedCell.center];
//    
//    if (self.isAnimating) // prevent double clicking
//    {
//        return;
//    }
//    
//    Channel *channel = (Channel *) self.channels[indexPath.row];
//    
//    [appDelegate.viewStackManager viewChannelDetails: channel];
//}


- (NSIndexPath *) indexPathForChannelCell: (UICollectionViewCell *) cell
{
    NSIndexPath *indexPath = [self.channelCollectionView indexPathForCell: cell];
    return  indexPath;
}

- (Channel *) channelInstanceForIndexPath: (NSIndexPath *) indexPath
                        andComponentIndex: (NSInteger) componentIndex
{
    if (componentIndex != kArcMenuInvalidComponentIndex)
    {
        AssertOrLog(@"Unexpectedly valid componentIndex");
    }
    
    Channel *channel = self.user.subscriptions[indexPath.item];
    
    return channel;
}


- (void) arcMenuUpdateState: (UIGestureRecognizer *) recognizer
{
    [self superArcMenuUpdateState: recognizer];

    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        Channel *channel = self.user.subscriptions[self.arcMenuIndexPath.item];
        
        [self requestShareLinkWithObjectType: @"channel"
                                    objectId: channel.uniqueId];
    }
}


- (void) arcMenu: (SYNArcMenuView *) menu
         didSelectMenuName: (NSString *) menuName
         forCellAtIndex: (NSIndexPath *) cellIndexPath
         andComponentIndex: (NSInteger) componentIndex
{
    if ([menuName isEqualToString: kActionShareChannel])
    {
        [self shareChannelAtIndexPath: cellIndexPath
                    andComponentIndex: componentIndex];
    }
    else
    {
        AssertOrLog(@"Invalid Arc Menu index selected");
    }
}

@end
