//
//  SYNPageView.m
//  rockpack
//
//  Created by Nick Banks on 17/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNPageView.h"

@interface SYNPageView ()

@property (nonatomic, strong) UIView *positionIndicatorView;

@end


@implementation SYNPageView

- (id) initWithFrame: (CGRect) frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self _initSubviews];
    }
    
    return self;
}


- (instancetype)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder: coder]))
    {
        [self _initSubviews];
    }
    
    return self;
}


- (void) _initSubviews
{
    // Initialization code
    
    // Grey background
    self.backgroundColor = [UIColor colorWithRed: 0.898f
                                           green: 0.898f
                                            blue: 0.898f
                                           alpha: 1.0f];
    // White foreground
    CGRect whiteRect = self.bounds;
    whiteRect.size.height -= 1;
    
    UIView *whiteView = [[UIView alloc] initWithFrame: whiteRect];
    whiteView.backgroundColor = [UIColor whiteColor];
    
    [self addSubview: whiteView];
    
    // Green/blue position indicator
    CGRect positionIndicatorRect = whiteRect;
    
    // This will need to change if we have more pages, but for now make it a third of the width
    positionIndicatorRect.size.width = positionIndicatorRect.size.width / 3;
    
    self.positionIndicatorView = [[UIView alloc] initWithFrame: positionIndicatorRect];
    
    self.positionIndicatorView.backgroundColor =  [UIColor colorWithRed: 0.043f
                                                                  green: 0.650f
                                                                   blue: 0.670f
                                                                  alpha: 1.0f];
    
    [self addSubview: self.positionIndicatorView];

}


// Set the position of the indicator
- (void) setPosition: (float) position
{
    CGRect frameRect = self.frame;
    
    CGRect positionIndicatorRect = self.positionIndicatorView.frame;
    
    CGFloat offsetPixels = (frameRect.size.width - positionIndicatorRect.size.width) * position;

    positionIndicatorRect.origin.x = offsetPixels;
    
    self.positionIndicatorView.frame = positionIndicatorRect;
}


@end
