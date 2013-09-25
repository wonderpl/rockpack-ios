//
//  SYNChannelThumbnailCell.h
//  rockpack
//
//  Created by Nick Banks on 11/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNHighlightableCollectionViewCell.h"
#import <UIKit/UIKit.h>

@interface SYNChannelThumbnailCell : SYNHighlightableCollectionViewCell

@property (nonatomic, strong) IBOutlet UIButton *displayNameButton;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIImageView* shadowOverlayImageView;
@property (nonatomic, strong) IBOutlet UILabel *displayNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) NSString *channelTitle;
@property (nonatomic, strong) NSString* imageUrlString;
@property (nonatomic, weak) id viewControllerDelegate;

@end
