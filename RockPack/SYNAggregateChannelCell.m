//
//  SYNAggregateChannelCell.m
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAggregateChannelCell.h"

@implementation SYNAggregateChannelCell

-(void)awakeFromNib
{
    [super awakeFromNib];
}

-(void)setCoverImageWithString:(NSString*)imageString
{
    
}


-(void)setCoverImageWithArray:(NSArray*)imageArray
{
    
}

-(void)setTitleMessage:(NSString*)message
{
    self.messageLabel.text = message;
}

@end
