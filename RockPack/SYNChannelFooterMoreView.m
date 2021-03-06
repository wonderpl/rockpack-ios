//
//  SYNChannelFooterMoreView.m
//  rockpack
//
//  Created by Michael Michailidis on 04/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNChannelFooterMoreView.h"

@implementation SYNChannelFooterMoreView

- (void) awakeFromNib
{
    self.activityIndicator.hidden = YES;
    
    self.activityIndicator.color = [UIColor colorWithRed: (11.0/255.0)
                                                   green: (166.0/255.0)
                                                    blue: (171.0/255.0)
                                                   alpha: (1.0)];
    
    self.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"BackgroundLoadMore"]];
}


- (void) setShowsLoading: (BOOL)showsLoading
{
    if (_showsLoading == showsLoading)
        return;
    
    _showsLoading = showsLoading;
    
    if(_showsLoading)
    {
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
        
    }
    else
    {
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
    }
}


@end
