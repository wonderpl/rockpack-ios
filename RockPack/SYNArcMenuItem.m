//
//  SYNArcMenuItem.m
//  rockpack
//
//  Created by Nick Banks on 12/08/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//
//  Based on https://github.com/levey/AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 Levey & Other Contributors. All rights reserved.

#import "SYNArcMenuItem.h"

static inline CGRect ScaleRect(CGRect rect, float n)
{
    return CGRectMake((rect.size.width - rect.size.width * n) / 2,
                      (rect.size.height - rect.size.height * n) / 2,
                      rect.size.width * n,
                      rect.size.height * n);
}

@implementation SYNArcMenuItem

#pragma mark - initialization & cleaning up
- (id) initWithImage: (UIImage *) img
       highlightedImage: (UIImage *) himg
       contentImage: (UIImage *) cimg
       highlightedContentImage: (UIImage *) hcimg;
{
    if ((self = [super init]))
    {
        self.image = img;
        self.highlightedImage = himg;
        self.userInteractionEnabled = YES;
        _contentImageView = [[UIImageView alloc] initWithImage: cimg];
        _contentImageView.highlightedImage = hcimg;
        [self addSubview: _contentImageView];
    }
    
    return self;
}

#pragma mark - UIView's methods

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    self.bounds = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    
    float width = self.contentImageView.image.size.width;
    float height = _contentImageView.image.size.height;
    self.contentImageView.frame = CGRectMake(self.bounds.size.width / 2 - width / 2, self.bounds.size.height / 2 - height / 2, width, height);
}


- (void) touchesBegan: (NSSet *) touches
            withEvent: (UIEvent *) event
{
    self.highlighted = YES;
    
    if ([self.delegate respondsToSelector: @selector(arcMenuItemTouchesBegan:)])
    {
        [self.delegate arcMenuItemTouchesBegan: self];
    }
}


- (void) touchesMoved: (NSSet *) touches
            withEvent: (UIEvent *) event
{
    // if move out of 2x rect, cancel highlighted.
    CGPoint location = [[touches anyObject] locationInView: self];
    
    if (!CGRectContainsPoint(ScaleRect(self.bounds, 2.0f), location))
    {
        self.highlighted = NO;
    }
}


- (void) touchesEnded: (NSSet *) touches
            withEvent: (UIEvent *) event
{
    self.highlighted = NO;
    // if stop in the area of 2x rect, response to the touches event.
    CGPoint location = [[touches anyObject] locationInView: self];
    
    if (CGRectContainsPoint(ScaleRect(self.bounds, 2.0f), location))
    {
        if ([self.delegate respondsToSelector: @selector(arcMenuItemTouchesEnd:)])
        {
            [self.delegate arcMenuItemTouchesEnd: self];
        }
    }
}


- (void) touchesCancelled: (NSSet *) touches
                withEvent: (UIEvent *) event
{
    self.highlighted = NO;
}


- (void) setHighlighted: (BOOL) highlighted
{
    [super setHighlighted: highlighted];
    [self.contentImageView setHighlighted: highlighted];
}


@end