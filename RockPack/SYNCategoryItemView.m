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
#import "Category.h"
#import "Subcategory.h"

@implementation SYNCategoryItemView

@synthesize glowImageView;

@synthesize label;

- (id)initWithTabItemModel:(TabItem*)tabItemModel andFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        // Identify what type it is (could have passed is as argument)
        if ([tabItemModel isKindOfClass:[Subcategory class]]) 
            type = TabItemTypeSub;
        else
            type = TabItemTypeMain;
        
        
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
        CGFloat correctY;
        if(type == TabItemTypeMain)
            correctY = self.frame.size.height*0.5 + 3.0;
        else
            correctY = self.frame.size.height*0.5 + 4.0;
        
        label.center = CGPointMake(self.frame.size.width*0.5, correctY - 4.0);
        [self addSubview:label];
        
        if(type == TabItemTypeMain)
        {
            self.glowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TabTopSelectedGlow.png"]];
            glowImageView.center = CGPointMake(self.frame.size.width*0.5, glowImageView.center.y);
            glowImageView.hidden = YES;
            glowImageView.userInteractionEnabled = NO;
            
        }
        else
        {
            self.glowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TabTopSubSelectedGlow.png"]];
            CGFloat offset = (self.frame.size.height - self.glowImageView.frame.size.height * 0.5) + 1;
            glowImageView.center = CGPointMake(self.frame.size.width*0.5, offset);
            glowImageView.hidden = YES;
            glowImageView.userInteractionEnabled = NO;
            
        }
        
        [self addSubview:glowImageView];
        
    }
    return self;
}


-(void)makeHighlightedWithImage:(BOOL)withImage
{
    
    if(withImage)
    {
        UIImage* pressedImage = [UIImage imageNamed:@"TabTopSelected.png"];
        self.backgroundColor = [UIColor colorWithPatternImage:pressedImage];
    }
    
    
    UIColor *color = [UIColor rockpackBlueColor];
    label.textColor = color;

    
    glowImageView.alpha = 0.0;
    glowImageView.hidden = NO;
    
    
    [UIView animateWithDuration:0.1 animations:^{
        glowImageView.alpha = 1.0;
    }];
    
    
    
    
}
-(void)makeFaded
{
    self.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor lightGrayColor];
    label.layer.shadowColor = [[UIColor clearColor] CGColor];
    glowImageView.hidden = YES;
}
-(void)makeStandard
{
    self.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.layer.shadowColor = [[UIColor clearColor] CGColor];
    glowImageView.hidden = YES;
}

@end
