//
//  SYNChannelCoverImageSelectorViewController.m
//  rockpack
//
//  Created by Mats Trovik on 08/05/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNChannelCoverImageSelectorViewController.h"
#import "SYNChannelCoverImageCell.h"
#import "ChannelCover.h"
#import "UIImageView+ImageProcessing.h"
#import <QuartzCore/QuartzCore.h>

enum ChannelCoverSelectorState {
    kChannelCoverDefault = 0,
    kChannelCoverCameraOptions = 1,
    kChannelCoverLocalAlbum = 2
    };

@interface SYNChannelCoverImageSelectorViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
{
    enum ChannelCoverSelectorState currentState;
}
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView; 
@property (weak, nonatomic) IBOutlet UIView *contentContainerView;

@end

@implementation SYNChannelCoverImageSelectorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    UINib* cellNib = [UINib nibWithNibName:@"SYNChannelCoverImageCell" bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"SYNChannelCoverImageCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Collection view delegate and data source

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch (currentState) {
        case kChannelCoverDefault:
        {
            ;
            id <NSFetchedResultsSectionInfo> userSectionInfo = self.userChannelCoverFetchedResultsController.sections [0];
            id <NSFetchedResultsSectionInfo> channelSectionInfo = self.channelCoverFetchedResultsController.sections [0];
            return [userSectionInfo numberOfObjects] + [channelSectionInfo numberOfObjects] + 1;
            break;
        }
        case kChannelCoverCameraOptions:
        case kChannelCoverLocalAlbum:
        default:
            return 0;
            break;
    }
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SYNChannelCoverImageCell* cell =(SYNChannelCoverImageCell*) [self.collectionView dequeueReusableCellWithReuseIdentifier:@"SYNChannelCoverImageCell" forIndexPath:indexPath];
    id <NSFetchedResultsSectionInfo> channelSectionInfo = self.channelCoverFetchedResultsController.sections [0];
    if(indexPath.row == 0)
    {
        cell.channelCoverImageView.image = [UIImage imageNamed:@"ChannelCreationCoverNone.png"];
    }
    else if (indexPath.row - 1 < [channelSectionInfo numberOfObjects])
    {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0];
        ChannelCover *channelCover = [self.channelCoverFetchedResultsController objectAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row
                                                                                                                          inSection: 0]];
        
        [cell.channelCoverImageView setAsynchronousImageFromURL:[NSURL URLWithString:channelCover.carouselURL] placeHolderImage:nil];
    }
    else
    {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 - [channelSectionInfo numberOfObjects] inSection:0];
        ChannelCover *channelCover = [self.userChannelCoverFetchedResultsController objectAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row
                                                                                                                          inSection: 0]];
        
        [cell.channelCoverImageView setAsynchronousImageFromURL:[NSURL URLWithString:channelCover.carouselURL] placeHolderImage:nil];
    }
    return cell;
}

-(void)refreshChannelCoverData
{
    if(currentState == kChannelCoverDefault)
    {
        [self.collectionView reloadData];
    }
}

#pragma mark - button actions
- (IBAction)cameraButtonTapped:(id)sender
{
    CATransition *animation = [CATransition animation];
    
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromRight];
    [animation setDuration:0.30];
    [animation setTimingFunction:
     [CAMediaTimingFunction functionWithName:
      kCAMediaTimingFunctionEaseInEaseOut]];
    
    self.cameraButton.hidden = YES;
    self.closeButton.hidden = YES;
    self.backButton.hidden = NO;
    currentState = kChannelCoverCameraOptions;
    [self.collectionView reloadData];
    
    [self.contentContainerView.layer addAnimation:animation forKey:nil];
}
- (IBAction)backButtonTapped:(id)sender
{
    CATransition *animation = [CATransition animation];
    
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setDuration:0.30];
    [animation setTimingFunction:
     [CAMediaTimingFunction functionWithName:
      kCAMediaTimingFunctionEaseInEaseOut]];
    switch (currentState) {
        case kChannelCoverCameraOptions:
            self.cameraButton.hidden = NO;
            self.closeButton.hidden = NO;
            self.backButton.hidden = YES;
            currentState = kChannelCoverDefault;
            break;
        case kChannelCoverLocalAlbum:
            currentState = kChannelCoverCameraOptions;
            break;
        default:
            break;
    }
        [self.collectionView reloadData];
    
    [self.contentContainerView.layer addAnimation:animation forKey:nil];
    
}

- (IBAction)closeButtonTapped:(id)sender
{
    if([self.imageSelectorDelegate respondsToSelector:@selector(closeImageSelector:)])
    {
        [self.imageSelectorDelegate closeImageSelector:self];
    }
}

@end
