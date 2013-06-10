//
//  SYNRefreshButton.m
//  rockpack
//
//  Created by Michael Michailidis on 11/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNRefreshButton.h"
#import "AppConstants.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNRefreshButton ()

@property (nonatomic, strong) UIImageView* image;
@property (nonatomic, strong) UIButton* button;

@end

@implementation SYNRefreshButton

+ (id) refreshButton
{
    return [[self alloc] init];
}


- (id) init
{
    if (self = [super initWithFrame: CGRectZero])
    {
        UIImageView* bg = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"ButtonRefresh"]];
        [self addSubview: bg];
        
        self.frame = bg.frame;
        
        self.image = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"ButtonRefreshArrow"]];
        self.image.center = bg.center;
        self.image.frame = CGRectIntegral(self.image.frame);
        [self addSubview: self.image];
        
        self.self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.frame = bg.frame;
        
        self.spinner = [[UIActivityIndicatorView alloc] init];
        self.spinner.color = [UIColor colorWithRed:162.0/255.0 green:172.0/255.0 blue:176.0/255.0 alpha:1.0];
        
        
        self.spinner.frame = bg.frame;
        
        [self addSubview: self.button];
        [self addSubview:self.spinner];
    }
    
    return self;
}


#pragma mark - UIControl Methods

- (void) addTarget: (id) target
            action: (SEL) action
  forControlEvents: (UIControlEvents) controlEvents
{
    [self.button addTarget: target
               action: action
     forControlEvents: controlEvents];
}


- (void) removeTarget: (id) target
               action: (SEL) action
     forControlEvents: (UIControlEvents) controlEvents
{
    [self.button removeTarget: target
                  action: action
        forControlEvents: controlEvents];
}

- (NSArray *) actionsForTarget: (id) target
               forControlEvent: (UIControlEvents) controlEvent
{
    return [self.button actionsForTarget: target
                    forControlEvent: controlEvent];
}


#pragma mark - Animation Methods

- (void) spinRefreshButton: (BOOL) spin
{
        
    if (spin)
    {
        [self.spinner startAnimating];
        self.image.alpha = 0.0;

    }
    else
    {
        [self.spinner stopAnimating];
        self.image.alpha = 1.0;
    }
}


- (void) animationDidStop: (CAAnimation *) theAnimation
                 finished: (BOOL) finished
{
	if (finished)
	{
		[self spinRefreshButton: TRUE];
	}
}


#pragma mark - API

- (void) startRefreshCycle
{
    [self spinRefreshButton: TRUE];
}


- (void) endRefreshCycle
{
    [self spinRefreshButton: FALSE];
}

@end
