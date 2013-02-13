//
//  SYNCategoryItemView.m
//  rockpack
//
//  Created by Michael Michailidis on 12/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCategoryItemView.h"
#import "UIFont+SYNFont.h"
#import "UIColor+SYNColor.h"
#import <QuartzCore/QuartzCore.h>

@implementation SYNCategoryItemView

@synthesize topGlowImageView;
@synthesize label;

- (id)initWithTabItemModel:(TabItem*)tabItemModel andFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.tag = [tabItemModel.uniqueId integerValue];
        
        NSString* itemName = tabItemModel.name;
        
        UIFont* fontToUse = [UIFont rockpackFontOfSize: 14.0f];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        label.font = fontToUse;
        label.text = itemName;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.userInteractionEnabled = NO;
        label.backgroundColor = [UIColor clearColor];
        label.center = CGPointMake(self.frame.size.width*0.5, self.frame.size.height*0.5);
        [self addSubview:label];
        
        self.topGlowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TabTopSelectedGlow.png"]];
        topGlowImageView.center = CGPointMake(self.frame.size.width*0.5, topGlowImageView.center.y);
        topGlowImageView.hidden = YES;
        [self addSubview:topGlowImageView];
        
    }
    return self;
}


-(void)makeHighlighted
{
    
    UIImage* pressedImage = [UIImage imageNamed:@"TabTopSelected.png"];
    self.backgroundColor = [UIColor colorWithPatternImage:pressedImage];
    
    UIColor *color = [UIColor rockpackBlueColor];
    label.layer.shadowColor = [color CGColor];
    label.layer.shadowRadius = 7.0f;
    label.layer.shadowOpacity = 1.0;
    label.layer.shadowOffset = CGSizeZero;
    label.layer.masksToBounds = NO;
    
    topGlowImageView.hidden = NO;
    
    
}

-(void)makeStandard
{
    self.backgroundColor = [UIColor clearColor];
    label.layer.shadowColor = [[UIColor clearColor] CGColor];
    topGlowImageView.hidden = YES;
}

@end
