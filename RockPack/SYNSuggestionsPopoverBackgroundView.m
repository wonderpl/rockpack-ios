//
//  SYNSuggestionsPopoverBackgroundView.m
//  rockpack
//
//  Created by Michael Michailidis on 06/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSuggestionsPopoverBackgroundView.h"

#define CONTENT_INSET 10.0
#define CAP_INSET 25.0
#define ARROW_BASE 25.0
#define ARROW_HEIGHT 25.0

@implementation SYNSuggestionsPopoverBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.arrowOffset = 0.0;
        
        
        self.backgroundColor = [UIColor grayColor];
        
        _backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"border.png"]];
        
        _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
        
        [self addSubview:_backgroundView];
        [self addSubview:_arrowView];
    }
    return self;
}

- (CGFloat) arrowOffset
{
    return _arrowOffset;
}

-(void)setArrowOffset:(CGFloat)arrowOffset
{
    _arrowOffset = arrowOffset;
}

+(CGFloat)arrowHeight
{
    return 25.0;
}

+(CGFloat)arrowBase
{
    return 25.0;
}

-(UIPopoverArrowDirection)arrowDirection
{
    return UIPopoverArrowDirectionUp;
}

+(UIEdgeInsets)contentViewInsets{
    return UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
}

+(BOOL)wantsDefaultContentAppearance
{
    return YES;
}

@end
