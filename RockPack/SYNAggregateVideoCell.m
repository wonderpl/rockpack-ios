//
//  SYNAggregateVideoCell.m
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAggregateVideoCell.h"

@implementation SYNAggregateVideoCell

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.likeLabel.font = [UIFont rockpackFontOfSize:self.likeLabel.font.pointSize];
}


-(void)setCoverImageWithString:(NSString*)imageString
{
    if(!videoImageView) {
        videoImageView = [[UIImageView alloc] initWithFrame:self.imageContainer.frame];
        [self.imageContainer addSubview:videoImageView];
    }
        
    
    [videoImageView setImageWithURL: [NSURL URLWithString: imageString]
                   placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                            options: SDWebImageRetryFailed];
    
    
    
    
}


-(void)setCoverImageWithArray:(NSArray*)imageArray
{
    
    
    
}

@end
