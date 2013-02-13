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

#define kMainTabHeight 50.0
#define kSecondaryTabHeight 40.0

@implementation SYNCategoriesTabView

@synthesize tapDelegate;

@synthesize mainTabsView;
@synthesize secondaryTabsView;

-(id)initWithCategories:(NSArray*)categories andSize:(CGSize)size
{
    
    
    
    CGFloat itemWidth = size.width / categories.count;
    
    CGRect mainFrame = CGRectMake(0.0, 0.0, size.width, kMainTabHeight);
    CGRect secondaryFrame = CGRectMake(0.0, kMainTabHeight, size.width, kSecondaryTabHeight);
    
    self = [super initWithFrame:mainFrame];
    
    if (self) {
        
        self.mainTabsView = [[UIView alloc] initWithFrame:mainFrame];
        self.secondaryTabsView = [[UIView alloc] initWithFrame:secondaryFrame];
        
        [self addSubview:self.mainTabsView];
        [self addSubview:self.secondaryTabsView];
       
        SYNCategoryItemView* tab = nil;
        CGFloat nextOrigin = 0.0;
        
        UITapGestureRecognizer *singleFingerTap = nil;
        
        CGRect itemFrame;
        
        for (Category* category in categories)
        {
            itemFrame = CGRectMake(nextOrigin, 0.0, itemWidth, mainFrame.size.height);
            
            tab = [[SYNCategoryItemView alloc] initWithName:category.name Id:category.uniqueId andFrame:itemFrame];
            [self.mainTabsView addSubview:tab];
            
            singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMainTap:)];
            [tab addGestureRecognizer:singleFingerTap];
            
            nextOrigin += itemWidth;
            
        }
        
        
        
    }
    return self;
}

-(void)createSubcategoriesTab:(NSSet*)subcategories
{
    
    // Clean current subviews
    
    for (UIView* sview in self.secondaryTabsView.subviews)
        [sview removeFromSuperview];
 
    
    
    CGFloat itemWidth = self.frame.size.width / subcategories.count;
    CGFloat itemHeight = self.secondaryTabsView.frame.size.height;
    
    SYNCategoryItemView* tab = nil;
    CGFloat nextOrigin = 0.0;
        
    UITapGestureRecognizer *singleFingerTap = nil;
    
    CGRect itemFrame;
        
    for (Subcategory* subcategory in subcategories)
    {
        itemFrame = CGRectMake(nextOrigin, 0.0, itemWidth, itemHeight);
        
        
        tab = [[SYNCategoryItemView alloc] initWithName:subcategory.name Id:subcategory.uniqueId andFrame:itemFrame];
        [self.secondaryTabsView addSubview:tab];
            
        singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMainTap:)];
        [tab addGestureRecognizer:singleFingerTap];
            
        nextOrigin += itemWidth;
        
        
            
    }
        
        
    
}


-(void)handleMainTap:(UITapGestureRecognizer*)recogniser
{
    [self.tapDelegate handleMainTap:recogniser];
}

-(void)handleSecondaryTap:(UITapGestureRecognizer*)recogniser
{
    [self.tapDelegate handleSecondaryTap:recogniser];
}



@end
