//
//  SYNChannelCoverImageCell.h
//  rockpack
//
//  Created by Mats Trovik on 08/05/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ALAsset;
@class ALAssetsLibrary;

@interface SYNChannelCoverImageCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView* channelCoverImageView;
@property (nonatomic, weak) IBOutlet UIImageView *glossImage;

- (void) setTitleText: (NSString*) titleText;
- (void) setimageFromAsset: (ALAsset*) asset;

@end
