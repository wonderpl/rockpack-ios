//
//  SYNChannelThumbnailCell.h
//  rockpack
//
//  Created by Nick Banks on 11/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNChannelThumbnailCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, strong) IBOutlet UIButton *rockItButton;
@property (nonatomic, strong) IBOutlet UIButton *shareItButton;
@property (nonatomic, strong) IBOutlet UILabel *rockItNumberLabel;

@end
