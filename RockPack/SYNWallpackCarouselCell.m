//
//  SYNWallpackCarouselCell.m
//  RockPack
//
//  Created by Nick Banks on 16/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNWallpackCarouselCell.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNWallpackCarouselCell ()

@property (strong, nonatomic) UIImageView* mainImage;

@end

@implementation SYNWallpackCarouselCell

@synthesize mainImage = _mainImage;

- (id) initWithFrame: (CGRect) frame
{
    if ((self = [super initWithFrame:frame]))
    {
        UIImageView *circleBackground = [[UIImageView alloc] initWithFrame: CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        circleBackground.image = [UIImage imageNamed: @"WallpackCarouselCircleBackground.png"];
        
        [self.contentView addSubview: circleBackground];
        
        self.mainImage = [[UIImageView alloc] initWithFrame: CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        [self.contentView addSubview: self.mainImage];
    }
    
    return self;
}

- (void) setImage: (UIImage *) image;
{
    self.mainImage.contentMode = UIViewContentModeCenter;
    self.mainImage.image = image;
    CALayer *mask = [CALayer layer];
    mask.contents = (id)[[UIImage imageNamed: @"WallpackCarouselCircleAlpha.png"] CGImage];
    mask.frame = CGRectMake(0, 0, 200, 200);
    self.mainImage.layer.mask = mask;
    self.mainImage.layer.masksToBounds = YES;
}


@end

