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
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLoadMore"]];
}


- (void) setShowsLoading: (BOOL)showsLoading
{
    if (_showsLoading == showsLoading)
        return;
    
    _showsLoading = showsLoading;
    
    if(_showsLoading)
    {
        self.loadMoreButton.hidden = YES;
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
        
    }
    else
    {
        self.loadMoreButton.hidden = NO;
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
    }
}


@end
