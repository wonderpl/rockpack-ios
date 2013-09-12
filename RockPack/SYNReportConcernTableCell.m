//
//  SYNReportConcernTableCell.m
//  rockpack
//
//  Created by Nick Banks on 14/05/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNReportConcernTableCell.h"
#import "UIFont+SYNFont.h"

@implementation SYNReportConcernTableCell


- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [UIFont rockpackFontOfSize: self.titleLabel.font.pointSize];
    
    if (IS_IOS_7_OR_GREATER)
    {
        self.backgroundColor = [UIColor clearColor];
        [self.backgroundImage removeFromSuperview];
        self.highlightedViewiOS7.hidden = YES;
        self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y - 2.0f, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);
    }
    
    else
    {
        [self.highlightedViewiOS7 removeFromSuperview];
    }
}



@end


