//
//  SYNContainerScrollView.m
//  rockpack
//
//  Created by Michael Michailidis on 24/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNContainerScrollView.h"
#import "SYNDeviceManager.h"

@implementation SYNContainerScrollView

@dynamic page;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        // Initialization code
    }
    
    return self;
}


#pragma mark - Accessors

- (void )setPage: (NSInteger) page
        animated: (BOOL) animated
{
    if (!self.scrollEnabled)
        return;
    
    CGPoint newPoint = CGPointMake(page * [SYNDeviceManager.sharedInstance currentScreenWidth], 0.0);
    
    [self setContentOffset: newPoint
                  animated: YES];
    
    // we do not hold the page as an ivar because it is calculated in the getter
}


- (void) setPage: (NSInteger) page
{
    [self setPage: page
         animated: NO];
}


- (NSInteger) page
{
    CGFloat currentScrollerOffset = self.contentOffset.x;
    int pageWidth = (int)self.contentSize.width / self.subviews.count;
    NSInteger page = roundf((currentScrollerOffset / pageWidth)); // 0 indexed
    return page;
}

@end
