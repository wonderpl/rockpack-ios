//
//  SYNChannelCategoryTableHeader.m
//  rockpack
//
//  Created by Mats Trovik on 24/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNChannelCategoryTableHeader.h"
#import "UIFont+SYNFont.h"

@implementation SYNChannelCategoryTableHeader

-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if(self)
    {
        UIView* subView = [[[NSBundle mainBundle] loadNibNamed:@"SYNChannelCategoryTableHeader" owner:self options:nil] objectAtIndex:0];
        [self.backgroundImage removeFromSuperview];
        self.backgroundView = self.backgroundImage;
        self.titleLabel.font = [UIFont rockpackFontOfSize:self.titleLabel.font.pointSize];
        [self addSubview:subView];
    }
    return self;
}



@end
