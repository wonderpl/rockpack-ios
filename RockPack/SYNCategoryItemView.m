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
#import "SYNDeviceManager.h"


// These layout offsets and font sizes have been eyeballed to compensate for font offset. May need tweaking.

#define kCategoriesTabOffsetXLandscape 32.0f
#define kCategoriesTabOffsetXPortrait 16.0f

#define kCategoriesTabLabelOffsetYLandscape 4.0f
#define kCategoriesTabLabelOffsetYPortrait 8.0f
#define kCategoriesSubTabLabelOffsetY 10.0f

#define kCategoriesTabFontSizeLandscape 15.0f
#define kCategoriesTabFontSizePortrait 13.0f
#define kCategoriesSubTabFontSizeLandscape 13.0f
#define kCategoriesSubTabFontSizePortrait 11.0f





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
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, sizeToUse.width + kCategoriesTabOffsetXLandscape, 0.0f)];
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


-(void)makeHighlighted
{
    
    UIImage* pressedImage = [UIImage imageNamed:@"CategoryBarSelected"];
    self.backgroundColor = [UIColor colorWithPatternImage:pressedImage];
    
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

#pragma mark - resize for different orientations
-(void)resizeForOrientation:(UIInterfaceOrientation)orientation withHeight:(CGFloat)height
{
    BOOL isLandscape = [[SYNDeviceManager sharedInstance] isLandscape];
    CGFloat offsetX;
    UIFont* fontToUse;
    CGFloat labelYOffset;
    if (type == TabItemTypeMain)
    {
        if(isLandscape)
        {
            fontToUse = [UIFont rockpackFontOfSize: kCategoriesTabFontSizeLandscape];
            offsetX = kCategoriesTabOffsetXLandscape;
            labelYOffset = kCategoriesTabLabelOffsetYLandscape;
        }
        else
        {
            fontToUse = [UIFont rockpackFontOfSize: kCategoriesTabFontSizePortrait];
            offsetX = kCategoriesTabOffsetXPortrait;
            labelYOffset = kCategoriesTabLabelOffsetYPortrait;
        }
    }
    else if(isLandscape)
    {
        fontToUse = [UIFont rockpackFontOfSize: kCategoriesSubTabFontSizeLandscape];
        offsetX = kCategoriesTabOffsetXLandscape;
        labelYOffset = kCategoriesSubTabLabelOffsetY;
    }
    else
    {
        fontToUse = [UIFont rockpackFontOfSize: kCategoriesSubTabFontSizePortrait];
        offsetX = kCategoriesTabOffsetXPortrait;
        labelYOffset = kCategoriesSubTabLabelOffsetY;
    }
    label.font = fontToUse;
    
    
    CGSize sizeToUse = [label.text sizeWithFont:fontToUse];
    
    CGRect newFrame = label.frame;
    newFrame.size=CGSizeMake(sizeToUse.width + offsetX, height + labelYOffset);
    label.frame = newFrame;
    
    CGRect finalFrame = self.label.frame;
    finalFrame.size = CGSizeMake(sizeToUse.width + offsetX + 2.0f, height );
    self.frame = finalFrame;
    
}

@end
