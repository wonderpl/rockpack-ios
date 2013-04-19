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


-(id)initWithSearchType:(SearchTabType)itsType
{
    if (self = [super init])
    {
        backgroundImageOn = [UIImage imageNamed:@"SearchTab"];
        backgroundImageOff = [UIImage imageNamed:@"SearchTabHighlighted"];
        
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
        
        bgImageView = [[UIImageView alloc] initWithImage:backgroundImageOn];
        
        [self addSubview:bgImageView];
        
        
        
        
        titleLabel = [[UILabel alloc] initWithFrame:self.frame];
        titleLabel.font = [UIFont rockpackFontOfSize:20.0];
        titleLabel.textColor = onColor;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        
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

-(void)setSelected:(BOOL)selected
{
    if(selected)
    {
        bgImageView.image = backgroundImageOff;
    }
    else
    {
        bgImageView.image = backgroundImageOn;
    }
}

@end
