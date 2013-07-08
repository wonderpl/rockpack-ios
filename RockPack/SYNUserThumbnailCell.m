//
//  SYNUserThumbnailCell.m
//  rockpack
//
//  Created by Michael Michailidis on 08/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNUserThumbnailCell.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

@implementation SYNUserThumbnailCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.nameLabel.font = [UIFont boldRockpackFontOfSize: self.nameLabel.font.pointSize];
    
    
    // Required to make cells look good when wobbling (delete)
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = UIScreen.mainScreen.scale;
    
}


-(void)setImageUrlString:(NSString *)imageUrlString
{
    if(!imageUrlString) // cancel the existing network operation
    {
        [self.imageView setImageWithURL: nil
                       placeholderImage: [UIImage imageNamed: @"PlaceholderChannel.png"]
                                options: SDWebImageRetryFailed];
    }
    
    
    [self.imageView setImageWithURL: [NSURL URLWithString: imageUrlString]
                   placeholderImage: [UIImage imageNamed: @"PlaceholderChannel.png"]
                            options: SDWebImageRetryFailed];
    
}


@end
