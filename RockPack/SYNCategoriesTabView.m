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
        
        
        // == Tob Bar == //
        
        UIImage* mainTabsBGImage = [UIImage imageNamed:@"CategoryBar"];
        CGRect mainFrame = CGRectMake(0.0, 0.0, totalWidth, mainTabsBGImage.size.height);
        
        self.mainTabsView.backgroundColor = [UIColor colorWithPatternImage:mainTabsBGImage];
        self.mainTabsView = [[UIView alloc] initWithFrame:mainFrame];
        
        
        
        // == Bottom Bar == //
        
        UIImage* secondaryTabsBGImage = [UIImage imageNamed:@"SubCategoryBar"];
        CGRect secondaryFrame = CGRectMake(0.0, mainFrame.size.height - 6.0, totalWidth, secondaryTabsBGImage.size.height);
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
    
    
    UIView* dividerOverlayView = [[UIView alloc] initWithFrame:self.mainTabsView.frame];
    dividerOverlayView.userInteractionEnabled = NO;
    
    
    CGFloat midMainFrame = self.mainTabsView.frame.size.height * 0.5;
    
    
    
    CGFloat nextOrigin = 0.0;
    
    for (Category* category in categories)
    {
        
        
        tab = [[SYNCategoryItemView alloc] initWithTabItemModel:category];
        CGRect tabFrame = tab.frame;
        tabFrame.origin.x = nextOrigin + 2.0;
        tabFrame.size.height = self.mainTabsView.frame.size.height;
        tab.frame = tabFrame;
        [self.mainTabsView addSubview:tab];
        
        [tab addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMainTap:)]];
        
        nextOrigin += tabFrame.size.width;
        
        UIImageView* dividerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CategoryBarDivider"]];
        dividerImageView.center = CGPointMake(nextOrigin, midMainFrame - 4.0);
        dividerImageView.frame = CGRectIntegral(dividerImageView.frame);
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
 
    
    
    SYNCategoryItemView* tab = nil;
    CGFloat nextOrigin = 0.0;
        
    
    
    CGFloat midSecondaryFrame = self.secondaryTabsView.frame.size.height * 0.5;
    
    
    NSSortDescriptor* idSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:NO];
    NSArray* sortedSubcategories = [subcategories sortedArrayUsingDescriptors:[NSArray arrayWithObject:idSortDescriptor]];
        
    for (Subcategory* subcategory in sortedSubcategories)
    {
        
        
        
        tab = [[SYNCategoryItemView alloc] initWithTabItemModel:subcategory];
        CGRect tabFrame = tab.frame;
        tabFrame.origin.x = nextOrigin + 2.0;
        tabFrame.size.height = self.mainTabsView.frame.size.height;
        tab.frame = tabFrame;
        [self.secondaryTabsView addSubview:tab];
        
        
        [tab addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSecondaryTap:)]];
            
        nextOrigin += tabFrame.size.width;
        
        UIImageView* dividerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SubCategoryBarDivider"]];
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
    
    
    // tapDelegate is the SYNCategoryViewController
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
