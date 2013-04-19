//
//  SYNSearchTabView.m
//  rockpack
//
//  Created by Michael Michailidis on 19/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchTabView.h"
#import "UIFont+SYNFont.h"

@implementation SYNSearchTabView
@synthesize selected;

-(id)initWithSearchType:(SearchTabType)itsType
{
    if (self = [super init])
    {
        backgroundImageOff = [UIImage imageNamed:@"SearchTab"];
        backgroundImageOn = [UIImage imageNamed:@"SearchTabHighlighted"];
        
        self.frame = CGRectMake(0.0, 0.0, backgroundImageOn.size.width, backgroundImageOn.size.height);
        
        switch (itsType) {
            case SearchTabTypeVideos:
                typeTitle = @"VIDEOS";
                break;
                
            case SearchTabTypeChannels:
                typeTitle = @"CHANNELS";
                break;
        }
        
        
        
        onColor = [UIColor whiteColor];
        offColor = [UIColor darkGrayColor];
        
        bgImageView = [[UIImageView alloc] initWithImage:backgroundImageOff];
        
        [self addSubview:bgImageView];
        
        CGRect labelFrame = self.frame;
        labelFrame.origin.y += 2.0f;
        titleLabel = [[UILabel alloc] initWithFrame:labelFrame];
        titleLabel.font = [UIFont rockpackFontOfSize:18.0];
        titleLabel.textColor = offColor;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self setNumberOfItems:0 animated:NO];
        
        [self addSubview:titleLabel];
        
        overButton = [UIButton buttonWithType:UIButtonTypeCustom];
        overButton.frame = self.frame;
        overButton.backgroundColor = [UIColor clearColor];
        
        [self addSubview:overButton];
        
        
    }
    return self;
}

+(id)tabViewWithSearchType:(SearchTabType)itsType
{
    return [[self alloc] initWithSearchType:itsType];
}

-(void)setNumberOfItems:(NSInteger)numberOfItems animated:(BOOL)animated
{
    
    titleLabel.text = [NSString stringWithFormat:@"%@ (%i)", typeTitle, numberOfItems];
}

#pragma mark - Control Methods

-(void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [overButton addTarget:target action:action forControlEvents:controlEvents];
}

-(void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [overButton removeTarget:target action:action forControlEvents:controlEvents];
}

-(void)setSelected:(BOOL)value
{
    selected = value;
    if(value)
    {
        bgImageView.image = backgroundImageOn;
        titleLabel.textColor = onColor;
    }
    else
    {
        bgImageView.image = backgroundImageOff;
        titleLabel.textColor = offColor;
    }
}

@end
