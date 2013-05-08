//
//  SYNChannelCoverImageCell.h
//  rockpack
//
//  Created by Mats Trovik on 08/05/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AVURLAsset;
@class ALAssetsLibrary;

@interface SYNChannelCoverImageCell : UICollectionViewCell

@property (nonatomic,weak) IBOutlet UIImageView* channelCoverImageView;
@property (weak, nonatomic) IBOutlet UIImageView *glossImage;

-(void)configureWithUrlAsset:(AVURLAsset*)asset fromLibrary:(ALAssetsLibrary*)library;
-(void)setTitleText:(NSString*)titleText;
@end