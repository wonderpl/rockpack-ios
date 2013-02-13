//
//  SYNCategoryItemView.m
//  rockpack
//
//  Created by Michael Michailidis on 12/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCategoryItemView.h"
#import "UIFont+SYNFont.h"


@implementation SYNCategoryItemView

@synthesize dataItemId;

- (id)initWithName:(NSString *)name Id:(NSString*)cid andFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.dataItemId = cid;
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        label.font = [UIFont boldRockpackFontOfSize: 14.0f];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = name;
        [self addSubview:label];
        
    }
    return self;
}



@end
