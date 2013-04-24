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
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Accessors

-(void)setPage:(NSInteger)page
{
    if(!self.scrollEnabled)
        return;
    
    CGPoint newPoint = CGPointMake(page * [[SYNDeviceManager sharedInstance] currentScreenWidth], 0.0);
    [self setContentOffset:newPoint animated:YES];
    
}



-(NSInteger)page
{
    CGFloat currentScrollerOffset = self.contentOffset.x;
    int pageWidth = (int)self.contentSize.width / self.subviews.count;
    NSInteger page = roundf((currentScrollerOffset / pageWidth)); // 0 indexed
    return page;
    
}

@end
