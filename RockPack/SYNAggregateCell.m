//
//  SYNAggregateCell.m
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAggregateCell.h"

@implementation SYNAggregateCell

-(void)awakeFromNib
{
    self.messageLabel.font = [UIFont rockpackFontOfSize:self.messageLabel.font.pointSize];
}

-(void)setCoverImagesFromArray:(NSArray*)array
{
    
}

@end
