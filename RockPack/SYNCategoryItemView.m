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

#define kCategoriesTabOffsetX 32.0
#define kCategoriesTabOffsetY 28.0

@implementation SYNCategoryItemView


@synthesize label;

- (id)initWithTabItemModel:(TabItem*)tabItemModel
{
    
    
    if (self = [super init]) {
        
        // Identify what type it is (could have passed is as argument)
        if ([tabItemModel isKindOfClass:[Subcategory class]]) 
            type = TabItemTypeSub;
        else
            type = TabItemTypeMain;
        
        self.backgroundColor = [UIColor clearColor];
        
        
        self.tag = [tabItemModel.uniqueId integerValue];
        
        NSString* itemName = tabItemModel.name;
        
        UIFont* fontToUse;
        if (type == TabItemTypeMain)
            fontToUse = [UIFont rockpackFontOfSize: 15.0f];
        else
            fontToUse = [UIFont rockpackFontOfSize: 13.0f];
        
        
        CGSize sizeToUse = [itemName sizeWithFont:fontToUse];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, sizeToUse.width + kCategoriesTabOffsetX, sizeToUse.height + kCategoriesTabOffsetY)];
        label.font = fontToUse;
        label.text = itemName;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.userInteractionEnabled = NO;
        label.backgroundColor = [UIColor clearColor];
        
        [self addSubview:label];
        
        CGRect finalFrame = self.label.frame;
        finalFrame.size.width += 2.0;
        self.frame = finalFrame;
        
        
        
    }
    return self;
}


-(void)makeHighlightedWithImage:(BOOL)withImage
{
    
    if(withImage)
    {
        UIImage* pressedImage = [UIImage imageNamed:@"CategoryBarSelected"];
        self.backgroundColor = [UIColor colorWithPatternImage:pressedImage];
    }
    
    
    UIColor *color = [UIColor whiteColor];
    label.textColor = color;

    
    
    
    
}
-(void)makeFaded
{
    self.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor lightGrayColor];
    
}
-(void)makeStandard
{
    self.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    
}

@end
