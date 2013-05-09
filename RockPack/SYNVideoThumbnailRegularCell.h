//
//  SYNVideoThumbnailRegularCell.h
//  rockpack
//
//  Created by Nick Banks on 03/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kChannelThumbnailDisplayModeStandard = 0,
    kChannelThumbnailDisplayModeEdit = 1
} kChannelThumbnailDisplayMode;

@interface SYNVideoThumbnailRegularCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) UIViewController *viewControllerDelegate;

@property (nonatomic) kChannelThumbnailDisplayMode displayMode;

@end
