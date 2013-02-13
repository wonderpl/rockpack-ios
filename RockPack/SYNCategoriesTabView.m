//
//  SYNCategoriesTabView.m
//  rockpack
//
//  Created by Michael Michailidis on 12/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCategoriesTabView.h"
#import "Category.h"
#import "Subcategory.h"
#import "SYNCategoryItemView.h"
#import "UIFont+SYNFont.h"


@implementation SYNCategoriesTabView

@synthesize tapDelegate;

@synthesize mainTabsView;
@synthesize secondaryTabsView;

-(id)initWithCategories:(NSArray*)categories andSize:(CGSize)size
{
    
    
    
    if (self = [super init]) {
        
        
        
        // Tob Bar //
        UIImage* mainTabsBGImage = [UIImage imageNamed:@"TabTop.png"];
        CGRect mainFrame = CGRectMake(0.0, 0.0, size.width, mainTabsBGImage.size.height);
        self.mainTabsView = [[UIView alloc] initWithFrame:mainFrame];
        self.mainTabsView. backgroundColor = [UIColor colorWithPatternImage:mainTabsBGImage];
        
        UIView* dividerOverlayView = [[UIView alloc] initWithFrame:mainFrame];
        dividerOverlayView.userInteractionEnabled = NO;
        
        // Bottom Bar //
        UIImage* secondaryTabsBGImage = [UIImage imageNamed:@"TabTopSub.png"];
        CGRect secondaryFrame = CGRectMake(0.0, mainFrame.size.height - 2.0, size.width, secondaryTabsBGImage.size.height);
        self.secondaryTabsView = [[UIView alloc] initWithFrame:secondaryFrame];
        self.secondaryTabsView.backgroundColor = [UIColor colorWithPatternImage:secondaryTabsBGImage];
        
        CGRect masterFrame = CGRectMake(0.0, 0.0, size.width, mainFrame.size.height + secondaryFrame.size.height);
        self.frame = masterFrame;
        
        // Add in correct order so that main is above secondary.
        
        
        [self addSubview:self.secondaryTabsView];
        [self addSubview:self.mainTabsView];
       
        SYNCategoryItemView* tab = nil;
        CGFloat nextOrigin = 0.0;
        
        UITapGestureRecognizer *singleFingerTap = nil;
        
        
        
        
        CGFloat itemWidth = size.width / categories.count;
        
        CGRect itemFrame;
        
        CGFloat midMainFrame = self.mainTabsView.frame.size.height * 0.5;
        
        for (Category* category in categories)
        {
            itemFrame = CGRectMake(nextOrigin, 0.0, itemWidth, mainFrame.size.height);
            itemFrame = CGRectIntegral(itemFrame);
            
            tab = [[SYNCategoryItemView alloc] initWithTabItemModel:category andFrame:itemFrame];
            [self.mainTabsView addSubview:tab];
            
            
            
            singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMainTap:)];
            [tab addGestureRecognizer:singleFingerTap];
            
            nextOrigin += itemWidth;
            
            UIImageView* dividerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TabTopDivider.png"]];
            dividerImageView.center = CGPointMake(nextOrigin, midMainFrame);
            [dividerOverlayView addSubview:dividerImageView];
            
        }
        
        [self addSubview:dividerOverlayView];
        
        
    }
    return self;
}

-(void)createSubcategoriesTab:(NSSet*)subcategories
{
    
    // Clean current subviews
    
    for (UIView* sview in self.secondaryTabsView.subviews)
        [sview removeFromSuperview];
 
    
    CGFloat itemHeight = self.secondaryTabsView.frame.size.height;
    
    SYNCategoryItemView* tab = nil;
    CGFloat nextOrigin = 0.0;
        
    UITapGestureRecognizer *singleFingerTap = nil;
    
    CGRect itemFrame;
    
    CGFloat midSecondaryFrame = self.secondaryTabsView.frame.size.height * 0.5;
    
        
    for (Subcategory* subcategory in subcategories)
    {
        
        
        // Change the font for the subcategory tab
        UIFont *fontToUse = [UIFont rockpackFontOfSize: 12.0f];
        CGSize tabMinSize = [subcategory.name sizeWithFont:fontToUse];
        
        itemFrame = CGRectMake(nextOrigin, 0.0, tabMinSize.width, itemHeight);
        
        tab = [[SYNCategoryItemView alloc] initWithTabItemModel:subcategory andFrame:itemFrame];
        [self.secondaryTabsView addSubview:tab];
        
        
        tab.backgroundColor = [UIColor greenColor];
        
        singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSecondaryTap:)];
        [tab addGestureRecognizer:singleFingerTap];
            
        nextOrigin += tab.frame.size.width;
        
        UIImageView* dividerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TabTopSubDivider.png"]];
        dividerImageView.center = CGPointMake(nextOrigin, midSecondaryFrame);
        [self.secondaryTabsView addSubview:dividerImageView];
        
            
    }
        

}


#pragma mark - Delegate Methods


-(void)handleMainTap:(UITapGestureRecognizer*)recogniser
{
    // Set as pressed
    SYNCategoryItemView* itemView;
    
    for(SYNCategoryItemView* itemView in self.mainTabsView.subviews)
        [itemView makeStandard];
    
    itemView = (SYNCategoryItemView*)recogniser.view;
    [itemView makeHighlighted];
    
    [self.tapDelegate handleMainTap:recogniser];
}

-(void)handleSecondaryTap:(UITapGestureRecognizer*)recogniser
{
    [self.tapDelegate handleSecondaryTap:recogniser];
}



@end
