//
//  SYNBackButtonControl.m
//  rockpack
//
//  Created by Michael Michailidis on 12/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNBackButtonControl.h"
#import "UIFont+SYNFont.h"

@implementation SYNBackButtonControl

-(id)init
{
    if (self = [super init])
    {
        
        // == Back Button == //
        
        
        arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ButtonBackHighlighted"]];
        [self addSubview:arrowImageView];
        
        
        // == UIView == //
        
        titleBGView = [[UIView alloc] init];
        titleBGView.backgroundColor = [UIColor whiteColor];
        CGRect titleBGRect = CGRectZero;
        titleBGRect.origin.x = arrowImageView.frame.size.width;
        titleBGRect.size.height = arrowImageView.frame.size.height;
        titleBGView.frame = titleBGRect;
        
        // == UILabel == //
        
        titleLabel = [[UILabel alloc] init];
        CGRect titleRect = CGRectZero;
        titleRect.origin.x = 10.0;
        titleRect.origin.y = 10.0;
        titleLabel.frame = titleRect;
        titleLabel.font = [UIFont rockpackFontOfSize:18.0];
        titleLabel.textColor = [UIColor lightGrayColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.backgroundColor = [UIColor clearColor];
        [titleBGView addSubview:titleLabel];
        
        // == Over Button == //
        
        overButton = [UIButton buttonWithType:UIButtonTypeCustom];
        overButton.backgroundColor = [UIColor clearColor];
        [self addSubview:overButton];
        
    }
    
    return self;
}


#pragma mark - UIControl Methods

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [overButton addTarget:target action:action forControlEvents:controlEvents];
}

- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [overButton removeTarget:target action:action forControlEvents:controlEvents];
}

- (NSArray *)actionsForTarget:(id)target forControlEvent:(UIControlEvents)controlEvent
{
    return [overButton actionsForTarget:target forControlEvent:controlEvent];
}

#pragma mark - Set the Title Methods

-(void)setBackTitle:(NSString*)backTitle
{
    CGSize titleSize = [backTitle sizeWithFont:titleLabel.font];
    CGRect titleLabelRect = titleLabel.frame;
    titleLabelRect.size = titleSize;
    titleLabel.frame = titleLabelRect;
    titleLabel.text = backTitle;
    
    CGRect titleBGFrame = titleBGView.frame;
    titleBGFrame.size.width = titleLabelRect.size.width + 20.0;
    titleBGView.frame = titleBGFrame;
    
    CGSize totalSize = CGSizeZero;
    totalSize.width = arrowImageView.frame.size.width + titleBGView.frame.size.width;
    totalSize.height = arrowImageView.frame.size.height;
    
    CGRect overButtonFrame = CGRectZero;
    overButtonFrame.size = totalSize;
    overButton.frame = overButtonFrame;
}


#pragma mark - Initialiser Method


+(id)backButton
{
    return [[self alloc] init];
}


@end
