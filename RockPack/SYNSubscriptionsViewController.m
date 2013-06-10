//
//  SYNSubscriptionsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 17/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "Channel.h"
#import "ChannelCover.h"
#import "SYNChannelMidCell.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNSubscriptionsViewController.h"
#import "UIImageView+WebCache.h"

@interface SYNSubscriptionsViewController ()


@end


@implementation SYNSubscriptionsViewController

@synthesize channelOwner = _channelOwner;

- (void) loadView
{
    [super loadView];
    
    self.channelThumbnailCollectionView.backgroundColor = [UIColor clearColor];
    self.channelThumbnailCollectionView.showsVerticalScrollIndicator = NO;
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
    
    [self.channelThumbnailCollectionView registerNib: footerViewNib
                          forSupplementaryViewOfKind: UICollectionElementKindSectionFooter
                                 withReuseIdentifier: @"SYNChannelFooterMoreView"];
    
    // Register Cells
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNChannelMidCell"
                                             bundle: nil];
    
    [self.channelThumbnailCollectionView registerNib: thumbnailCellNib
                          forCellWithReuseIdentifier: @"SYNChannelMidCell"];
    
    
    CGRect correntFrame = self.channelThumbnailCollectionView.frame;
    correntFrame.size.width = 20.0;
    self.channelThumbnailCollectionView.frame = correntFrame;
}

- (void) handleDataModelChange: (NSNotification*) notification
{
    NSArray* updatedObjects = [[notification userInfo] objectForKey: NSUpdatedObjectsKey];
    NSArray* insertedObjects = [[notification userInfo] objectForKey: NSInsertedObjectsKey];
    NSArray* deletedObjects = [[notification userInfo] objectForKey: NSDeletedObjectsKey];
    
    [updatedObjects enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop)
     {
         
         if (obj == self.channelOwner)
         {
             
             
             // == Handle Inserted == //
             
             NSMutableArray* insertedIndexPathArray = [NSMutableArray arrayWithCapacity:insertedObjects.count]; // maximum
             
             [self.channelOwner.subscriptions enumerateObjectsUsingBlock:^(Channel* subscriptionChannel, NSUInteger cidx, BOOL *cstop) {
                 
                 [insertedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                     
                     if(obj == subscriptionChannel)
                     {
                         NSLog(@"SC(+) Inserted (%@): %@", NSStringFromClass([obj class]), ((Channel*)obj).title);
                         
                         [insertedIndexPathArray addObject:[NSIndexPath indexPathForItem:cidx inSection:0]];
                     }
                 }];
                 
             }];
             
             
             // == Handle Deleted == //
             
             NSMutableArray* deletedIndetifiers = [NSMutableArray arrayWithCapacity:deletedObjects.count];
             NSMutableArray* deletedIndexPathArray = [NSMutableArray arrayWithCapacity:deletedObjects.count]; // maximum
             [deletedObjects enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
                 
                 if ([obj isKindOfClass:[Channel class]]) {
                     
                     NSLog(@"PR(-) Deleted: %@", ((Channel*)obj).title);
                     
                     [deletedIndetifiers addObject:((Channel*)obj).uniqueId];
                     
                 }
                 
             }];
             
             int index = 0;
             for(SYNChannelMidCell* cell in self.channelThumbnailCollectionView.visibleCells){
                 
                 if([deletedIndetifiers containsObject:cell.dataIndentifier])
                 {
                     NSLog(@"PR(-) Found Cell at: %i", index);
                     [deletedIndexPathArray addObject:[NSIndexPath indexPathForItem:index inSection:0]];
                 }
                 index++;
                 
             }
             
             
             [self.channelThumbnailCollectionView performBatchUpdates:^{
                 
                 if(insertedIndexPathArray.count > 0)
                     [self.channelThumbnailCollectionView insertItemsAtIndexPaths:insertedIndexPathArray];
                 
                 if(deletedIndexPathArray.count > 0)
                     [self.channelThumbnailCollectionView deleteItemsAtIndexPaths:deletedIndexPathArray];
                 
             } completion:^(BOOL finished) {
                 
                
                 
                 
                 
             }];
             
             
             return;
             
             
         }
         
     }];
    
}


#pragma mark - UICollectionView Delegate Methods

- (NSInteger) collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section
{
    return self.channelOwner.subscriptions.count;
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) cv cellForItemAtIndexPath: (NSIndexPath *) indexPath {
    
    
    
    Channel *channel = self.channelOwner.subscriptions[indexPath.item];
    
    SYNChannelMidCell *channelThumbnailCell = [cv dequeueReusableCellWithReuseIdentifier: @"SYNChannelMidCell"
                                                                            forIndexPath: indexPath];

    [channelThumbnailCell.imageView setImageWithURL: [NSURL URLWithString: channel.channelCover.imageLargeUrl]
                                   placeholderImage: [UIImage imageNamed: @"PlaceholderChannelMid.png"]
                                            options: SDWebImageRetryFailed];
    
    [channelThumbnailCell setChannelTitle: channel.title];
    
    return channelThumbnailCell;
}


- (void) reloadCollectionViews
{
    if (self.headerView)
    {
        NSInteger totalChannels = self.channelOwner.subscriptions.count;
        
        if (self.channelOwner == appDelegate.currentUser)
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
    
    [self.channelThumbnailCollectionView reloadData];
}


- (void) setViewFrame: (CGRect) frame
{
    NSLog(@"Width: %f", frame.size.width);
    self.view.frame = frame;
    self.channelThumbnailCollectionView.frame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
}

#pragma mark - Accessors

- (UICollectionView *) collectionView
{
    return self.channelThumbnailCollectionView;
}



-(void)setChannelOwner:(ChannelOwner*)channelOnwer
{
    if (self.channelOwner) // if we have an existing user
    {
        // remove the listener, even if nil is passed
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSManagedObjectContextObjectsDidChangeNotification
                                                      object:self.channelOwner];
    }
    
    // no additional checks because it is done above
    _channelOwner = channelOnwer;
    
    if(!_channelOwner)
        return;
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleDataModelChange:)
                                                 name: NSManagedObjectContextDidSaveNotification
                                               object: self.channelOwner.managedObjectContext];
    
    [self.channelThumbnailCollectionView reloadData];
}
-(ChannelOwner*)channelOwner
{
    return (ChannelOwner*)_channelOwner;
}

- (void) dealloc
{
    self.channelOwner = nil;
}


@end
