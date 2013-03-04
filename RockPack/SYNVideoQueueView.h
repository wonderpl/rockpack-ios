//
//  SYNVideoQueueView.h
//  rockpack
//
//  Created by Michael Michailidis on 25/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNAbstractViewController.h"
#import "VideoInstance.h"

@interface SYNVideoQueueView : UIView {
    
    UIImageView* backgroundImageView;
    
    
    
    UIImageView* messageView;
    
    UIView* dropZoneView;
    
    UICollectionView* videoQueueCollectionView;
}


@property (nonatomic, strong) UICollectionView* videoQueueCollectionView;

@property (nonatomic, strong) UIButton* deleteButton;
@property (nonatomic, strong) UIButton* channelButton;
@property (nonatomic, strong) UIButton* existingButton;

@property (nonatomic, strong) UIImageView* backgroundImageView;

- (void) showMessage:(BOOL)show;

- (void) addVideoToQueue: (VideoInstance *) videoInstance;


-(void)clearVideoQueue;


@end
