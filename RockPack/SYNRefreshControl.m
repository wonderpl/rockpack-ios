//
//  SYNRefreshButton.m
//  rockpack
//
//  Created by Michael Michailidis on 11/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNRefreshControl.h"
#import "AppConstants.h"
#import <QuartzCore/QuartzCore.h>



@implementation SYNRefreshControl

+ (id) refreshControl
{
    return [[self alloc] init];
}


- (id) init
{
    if (self = [super initWithFrame: CGRectZero])
    {
        
        
        
        iconImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"ButtonRefreshArrow"]];
        [self addSubview: iconImageView];
        
        self.frame = iconImageView.frame;
        
        
        self.spinner = [[UIActivityIndicatorView alloc] init];
        self.spinner.color = [UIColor colorWithRed:162.0/255.0 green:172.0/255.0 blue:176.0/255.0 alpha:1.0];
        
        
        self.spinner.frame = self.frame;
        
        [self addSubview:self.spinner];
    }
    
    return self;
}





#pragma mark - Animation Methods

- (void) spinRefreshButton: (BOOL) spin
{
        
    if (spin)
    {
        [self.spinner startAnimating];
        iconImageView.alpha = 0.0;

    }
    else
    {
        [self.spinner stopAnimating];
        iconImageView.alpha = 1.0;
    }
}


- (void) animationDidStop: (CAAnimation *) theAnimation
                 finished: (BOOL) finished
{
	if (finished)
	{
		[self spinRefreshButton: YES];
	}
}


#pragma mark - API

- (void) start
{
    [self spinRefreshButton: YES];
}


- (void) stop
{
    [self spinRefreshButton: NO];
}

@end
