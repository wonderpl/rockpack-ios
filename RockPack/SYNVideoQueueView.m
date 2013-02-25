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

@implementation SYNVideoQueueView

@synthesize videoQueueCollectionView;
@synthesize delegate;
@synthesize highlighted;

-(id)init
{
    CGRect stdFrame = CGRectMake(0, 573+kVideoQueueEffectiveHeight, 1024, kVideoQueueEffectiveHeight);
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
        
        
        
        [self addSubview:deleteButton];
        
        
        
        // == New Button
        
        newButton = [UIButton buttonWithType: UIButtonTypeCustom];
        newButton.frame = CGRectMake(663, 35, 50, 50);
        
        [newButton setImage:[UIImage imageNamed:@"ButtonVideoWellNew.png"] forState: UIControlStateNormal];
        
        [newButton setImage:[UIImage imageNamed: @"ButtonVideoWellNewHighlighted.png"] forState: UIControlStateSelected];
        
        
        [self addSubview:newButton];
        
        
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
    
    
    [deleteButton addTarget:delegate action: @selector(clearVideoQueue) forControlEvents: UIControlEventTouchUpInside];
    
    [newButton addTarget:self.delegate action: @selector(createChannelFromVideoQueue) forControlEvents: UIControlEventTouchUpInside];
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




@end
