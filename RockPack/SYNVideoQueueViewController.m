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

@end

@implementation SYNVideoQueueViewController

-(void)loadView
{
    self.view = [[SYNVideoQueueView alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Delegate Methods

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
    // Assume for now, that we can handle this
    BOOL handledInAbstractView = YES;
    
    DebugLog (@"Selecting image well cell does nothing");
    
    return handledInAbstractView;
}

@end
