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

@synthesize usersThumbnailCollectionView = _usersThumbnailCollectionView;

- (void) loadView
{
    
    
    SYNIntegralCollectionViewFlowLayout* flowLayout;
    
    if (IS_IPHONE)
    {
        flowLayout = [SYNIntegralCollectionViewFlowLayout layoutWithItemSize: CGSizeMake(320.0f, 72.0f)
                                                     minimumInterItemSpacing: 0.0
                                                          minimumLineSpacing: 6.0
                                                             scrollDirection: UICollectionViewScrollDirectionVertical
                                                                sectionInset: UIEdgeInsetsMake(2.0, 2.0, 46.0, 2.0)];
    }
    else
    {
        flowLayout = [SYNIntegralCollectionViewFlowLayout layoutWithItemSize: CGSizeMake(120.0f, 180.0f)
                                                     minimumInterItemSpacing: 0.0
                                                          minimumLineSpacing: 2.0
                                                             scrollDirection: UICollectionViewScrollDirectionVertical
                                                                sectionInset: UIEdgeInsetsMake(6.0, 6.0, 5.0, 6.0)];
    }
        
    
    
    
    flowLayout.footerReferenceSize = [self footerSize];
    
    
    _usersThumbnailCollectionView = [[UICollectionView alloc] initWithFrame: CGRectZero
                                                           collectionViewLayout: flowLayout];
    
    _usersThumbnailCollectionView.dataSource = self;
    _usersThumbnailCollectionView.delegate = self;
    _usersThumbnailCollectionView.backgroundColor = [UIColor clearColor];
    _usersThumbnailCollectionView.showsVerticalScrollIndicator = NO;
    
    _usersThumbnailCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _usersThumbnailCollectionView.scrollsToTop = NO;
    
    
    
    self.view = _usersThumbnailCollectionView;
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    _usersThumbnailCollectionView.showsVerticalScrollIndicator = YES;
    
    
    
    // Register Cells
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNUserThumbnailCell"
                                             bundle: nil];
    
    [self.usersThumbnailCollectionView registerNib: thumbnailCellNib
                        forCellWithReuseIdentifier: @"SYNUserThumbnailCell"];
    
    // Register Footer
    UINib *footerViewNib = [UINib nibWithNibName: @"SYNChannelFooterMoreView"
                                          bundle: nil];
    
    [_usersThumbnailCollectionView registerNib: footerViewNib
                    forSupplementaryViewOfKind: UICollectionElementKindSectionFooter
                           withReuseIdentifier: @"SYNChannelFooterMoreView"];
    
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.users = [NSMutableArray array];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setOffsetTop:0.0f];
    
    
    

}

#pragma mark - Getters/Setters

-(UICollectionView*)usersThumbnailCollectionView
{
    return (UICollectionView*)self.view;
}

-(void)setOffsetTop:(CGFloat)offsetTop
{
    CGRect collectionViewFrame = CGRectMake(0.0f, offsetTop,
                                            self.view.superview.frame.size.width,
                                            [SYNDeviceManager.sharedInstance currentScreenHeight] - offsetTop);
    
    
    self.usersThumbnailCollectionView.frame = collectionViewFrame;
}

@end
