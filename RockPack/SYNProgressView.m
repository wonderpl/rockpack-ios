//
//  SYNProgressView.m
//  rockpack
//
//  Created by Nick Banks on 10/09/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNProgressView.h"

@interface SYNProgressView ()

@property (nonatomic, strong) UIImageView *progressIndicatorImageView;

@end


@implementation SYNProgressView

- (id) initWithFrame: (CGRect) frame
{
    if ((self = [super initWithFrame: frame]))
    {
        [self initProgressViewSubviews];
    }
    
    return self;
}


- (instancetype) initWithCoder: (NSCoder *) coder
{
    if ((self = [super initWithCoder: coder]))
    {
        [self initProgressViewSubviews];
    }
    
    return self;
}


- (void) initProgressViewSubviews
{
    // Our progress indicator is a subview of out track image view
    self.progressIndicatorImageView = [[UIImageView alloc] initWithFrame: self.bounds];
    
    self.backgroundColor = [UIColor clearColor];
    self.progressIndicatorImageView.backgroundColor = [UIColor clearColor];
    
    // We might want to remove this
    [self setProgress: 0.5f];
    
    [self addSubview: self.progressIndicatorImageView];
}


// Set the position of the indicator
- (void) setProgress: (float) progress
{
    CGRect progressIndicatorViewRect = self.bounds;
    
    CGFloat progressBarWidth = progressIndicatorViewRect.size.width * progress;
    
    progressIndicatorViewRect.size.width = progressBarWidth;
    
    self.progressIndicatorImageView.frame = progressIndicatorViewRect;
}


- (void) setTrackImage: (UIImage *) trackImage
{
    self.image = trackImage;
}


- (void) setProgressImage: (UIImage *) progressImage
{
    self.progressIndicatorImageView.image = progressImage;
}


@end
