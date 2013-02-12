//
//  SYNCategoryItemView.m
//  rockpack
//
//  Created by Michael Michailidis on 12/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCategoryItemView.h"


@implementation SYNCategoryItemView

@synthesize mainLabel;

- (id)initWithCategory:(Category *)category andFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        self.mainLabel.textAlignment = NSTextAlignmentCenter;
        self.mainLabel.text = category.name;
        [self addSubview:mainLabel];
        
    }
    return self;
}



@end
