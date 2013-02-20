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

@interface SYNCategoriesTabView ()

@property (nonatomic, strong) UIView* mainTabsView;
@property (nonatomic, strong) UIView* secondaryTabsView;
@property (nonatomic, strong) UIView* secondaryTabsBGView;
@property (nonatomic, strong) UIView* secondaryDividerOverlay;


@end


@implementation SYNCategoriesTabView





-(id)initWithSize:(CGFloat)totalWidth
{
    
    
    
    if (self = [super init]) {
        
        
        
        // Tob Bar //
        UIImage* mainTabsBGImage = [UIImage imageNamed:@"TabTop.png"];
        CGRect mainFrame = CGRectMake(0.0, 0.0, totalWidth, mainTabsBGImage.size.height);
        self.mainTabsView = [[UIView alloc] initWithFrame:mainFrame];
        self.mainTabsView. backgroundColor = [UIColor colorWithPatternImage:mainTabsBGImage];
        
        
        
        // Bottom Bar //
        UIImage* secondaryTabsBGImage = [UIImage imageNamed:@"TabTopSub.png"];
        CGRect secondaryFrame = CGRectMake(0.0, mainFrame.size.height, totalWidth, secondaryTabsBGImage.size.height);
        self.secondaryTabsView = [[UIView alloc] initWithFrame:secondaryFrame];
        
        self.secondaryDividerOverlay = [[UIView alloc] initWithFrame:secondaryFrame];
        self.secondaryDividerOverlay.userInteractionEnabled = NO;
        self.secondaryDividerOverlay.alpha = 0.0;
        
        self.secondaryTabsBGView = [[UIView alloc] initWithFrame:secondaryFrame];
        self.secondaryTabsBGView.backgroundColor = [UIColor colorWithPatternImage:secondaryTabsBGImage];
        self.secondaryTabsBGView.userInteractionEnabled = NO;
        self.secondaryTabsBGView.alpha = 0.0;
        
        CGRect masterFrame = CGRectMake(0.0, 0.0, totalWidth, mainFrame.size.height + secondaryFrame.size.height);
        self.frame = masterFrame;
        
        // Add in correct order so that main is above secondary.
        
        [self addSubview:self.secondaryTabsBGView];
        [self addSubview:self.secondaryTabsView];
        [self addSubview:self.secondaryDividerOverlay];
        [self addSubview:self.mainTabsView];
       
        
        
        
    }
    return self;
}


-(void)createCategoriesTab:(NSArray*)categories
{
    SYNCategoryItemView* tab = nil;
    CGFloat nextOrigin = 0.0;
    
    UIView* dividerOverlayView = [[UIView alloc] initWithFrame:self.mainTabsView.frame];
    dividerOverlayView.userInteractionEnabled = NO;
    
    UITapGestureRecognizer *singleFingerTap = nil;
    
    CGFloat itemWidth = self.frame.size.width / categories.count;
    
    CGRect itemFrame;
    
    CGFloat midMainFrame = self.mainTabsView.frame.size.height * 0.5;
    
    for (Category* category in categories)
    {
        itemFrame = CGRectMake(nextOrigin + 2.0, 0.0, itemWidth - 2.0, self.mainTabsView.frame.size.height);
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

-(void)createSubcategoriesTab:(NSSet*)subcategories
{
    
    // Clean current subviews
    
    self.secondaryTabsView.alpha = 0.0;
    
    for (UIView* sview in self.secondaryTabsView.subviews)
        [sview removeFromSuperview];
    
    for(SYNCategoryItemView* divider in self.secondaryDividerOverlay.subviews)
        [divider removeFromSuperview];
 
    
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
        tabMinSize.width += 36.0;
        
        itemFrame = CGRectMake(nextOrigin, 0.0, tabMinSize.width, itemHeight);
        
        tab = [[SYNCategoryItemView alloc] initWithTabItemModel:subcategory andFrame:itemFrame];
        [self.secondaryTabsView addSubview:tab];
        
        tab.label.font = fontToUse;
        
        
        singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSecondaryTap:)];
        [tab addGestureRecognizer:singleFingerTap];
            
        nextOrigin += tab.frame.size.width;
        
        UIImageView* dividerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TabTopSubDivider.png"]];
        dividerImageView.center = CGPointMake(nextOrigin, midSecondaryFrame);
        [self.secondaryDividerOverlay addSubview:dividerImageView];
        
            
    }
    
    [UIView animateWithDuration:0.6 delay:0.2 options:UIViewAnimationCurveEaseOut animations:^{
        self.secondaryTabsView.alpha = 1.0;
        self.secondaryTabsBGView.alpha = 1.0;
        self.secondaryDividerOverlay.alpha = 1.0;
    } completion:^(BOOL result){}];
    
    
        

}


#pragma mark - Delegate Methods


-(void)handleMainTap:(UITapGestureRecognizer*)recogniser
{
    // Set as pressed
    SYNCategoryItemView* itemView;
    
    for(SYNCategoryItemView* itemView in self.mainTabsView.subviews)
        [itemView makeFaded];
    
    
    
    itemView = (SYNCategoryItemView*)recogniser.view;
    [itemView makeHighlightedWithImage:YES];
    
    [self.tapDelegate handleMainTap:recogniser];
}

-(void)handleSecondaryTap:(UITapGestureRecognizer*)recogniser
{
    SYNCategoryItemView* itemView;
    
    for(SYNCategoryItemView* itemView in self.secondaryTabsView.subviews)
        [itemView makeStandard];
    
    
    
    itemView = (SYNCategoryItemView*)recogniser.view;
    [itemView makeHighlightedWithImage:NO];
    
    [self.tapDelegate handleSecondaryTap:recogniser];
}



@end
