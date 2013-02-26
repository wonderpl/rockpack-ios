//
//  SYNVideoQueueView.m
//  rockpack
//
//  Created by Michael Michailidis on 25/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNVideoQueueView.h"
#import "AppConstants.h"
#import "SYNVideoSelection.h"
#import "SYNSoundPlayer.h"

@implementation SYNVideoQueueView

@synthesize videoQueueCollectionView;
@synthesize delegate;
@synthesize highlighted;

-(id)init
{
    CGRect stdFrame = CGRectMake(0, 573 + kVideoQueueEffectiveHeight, 1024, kVideoQueueEffectiveHeight);
    if (self = [self initWithFrame:stdFrame]) {
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        // == Background
        
        backgroundImageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 1024, 115)];
        backgroundImageView.image = [UIImage imageNamed: @"PanelVideoQueue.png"];
        [self addSubview: backgroundImageView];
        
        
        
        // == Delete Button 
        
        deleteButton = [UIButton buttonWithType: UIButtonTypeCustom];
        deleteButton.frame = CGRectMake(949, 35, 50, 50);
        
        [deleteButton setImage:[UIImage imageNamed: @"ButtonVideoWellDelete.png"] forState: UIControlStateNormal];
        
        [deleteButton setImage:[UIImage imageNamed: @"ButtonVideoWellDeleteHighlighted.png"] forState: UIControlStateHighlighted];
        
        deleteButton.enabled = NO;
        
        [self addSubview:deleteButton];
        
        
        
        // == New Button
        
        channelButton = [UIButton buttonWithType: UIButtonTypeCustom];
        channelButton.frame = CGRectMake(663, 35, 50, 50);
        
        [channelButton setImage:[UIImage imageNamed:@"ButtonVideoWellNew.png"] forState: UIControlStateNormal];
        
        [channelButton setImage:[UIImage imageNamed: @"ButtonVideoWellNewHighlighted.png"] forState: UIControlStateSelected];
        
        channelButton.enabled = NO;
        
        [self addSubview:channelButton];
        
        
        // == Existing Button
        
        existingButton = [UIButton buttonWithType: UIButtonTypeCustom];
        existingButton.frame = CGRectMake(806, 35, 50, 50);
        
        [existingButton setImage:[UIImage imageNamed: @"ButtonVideoWellExisting.png"] forState: UIControlStateNormal];
        
        [existingButton setImage:[UIImage imageNamed: @"ButtonVideoWellExistingHighlighted.png"] forState: UIControlStateHighlighted];
        
        [self addSubview:existingButton];
        
        
        // == Message View
        
        messageView = [[UIImageView alloc] initWithFrame: CGRectMake(60, 47, 411, 31)];
        messageView.image = [UIImage imageNamed: @"MessageDragAndDrop.png"];
        
        // Disable message if we already have items in the queue (from another screen)
        if (SYNVideoSelection.sharedVideoSelectionArray.count == 0)
        {
            messageView.alpha = 0.0f;
        }
        
        [self addSubview:messageView];
        
        // Video Queue collection view
        
        
        // == Layout
        
        UICollectionViewFlowLayout *standardFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        standardFlowLayout.itemSize = CGSizeMake(127.0f , 73.0f);
        standardFlowLayout.minimumInteritemSpacing = 0.0f;
        standardFlowLayout.minimumLineSpacing = 15.0f;
        standardFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        standardFlowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        
        // Make this of zero width initially
        videoQueueCollectionView = [[UICollectionView alloc] initWithFrame: CGRectMake(kVideoQueueWidth + kVideoQueueOffsetX, 26, 0, 73)
                                                           collectionViewLayout: standardFlowLayout];
        
        
        
        videoQueueCollectionView.backgroundColor = [UIColor clearColor];
        
        UINib *videoQueueCellNib = [UINib nibWithNibName: @"SYNVideoQueueCell" bundle: nil];
        
        [videoQueueCollectionView registerNib: videoQueueCellNib forCellWithReuseIdentifier: @"VideoQueueCell"];
        
        [self addSubview:videoQueueCollectionView];
        
        
        // == Drop Zone
        
        dropZoneView = [[UIView alloc] initWithFrame: CGRectMake(20, 640, 127, 73)];
        [self addSubview:dropZoneView];
        
        
    }
    return self;
}

#pragma mark - Accessors

-(void)setDelegate:(id<SYNVideoQueueDelegate, UICollectionViewDataSource, UICollectionViewDelegate>)del
{
    delegate = del;
    
    videoQueueCollectionView.delegate = self.delegate;
    videoQueueCollectionView.dataSource = self.delegate;
    
    
    [deleteButton addTarget:self action: @selector(clearVideoQueue) forControlEvents: UIControlEventTouchUpInside];
    
    [channelButton addTarget:self.delegate action: @selector(createChannelFromVideoQueue) forControlEvents: UIControlEventTouchUpInside];
}

-(void)setHighlighted:(BOOL)value
{
    if (value)
    {
        backgroundImageView.image = [UIImage imageNamed: @"PanelVideoQueueHighlighted.png"];
    }
    else
    {
        backgroundImageView.image = [UIImage imageNamed: @"PanelVideoQueue.png"];
    }
}



#pragma mark - Add to Queue

#pragma mark - Add Videos

- (void) addVideoToQueue: (VideoInstance *) videoInstance
{
    
    [[SYNSoundPlayer sharedInstance] playSoundByName:kSoundSelect];
    
    // The first video added enables the new channel button
    if (SYNVideoSelection.sharedVideoSelectionArray.count == 0)
    {
        channelButton.enabled = YES;
        channelButton.selected = YES;
        deleteButton.enabled = YES;
        
        [self showMessage:NO];
    }
    
    
    
    // First, increase the size of the view by the size of the new cell to be added (+margin)
    CGRect videoQueueViewFrame = self.videoQueueCollectionView.frame;
    videoQueueViewFrame.size.width += 142;
    
    self.videoQueueCollectionView.frame = videoQueueViewFrame;
    
    [SYNVideoSelection.sharedVideoSelectionArray addObject: videoInstance];
    
    [self.videoQueueCollectionView reloadData];
    
    if (self.videoQueueCollectionView.contentSize.width + 15 > kVideoQueueWidth + 142)
    {
        CGPoint contentOffset = self.videoQueueCollectionView.contentOffset;
        contentOffset.x = self.videoQueueCollectionView.contentSize.width - kVideoQueueWidth;
        self.videoQueueCollectionView.contentOffset = contentOffset;
    }
    
    
    // Animate the view out onto the screen
    [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                          delay: 0.5f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
         // Slide origin back
         CGRect videoQueueCollectionViewFrame = self.videoQueueCollectionView.frame;
         videoQueueCollectionViewFrame.origin.x -= 142;
         
         CGPoint contentOffset = self.videoQueueCollectionView.contentOffset;
         
         if (self.videoQueueCollectionView.contentSize.width > kVideoQueueWidth)
         {
             videoQueueCollectionViewFrame.origin.x = kVideoQueueOffsetX;
             videoQueueCollectionViewFrame.size.width = kVideoQueueWidth;
             
             
             contentOffset.x = self.videoQueueCollectionView.contentSize.width - kVideoQueueWidth + 15;
         }
         
         self.videoQueueCollectionView.contentOffset = contentOffset;
         self.videoQueueCollectionView.frame = videoQueueCollectionViewFrame;
     } completion: ^(BOOL finished) {
         
     }];
}




- (void) clearVideoQueue
{

    
    [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         
         messageView.alpha = 1.0f;
        
         
     } completion: ^(BOOL finished) {
         
     }];
    
    channelButton.enabled = NO;
    channelButton.selected = NO;
    deleteButton.enabled = NO;
    
    [SYNVideoSelection.sharedVideoSelectionArray removeAllObjects];
    
    [self.videoQueueCollectionView reloadData];
}


-(void)showMessage:(BOOL)show
{
    [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         
                         messageView.alpha = show ? 1.0f : 0.0f;
                         
        } completion: ^(BOOL finished) {
                         
        }];
}


@end
