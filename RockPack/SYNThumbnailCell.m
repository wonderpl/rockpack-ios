//
//  SYNThumbnailCell.m
//  rockpack
//
//  Created by Nick Banks on 18/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNThumbnailCell.h"

@implementation SYNThumbnailCell

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}

- (id) initWithFrame: (CGRect) frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed: @"SYNThumbnail"
                                                              owner: self
                                                             options:nil];
    
        if ([arrayOfViews count] < 1)
        {
            return nil;
        }
    
        if (![[arrayOfViews objectAtIndex: 0] isKindOfClass: [UICollectionViewCell class]])
        {
            return nil;
        }
    
        self = [arrayOfViews objectAtIndex: 0];
    
}
    
    return self;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
