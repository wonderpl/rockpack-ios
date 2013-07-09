//
//  SYNUsersViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 09/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNUsersViewController.h"
#import "SYNDeviceManager.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNUserThumbnailCell.h"


@interface SYNUsersViewController ()

@end

@implementation SYNUsersViewController

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


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.users = [NSMutableArray array];
    
}



@end
