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
@synthesize secondaryTabsBGView;

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
        self.secondaryTabsBGView = [[UIView alloc] initWithFrame:secondaryFrame];
        self.secondaryTabsBGView.backgroundColor = [UIColor colorWithPatternImage:secondaryTabsBGImage];
        
        CGRect masterFrame = CGRectMake(0.0, 0.0, size.width, mainFrame.size.height + secondaryFrame.size.height);
        self.frame = masterFrame;
        
        // Add in correct order so that main is above secondary.
        
        [self addSubview:self.secondaryTabsBGView];
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
            itemFrame = CGRectMake(nextOrigin + 2.0, 0.0, itemWidth - 2.0, mainFrame.size.height);
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
    
    self.secondaryTabsView.alpha = 0.0;
    
    for (UIView* sview in self.secondaryTabsView.subviews)
        [sview removeFromSuperview];
 
    
    CGFloat itemHeight = self.secondaryTabsView.frame.size.height;
    
    SYNCategoryItemView* tab = nil;
    CGFloat nextOrigin = 0.0;
        
    UITapGestureRecognizer *singleFingerTap = nil;
    
    CGRect itemFrame;
    
    CGFloat midSecondaryFrame = self.secondaryTabsView.frame.size.height * 0.5;
    
    
    NSSortDescriptor* idSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"uniqueId" ascending:YES];
    NSArray* sortedSubcategories = [subcategories sortedArrayUsingDescriptors:[NSArray arrayWithObject:idSortDescriptor]];
        
    for (Subcategory* subcategory in sortedSubcategories)
    {
        
        
        // Change the font for the subcategory tab
        UIFont *fontToUse = [UIFont rockpackFontOfSize: 13.0f];
        CGSize tabMinSize = [subcategory.name sizeWithFont:fontToUse];
        tabMinSize.width += 20.0;
        
        itemFrame = CGRectMake(nextOrigin, 0.0, tabMinSize.width, itemHeight);
        
        tab = [[SYNCategoryItemView alloc] initWithTabItemModel:subcategory andFrame:itemFrame];
        [self.secondaryTabsView addSubview:tab];
        
        tab.label.font = fontToUse;
        
        
        singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSecondaryTap:)];
        [tab addGestureRecognizer:singleFingerTap];
            
        nextOrigin += tab.frame.size.width;
        
        UIImageView* dividerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TabTopSubDivider.png"]];
        dividerImageView.center = CGPointMake(nextOrigin, midSecondaryFrame);
        [self.secondaryTabsView addSubview:dividerImageView];
        
            
    }
    
    
    [UIView animateWithDuration:0.7 animations:^{
        self.secondaryTabsView.alpha = 1.0;
    }];
        

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
