//
//  SYNVideoQueueViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 25/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNVideoQueueViewController.h"
#import "SYNVideoQueueView.h"
#import "SYNVideoSelection.h"
#import "SYNVideoQueueCell.h"
#import "Video.h"
#import "VideoInstance.h"


@interface SYNVideoQueueViewController ()

@property (nonatomic, readonly) SYNVideoQueueView* videoQueueView;

@end

@implementation SYNVideoQueueViewController

@dynamic videoQueueView;

@synthesize delegate;

-(void)loadView
{
    SYNVideoQueueView* videoQView = [[SYNVideoQueueView alloc] init];
    videoQView.videoQueueCollectionView.dataSource = self;
    videoQView.videoQueueCollectionView.delegate = self;
    self.view = videoQView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self reloadData];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UICollectionViewDelegate Methods

- (NSInteger) collectionView: (UICollectionView *) cv numberOfItemsInSection: (NSInteger) section {
    
    return SYNVideoSelection.sharedVideoSelectionArray.count;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) cv cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    UICollectionViewCell *cell = nil;
    
    SYNVideoQueueCell *videoQueueCell = [cv dequeueReusableCellWithReuseIdentifier: @"VideoQueueCell"
                                                                      forIndexPath: indexPath];
    
    VideoInstance *videoInstance = [SYNVideoSelection.sharedVideoSelectionArray objectAtIndex: indexPath.item];
    
    // Load the image asynchronously
    videoQueueCell.VideoImageViewImage = videoInstance.video.thumbnailURL;
    
    cell = videoQueueCell;
    
    return cell;
}

- (BOOL) collectionView: (UICollectionView *) cv didSelectItemAtIndexPathAbstract: (NSIndexPath *) indexPath
{
    
    BOOL handledInAbstractView = YES;
    
    DebugLog (@"Selecting image well cell does nothing");
    
    return handledInAbstractView;
}

-(SYNVideoQueueView*)videoQueueView
{
    return (SYNVideoQueueView*)self.view;
}

#pragma mark - Delegate

-(void)setDelegate:(id<SYNVideoQueueDelegate>)del
{
    delegate = del;
    
    [self.videoQueueView.deleteButton addTarget:self action: @selector(clearVideoQueue) forControlEvents: UIControlEventTouchUpInside];
    
    [self.videoQueueView.channelButton addTarget:self.delegate action: @selector(createChannelFromVideoQueue) forControlEvents: UIControlEventTouchUpInside];
}

- (void) clearVideoQueue
{
    
    
    [self.videoQueueView showMessage:YES];
    
    self.videoQueueView.channelButton.enabled = NO;
    self.videoQueueView.channelButton.selected = NO;
    self.videoQueueView.deleteButton.enabled = NO;
    
    [SYNVideoSelection.sharedVideoSelectionArray removeAllObjects];
    
    [self.videoQueueView.videoQueueCollectionView reloadData];
}

-(void)reloadData
{
    [self.videoQueueView.videoQueueCollectionView reloadData];
    
}

@end
