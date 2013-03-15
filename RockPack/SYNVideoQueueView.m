//
//  SYNVideoQueueView.m
//  rockpack
//
//  Created by Michael Michailidis on 25/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNVideoQueueView.h"
#import "AppConstants.h"

#define kVideoQueueCellWidth 142.0

@implementation SYNVideoQueueView

@synthesize videoQueueCollectionView;
@synthesize deleteButton, channelButton, existingButton;
@synthesize backgroundImageView;


-(id)init
{
    CGRect stdFrame = CGRectMake(0, 0.0, 1024.0, 103.0);
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

        // initially there are no selected videos since the VideoQueue is loaded only once at the start.
        
        messageView.alpha = 0.0f;
        
        [self addSubview:messageView];
        
        
        
        // == Video Queue collection view + Scroller
        
        
        UICollectionViewFlowLayout *standardFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        standardFlowLayout.itemSize = CGSizeMake(127.0f , 73.0f);
        standardFlowLayout.minimumInteritemSpacing = 0.0f;
        standardFlowLayout.minimumLineSpacing = 15.0f;
        standardFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        standardFlowLayout.sectionInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        
        
        // Make this of zero width initially
        collectionViewStartFrame = CGRectMake(430.0, 0.0, 0.0, 73);
        videoQueueCollectionView = [[UICollectionView alloc] initWithFrame: collectionViewStartFrame
                                                      collectionViewLayout: standardFlowLayout];
        
        
        
        videoQueueCollectionView.backgroundColor = [UIColor clearColor];
        videoQueueCollectionView.scrollEnabled = NO; // scroll will happen on the scrollView which wraps it
        //videoQueueCollectionView.backgroundColor = [UIColor greenColor];
        
        UINib *videoQueueCellNib = [UINib nibWithNibName: @"SYNVideoQueueCell" bundle: nil];
        
        [videoQueueCollectionView registerNib: videoQueueCellNib forCellWithReuseIdentifier: @"VideoQueueCell"];
        
        
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(74.0, 26.0, 568.0, 73.0)];
        [scrollView setBackgroundColor:[UIColor clearColor]];
        scrollView.scrollEnabled = YES;
        scrollView.pagingEnabled = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        
        [self addSubview:scrollView];
        
        [scrollView addSubview:videoQueueCollectionView];
        
        leftmostOffset = CGPointZero;
        
        
        // == Drop Zone
        
        dropZoneView = [[UIView alloc] initWithFrame: CGRectMake(20, 640, 127, 73)];
        [self addSubview:dropZoneView];
        
        
    }
    return self;
}


#pragma mark - Add to Queue

- (void) addVideoToQueue: (VideoInstance *) videoInstance
{
    
  
    
    [scrollView setContentOffset:leftmostOffset];
    
    // 1. Expand Collection View Frame
    
    CGRect expandeCollectionViewFrame = self.videoQueueCollectionView.frame;
    expandeCollectionViewFrame.size.width += kVideoQueueCellWidth;
    
    self.videoQueueCollectionView.frame = expandeCollectionViewFrame;
    
    // 2. Expand the content size of the scroller accordingly
    
    
    [scrollView setContentSize:CGSizeMake(self.videoQueueCollectionView.frame.size.width + kVideoQueueCellWidth,
                                          scrollView.frame.size.height)];
    
    
    // 3. If the content is bigger than the scrollView frame

    if(expandeCollectionViewFrame.size.width + kVideoQueueCellWidth > scrollView.frame.size.width)
    {
        
        // 4. snap the offset back (which would bring the cells to the left)
        
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x + kVideoQueueCellWidth, 0.0)];
        
        
        // 5. snap the cells to the right (which will bring them back to where they where before)
        
        self.videoQueueCollectionView.center = CGPointMake(self.videoQueueCollectionView.center.x + kVideoQueueCellWidth,
                                                           self.videoQueueCollectionView.center.y);
        
        // 6. After leaving the conditional the cells are where they where but with the content offset to the left so that it can scroll
        
        leftmostOffset = scrollView.contentOffset;
        
    }
    
    
    
    
    // 7. Load the new cell
    
    [self.videoQueueCollectionView reloadData];
    
    
    
    [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                          delay: 0.5f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                        
                         
                         self.videoQueueCollectionView.center = CGPointMake(self.videoQueueCollectionView.center.x - kVideoQueueCellWidth,
                                                                            self.videoQueueCollectionView.center.y);
                         
     } completion: ^(BOOL finished) {

         
     }];
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

-(void)showRemovedLastVideo
{
    CGRect contractedCollectionViewFrame = self.videoQueueCollectionView.frame;
    contractedCollectionViewFrame.size.width -= kVideoQueueCellWidth;
    
    self.videoQueueCollectionView.frame = contractedCollectionViewFrame;
    
    [self.videoQueueCollectionView reloadData];
    
    
//    if(contractedCollectionViewFrame.size.width + kVideoQueueCellWidth < scrollView.frame.size.width)
//    {
//        
//        // 4. snap the offset back (which would bring the cells to the left)
//        
//        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x - kVideoQueueCellWidth, 0.0)];
//        
//        
//        // 5. snap the cells to the right (which will bring them back to where they where before)
//        
//        self.videoQueueCollectionView.center = CGPointMake(self.videoQueueCollectionView.center.x - kVideoQueueCellWidth,
//                                                           self.videoQueueCollectionView.center.y);
//        
//        // 6. After leaving the conditional the cells are where they where but with the content offset to the left so that it can scroll
//        
//        leftmostOffset = scrollView.contentOffset;
//        
//    }
    
    [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                          delay: 0.5f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         
                         
                         self.videoQueueCollectionView.center = CGPointMake(self.videoQueueCollectionView.center.x + kVideoQueueCellWidth,
                                                                            self.videoQueueCollectionView.center.y);
                         
                     } completion: ^(BOOL finished) {
                         
                         
                     }];
}


-(void)clearVideoQueue
{
    [self.videoQueueCollectionView setFrame:collectionViewStartFrame];
    [self.videoQueueCollectionView reloadData];
}

@end
