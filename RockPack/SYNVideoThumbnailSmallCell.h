//
//  SYNVideoThumbnailSmallCell.h
//  rockpack
//
//  Created by Nick Banks on 30/01/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNVideoThumbnailSmallCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, getter = isColour) BOOL colour;

- (void) setVideoImageViewImage: (NSString*) imageURLString;

@end
