//
//  SYNExistingChannelsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 22/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "GAI.h"
#import "SYNChannelCreateNewCell.h"
#import "SYNChannelDetailViewController.h"
#import "SYNChannelMidCell.h"
#import "SYNDeletionWobbleLayout.h"
#import "SYNDeviceManager.h"
#import "SYNExistingChannelsViewController.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import "ChannelCover.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNExistingChannelsViewController ()

@property (nonatomic, strong) IBOutlet UIButton* closeButton;
@property (nonatomic, strong) IBOutlet UIButton* confirmButtom;
@property (nonatomic, strong) IBOutlet UICollectionView* channelThumbnailCollectionView;
@property (nonatomic, weak) Channel* selectedChannel;
@property (nonatomic, weak) SYNChannelMidCell* selectedCell;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) NSArray* channels;

@end

@implementation SYNExistingChannelsViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // We need to use a custom layout (as due to the deletion/wobble logic used elsewhere)
    if ([SYNDeviceManager.sharedInstance isIPad])
    {
        // iPad layout & size
        self.channelThumbnailCollectionView.collectionViewLayout =
        [SYNDeletionWobbleLayout layoutWithItemSize: CGSizeMake(184.0f, 184.0f)
                            minimumInterItemSpacing: 10.0f
                                 minimumLineSpacing: 10.0f
                                    scrollDirection: UICollectionViewScrollDirectionVertical
                                       sectionInset: UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    }
    else
    {
        // iPhone layout & size
        self.channelThumbnailCollectionView.collectionViewLayout =
        [SYNDeletionWobbleLayout layoutWithItemSize: CGSizeMake(152.0f, 152.0f)
                            minimumInterItemSpacing: 6.0f
                                 minimumLineSpacing: 5.0f
                                    scrollDirection: UICollectionViewScrollDirectionVertical
                                       sectionInset: UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
    }

    UINib *createCellNib = [UINib nibWithNibName: @"SYNChannelCreateNewCell"
                                          bundle: nil];
    
    [self.channelThumbnailCollectionView registerNib: createCellNib
                          forCellWithReuseIdentifier: @"SYNChannelCreateNewCell"];
    
    
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNChannelMidCell"
                                             bundle: nil];
    
    [self.channelThumbnailCollectionView registerNib: thumbnailCellNib
                          forCellWithReuseIdentifier: @"SYNChannelMidCell"];
    
    self.titleLabel.font = [UIFont boldRockpackFontOfSize:self.titleLabel.font.pointSize];
    
    // Copy Channels and filter them
    
    NSMutableArray* allChannels = [NSMutableArray arrayWithCapacity:appDelegate.currentUser.channels.count];
    for (Channel* ch in appDelegate.currentUser.channels)
    {
        if (ch.favouritesValue) // remove the favourites channel because it can be added to only by subscribing to a video
            continue;
        
        [allChannels addObject:ch];
        
    }
    
    self.channels = [NSArray arrayWithArray:allChannels];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    // Google analytics support
    [GAI.sharedInstance.defaultTracker sendView: @"Channels - Create - Select"];
    
    self.closeButton.enabled = YES;
    self.confirmButtom.enabled = YES;
    
    
    [self packViewForInterfaceOrientation:[SYNDeviceManager.sharedInstance orientation]];
    
    [self.channelThumbnailCollectionView reloadData];
}




#pragma mark - UICollectionView DataSource

- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    return self.channels.count + 1; // add one for the 'create new channel' cell
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    UICollectionViewCell* cell;
    
    if (indexPath.row == 0) // first row (create)
    {
        SYNChannelCreateNewCell* createCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelCreateNewCell"
                                                                                        forIndexPath: indexPath];
        
        cell = createCell;
    }
    else
    {
        Channel *channel = (Channel*)self.channels[indexPath.row-1];
        
        SYNChannelMidCell *channelThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelMidCell"
                                                                                            forIndexPath: indexPath];

        [channelThumbnailCell.imageView setImageWithURL: [NSURL URLWithString: channel.channelCover.imageLargeUrl]
                                       placeholderImage: [UIImage imageNamed: @"PlaceholderChannelMid.png"]
                                                options: SDWebImageRetryFailed];

        [channelThumbnailCell setChannelTitle: channel.title];
        
        cell = channelThumbnailCell;
    }

    return cell;
}


- (IBAction) closeButtonPressed: (id) sender
{
    self.closeButton.enabled = NO;
    self.confirmButtom.enabled = NO;
    [UIView animateWithDuration: 0.2
                     animations: ^{
        self.view.alpha = 0.0;
    }
                     completion: ^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}


- (IBAction) confirmButtonPressed: (id) sender
{
    if (!self.selectedChannel)
        return;
    
    self.confirmButtom.enabled = NO;
    self.closeButton.enabled = NO;
    
    [UIView animateWithDuration: 0.2
                     animations: ^{
                         
                         self.view.alpha = 0.0;
                         
                   } completion: ^(BOOL finished) {
                       
                       [self.view removeFromSuperview];
                       [self removeFromParentViewController];
                       
                       // send to MasterViewController
        
                       [[NSNotificationCenter defaultCenter] postNotificationName: kNoteVideoAddedToExistingChannel
                                                                           object: self
                                                                         userInfo: @{kChannel:self.selectedChannel}];
                       
                     
                       
                       
    }];
}


- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (indexPath.row == 0)
    {
        if([SYNDeviceManager.sharedInstance isIPad])
        {
            if (!appDelegate.videoQueue.currentlyCreatingChannel)
                return;
        
            self.selectedChannel = nil;
            self.selectedCell = nil;
        
            [UIView animateWithDuration: 0.3
                                  delay: 0.0
                                options: UIViewAnimationCurveLinear
                             animations: ^{
                             
                                 self.view.alpha = 0.0;
                            
            
                           } completion: ^(BOOL finished) {
                               [self.view removeFromSuperview];
                           
                               [[NSNotificationCenter defaultCenter] postNotificationName: kNoteCreateNewChannel
                                                                                   object: self
                                                                                 userInfo: @{kChannel:appDelegate.videoQueue.currentlyCreatingChannel}];
                         }];
        }
        else
        {
            
            //On iPhone we want a different navigation structure. Slide the view in.
            
            SYNChannelDetailViewController *channelCreationVC =
            [[SYNChannelDetailViewController alloc] initWithChannel: appDelegate.videoQueue.currentlyCreatingChannel
                                                          usingMode: kChannelDetailsModeEdit] ;
            CGRect newFrame = channelCreationVC.view.frame;
            newFrame.size.height = self.view.frame.size.height;
            channelCreationVC.view.frame = newFrame;
            CATransition *animation = [CATransition animation];
            
            [animation setType:kCATransitionMoveIn];
            [animation setSubtype:kCATransitionFromRight];
            
            [animation setDuration:0.30];
            [animation setTimingFunction:
             [CAMediaTimingFunction functionWithName:
              kCAMediaTimingFunctionEaseInEaseOut]];
            
            [self.view.window.layer addAnimation:animation forKey:nil];
            [self presentViewController:channelCreationVC animated:NO completion:^{
                
            }];
            
        }
    }
    else
    {
        self.selectedCell = (SYNChannelMidCell*)[self.channelThumbnailCollectionView cellForItemAtIndexPath:indexPath];
        //Compensate for the extra "create new" cell
        self.selectedChannel = (Channel*)self.channels[indexPath.row - 1];
    }
    
}


- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    [super willAnimateRotationToInterfaceOrientation: toInterfaceOrientation
                                            duration: duration];
    
    [self packViewForInterfaceOrientation:toInterfaceOrientation];
}

-(void)packViewForInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation
{
    CGRect collectionFrame = self.channelThumbnailCollectionView.frame;
    
    if ([SYNDeviceManager.sharedInstance isIPad])
    {
        if(UIInterfaceOrientationIsPortrait(interfaceOrientation))
        {
            collectionFrame.size.width = 572.0;
        }
        else
        {
            collectionFrame.size.width = 766.0;
        }
    }
    else
    {
        collectionFrame.size.width = 320.0f;
    }
    
    collectionFrame.origin.x = (self.view.frame.size.width * 0.5) - (collectionFrame.size.width * 0.5);
    self.channelThumbnailCollectionView.frame = CGRectIntegral(collectionFrame);
    
    CGRect selfFrame = self.view.frame;
    selfFrame.size = [SYNDeviceManager.sharedInstance currentScreenSize];
    self.view.frame = selfFrame;
    
    
}

- (void) setSelectedCell: (SYNChannelMidCell *) selectedCell
{
    _selectedCell.specialSelected = NO;
    
    if(selectedCell) // we can still pass nill
        selectedCell.specialSelected = YES;
    
    _selectedCell = selectedCell;
}

@end
