//
//  SYNSearchUsersViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 08/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchUsersViewController.h"
#import "SYNSearchTabView.h"
#import "SYNDeviceManager.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNUserThumbnailCell.h"

@interface SYNSearchUsersViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView* usersThumbnailCollectionView;
@property (nonatomic, weak) NSString* searchTerm;
@property (nonatomic, strong) NSArray* users;

@end

@implementation SYNSearchUsersViewController

@synthesize itemToUpdate;
@synthesize users;


- (id) initWithViewId: (NSString *) vid
{
    if ((self = [super initWithViewId: vid]))
    {
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleDataModelChange:)
                                                     name: NSManagedObjectContextObjectsDidChangeNotification
                                                   object: appDelegate.searchManagedObjectContext];
    }
    
    return self;
}



- (void) loadView
{
    BOOL isIPhone = IS_IPHONE;
    
    SYNIntegralCollectionViewFlowLayout* flowLayout;
    
    if (isIPhone)
        flowLayout = [SYNIntegralCollectionViewFlowLayout layoutWithItemSize: CGSizeMake(320.0f, 72.0f)
                                                     minimumInterItemSpacing: 0.0
                                                          minimumLineSpacing: 6.0
                                                             scrollDirection: UICollectionViewScrollDirectionVertical
                                                                sectionInset: UIEdgeInsetsMake(2.0, 2.0, 46.0, 2.0)];
    else
        flowLayout = [SYNIntegralCollectionViewFlowLayout layoutWithItemSize: CGSizeMake(120.0f, 180.0f)
                                                     minimumInterItemSpacing: 0.0
                                                          minimumLineSpacing: 2.0
                                                             scrollDirection: UICollectionViewScrollDirectionVertical
                                                                sectionInset: UIEdgeInsetsMake(6.0, 6.0, 5.0, 6.0)];
    
    
    
    flowLayout.footerReferenceSize = [self footerSize];
    
    // Work out how hight the inital tab bar is
    CGFloat topTabBarHeight = [UIImage imageNamed: @"CategoryBar"].size.height;
    
    CGRect channelCollectionViewFrame;
    if (isIPhone)
    {
        channelCollectionViewFrame = CGRectMake(0.0f, 52.0f,
                                                [SYNDeviceManager.sharedInstance currentScreenWidth],
                                                [SYNDeviceManager.sharedInstance currentScreenHeight] - 123.0f);
    }
    else
    {
        channelCollectionViewFrame = [SYNDeviceManager.sharedInstance isLandscape] ?
        CGRectMake(0.0, kStandardCollectionViewOffsetY + topTabBarHeight, kFullScreenWidthLandscape, kFullScreenHeightLandscapeMinusStatusBar - kStandardCollectionViewOffsetY - topTabBarHeight) :
        CGRectMake(0.0f, kStandardCollectionViewOffsetY + topTabBarHeight, kFullScreenWidthPortrait, kFullScreenHeightPortraitMinusStatusBar  - kStandardCollectionViewOffsetY - topTabBarHeight);
    }
    
    self.usersThumbnailCollectionView = [[UICollectionView alloc] initWithFrame: channelCollectionViewFrame
                                                           collectionViewLayout: flowLayout];
    
    self.usersThumbnailCollectionView.dataSource = self;
    self.usersThumbnailCollectionView.delegate = self;
    self.usersThumbnailCollectionView.backgroundColor = [UIColor clearColor];
    self.usersThumbnailCollectionView.showsVerticalScrollIndicator = NO;
    
    self.usersThumbnailCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.usersThumbnailCollectionView.scrollsToTop = NO;
    
    CGRect newFrame;
    if (isIPhone)
    {
        newFrame = CGRectMake(0.0f, 59.0f, [SYNDeviceManager.sharedInstance currentScreenWidth],
                              [SYNDeviceManager.sharedInstance currentScreenHeight] - 20.0f);
    }
    else
    {
        newFrame = [SYNDeviceManager.sharedInstance isLandscape] ?
        CGRectMake(0.0, 0.0, kFullScreenWidthLandscape, kFullScreenHeightLandscapeMinusStatusBar) :
        CGRectMake(0.0f, 0.0f, kFullScreenWidthPortrait, kFullScreenHeightPortraitMinusStatusBar);
    }
    
    self.view = [[UIView alloc] initWithFrame:newFrame];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.usersThumbnailCollectionView];
    
    
    self.usersThumbnailCollectionView.showsVerticalScrollIndicator = YES;
}

- (void) handleDataModelChange: (NSNotification*) dataNotification
{
    
    [self displayUsers];
    
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.users = [NSMutableArray array];
    
    // Register Cells
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNUserThumbnailCell"
                                             bundle: nil];
    
    [self.usersThumbnailCollectionView registerNib: thumbnailCellNib
                        forCellWithReuseIdentifier: @"SYNUserThumbnailCell"];
    
    // Register Footer
    UINib *footerViewNib = [UINib nibWithNibName: @"SYNChannelFooterMoreView"
                                          bundle: nil];
    
    [self.usersThumbnailCollectionView registerNib: footerViewNib
                          forSupplementaryViewOfKind: UICollectionElementKindSectionFooter
                                 withReuseIdentifier: @"SYNChannelFooterMoreView"];
    
}

- (void) displayUsers
{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName: @"ChannelOwner"
                                   inManagedObjectContext: appDelegate.searchManagedObjectContext]];
    
    
    [request setPredicate: [NSPredicate predicateWithFormat: @"viewId == %@", self.viewId]];
    
    request.fetchBatchSize = 20;
    
    NSError *error = nil;
    NSArray *resultsArray = [appDelegate.searchManagedObjectContext executeFetchRequest: request
                                                                                  error: &error];
    
    
    if (!resultsArray)
        return;
    
    users = [NSMutableArray arrayWithArray: resultsArray];
    
    [self.usersThumbnailCollectionView reloadData];
}

- (void) performNewSearchWithTerm: (NSString*) term
{
    
    
    if (!appDelegate)
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    self.dataRequestRange = NSMakeRange(0, kAPIInitialBatchSize);
    
    
    [appDelegate.networkEngine searchUsersForTerm: term
                                         andRange: self.dataRequestRange
                                       onComplete: ^(int itemsCount) {
                                              self.dataItemsAvailable = itemsCount;
                                              if (self.itemToUpdate)
                                                  [self.itemToUpdate setNumberOfItems: self.dataItemsAvailable
                                                                             animated: YES];
                                              
                                          }];
    
    self.searchTerm = term;
}

- (void) loadMoreUsers: (UIButton*) sender
{
    NSInteger nextStart = self.dataRequestRange.location + self.dataRequestRange.length; // one is subtracted when the call happens for 0 indexing
    
    if(nextStart >= self.dataItemsAvailable)
        return;
    
    self.loadingMoreContent = YES;
    
    NSInteger nextSize = (nextStart + STANDARD_REQUEST_LENGTH) >= self.dataItemsAvailable ? (self.dataItemsAvailable - nextStart) : STANDARD_REQUEST_LENGTH;
    
    self.dataRequestRange = NSMakeRange(nextStart, nextSize);
    
    [appDelegate.networkEngine searchUsersForTerm: self.searchTerm
                                         andRange: self.dataRequestRange
                                       onComplete: ^(int itemsCount) {
                                              self.dataItemsAvailable = itemsCount;
                                              self.loadingMoreContent = NO;
                                          }];
}

#pragma mark - UICollectionView Delegate

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}

- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    return self.users.count;
    
}



- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    ChannelOwner *user = self.users[indexPath.row];
    
    SYNUserThumbnailCell *userThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNUserThumbnailCell"
                                                                                        forIndexPath: indexPath];
    
    
    userThumbnailCell.nameLabel.text = user.displayName;
    
    userThumbnailCell.imageUrlString = user.thumbnailLargeUrl;
    
    [userThumbnailCell setDisplayName:user.displayName andUsername:user.username];
    
    
    return userThumbnailCell;
}

- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    ChannelOwner *channelOwner = (ChannelOwner*)self.users[indexPath.row];
    
    [appDelegate.viewStackManager viewProfileDetails:channelOwner];
}

- (CGSize) itemSize
{
    return [SYNDeviceManager.sharedInstance isIPhone] ? CGSizeMake(120.0f, 152.0f) : CGSizeMake(251.0, 274.0);
}



- (void) dealloc
{
    // Stop observing everything (less error-prone than trying to remove observers individually
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end
