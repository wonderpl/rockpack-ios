//
//  SYNExistingChannelsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 22/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
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
{
    BOOL hideCells;
}

@property (nonatomic, strong) IBOutlet UIButton* closeButton;
@property (nonatomic, strong) IBOutlet UIButton* confirmButtom;
@property (nonatomic, strong) IBOutlet UICollectionView* channelThumbnailCollectionView;
@property (nonatomic, weak) Channel* selectedChannel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) NSArray* channels;
@property (nonatomic, strong) NSIndexPath* previouslySelectedPath;

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
        [SYNDeletionWobbleLayout layoutWithItemSize: CGSizeMake(192.0f, 192.0f)
                            minimumInterItemSpacing: 0.0f
                                 minimumLineSpacing: 5.0f
                                    scrollDirection: UICollectionViewScrollDirectionVertical
                                       sectionInset: UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    }
    else
    {
        // iPhone layout & size
        self.channelThumbnailCollectionView.collectionViewLayout =
        [SYNDeletionWobbleLayout layoutWithItemSize: CGSizeMake(158.0f, 158.0f)
                            minimumInterItemSpacing: 0.0f
                                 minimumLineSpacing: 0.0f
                                    scrollDirection: UICollectionViewScrollDirectionVertical
                                       sectionInset: UIEdgeInsetsMake(2.0f, 2.0f, 0.0f, 2.0f)];
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
    
    
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    // Google analytics support
    [GAI.sharedInstance.defaultTracker sendView: @"Channels - Create - Select"];
    
    self.closeButton.enabled = YES;
    self.confirmButtom.enabled = YES;
    
    // Copy Channels     
    self.channels = [appDelegate.currentUser.channels array];
    if (self.selectedChannel)
    {
        int selectedIndex = [self.channels indexOfObject:self.selectedChannel];
        if( selectedIndex != NSNotFound)
        {
            self.selectedChannel = [self.channels objectAtIndex:selectedIndex];
            self.previouslySelectedPath = [NSIndexPath indexPathForRow:selectedIndex + 1 inSection:0];
            self.confirmButtom.enabled = YES;
        }
        else
        {
            self.previouslySelectedPath = nil;
            self.selectedChannel = nil;
            self.confirmButtom.enabled = NO;
        }
    }
    else
    {
        self.previouslySelectedPath = nil;
        self.selectedChannel = nil;
        self.confirmButtom.enabled = NO;
    }
    
    [self packViewForInterfaceOrientation:[SYNDeviceManager.sharedInstance orientation]];
    
    [self.channelThumbnailCollectionView reloadData];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.channels = nil;
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
        
        channelThumbnailCell.specialSelected = (channel == self.selectedChannel);

        
        cell = channelThumbnailCell;
    }
    
    if(hideCells)
    {
        cell.contentView.alpha = 0.0f;
    }

    return cell;
}


- (IBAction) closeButtonPressed: (id) sender
{
    self.closeButton.enabled = NO;
    self.confirmButtom.enabled = NO;
    
    [self closeAnimation:^(BOOL finished) {
        [self.view removeFromSuperview];
        // Post notification without object. Needed to restart video player if visible.
        [[NSNotificationCenter defaultCenter] postNotificationName: kNoteVideoAddedToExistingChannel
                                                            object: self];
    }];
    
    

    
}


- (IBAction) confirmButtonPressed: (id) sender
{
    if (!self.selectedChannel)
        return;
    
    self.confirmButtom.enabled = NO;
    self.closeButton.enabled = NO;
    
    [self closeAnimation:^(BOOL finished) {
        [self.view removeFromSuperview];
        [[NSNotificationCenter defaultCenter] postNotificationName: kNoteVideoAddedToExistingChannel
                                                            object: self
                                                          userInfo: @{kChannel:self.selectedChannel}];

    }];
    
    
}

-(void)closeAnimation:(void(^)(BOOL finished))completionBlock
{
    [UIView animateWithDuration: kAddToChannelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         CGRect newFrame = self.view.frame;
                         newFrame.origin.y = newFrame.size.height;
                         self.view.frame = newFrame;
                     }
                     completion:completionBlock];
}

- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (indexPath.row == 0)
    {
        //Reset any previous selection
        self.previouslySelectedPath = nil;
        self.selectedChannel = nil;
        self.confirmButtom.enabled = NO;
        
        if([SYNDeviceManager.sharedInstance isIPad])
        {
            if (!appDelegate.videoQueue.currentlyCreatingChannel)
                return;
        
            self.selectedChannel = nil;
        
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
                
                [[NSNotificationCenter defaultCenter] postNotificationName: kNoteCreateNewChannel
                                                                    object: self
                                                                  userInfo: @{kChannel:appDelegate.videoQueue.currentlyCreatingChannel}];
            }];
            
        }
    }
    else
    {
        if(self.previouslySelectedPath)
        {
            SYNChannelMidCell* cellToDeselect = (SYNChannelMidCell*)[self.channelThumbnailCollectionView cellForItemAtIndexPath:self.previouslySelectedPath];
            cellToDeselect.specialSelected = NO;
        }
        
        SYNChannelMidCell* cellToSelect = (SYNChannelMidCell*)[self.channelThumbnailCollectionView cellForItemAtIndexPath:indexPath];
        cellToSelect.specialSelected = YES;
        //Compensate for the extra "create new" cell
        self.selectedChannel = (Channel*)self.channels[indexPath.row - 1];
        self.previouslySelectedPath = indexPath;
        self.confirmButtom.enabled = YES;
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
            collectionFrame.size.width = 580.0;
        }
        else
        {
            collectionFrame.size.width = 780.0;
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


-(void)prepareForAppearAnimation;
{
    hideCells = YES;
    UICollectionViewCell* cell = nil;
    NSArray *indexPaths = [self.channelThumbnailCollectionView indexPathsForVisibleItems];
    for (NSIndexPath* path in indexPaths) {
        cell = [self.channelThumbnailCollectionView cellForItemAtIndexPath:path];
        cell.contentView.alpha= 0.0f;
    }
}

-(void)runAppearAnimation
{
    UICollectionViewCell* cell = nil;
    NSArray* sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"section" ascending:YES],[[NSSortDescriptor alloc] initWithKey:@"row" ascending:YES]];
    NSArray* indexPaths = [[self.channelThumbnailCollectionView indexPathsForVisibleItems] sortedArrayUsingDescriptors:sortDescriptors];
    int count = 0;
    for (NSIndexPath* path in indexPaths) {
        cell = [self.channelThumbnailCollectionView cellForItemAtIndexPath:path];
        [UIView animateWithDuration:0.2f delay:0.05*count options:UIViewAnimationCurveEaseInOut animations:^{
           cell.contentView.alpha= 1.0f;
        } completion:nil];
        count++;
    }
    hideCells = NO;
}

@end
