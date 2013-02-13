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


@implementation SYNCategoriesTabView

@synthesize tapDelegate;

@synthesize mainTabsView;
@synthesize secondaryTabsView;

-(id)initWithCategories:(NSArray*)categories andSize:(CGSize)size
{
    
    
    
    if (self = [super init]) {
        
        
        
        UIImage* mainTabsBGImage = [UIImage imageNamed:@"TabTop.png"];
        CGRect mainFrame = CGRectMake(0.0, 0.0, size.width, mainTabsBGImage.size.height);
        self.mainTabsView = [[UIView alloc] initWithFrame:mainFrame];
        self.mainTabsView. backgroundColor = [UIColor colorWithPatternImage:mainTabsBGImage];
        
        UIImage* secondaryTabsBGImage = [UIImage imageNamed:@"TabTopSub.png"];
        CGRect secondaryFrame = CGRectMake(0.0, mainFrame.size.height, size.width, secondaryTabsBGImage.size.height);
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
        
        CGFloat midMainFrame = mainFrame.size.height * 0.5;
        
        for (Category* category in categories)
        {
            itemFrame = CGRectMake(nextOrigin, 0.0, itemWidth, mainFrame.size.height);
            itemFrame = CGRectIntegral(itemFrame);
            
            tab = [[SYNCategoryItemView alloc] initWithName:category.name Id:category.uniqueId andFrame:itemFrame];
            [self.mainTabsView addSubview:tab];
            
            UIImageView* dividerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TabTopDivider.png"]];
            dividerImageView.center = CGPointMake(nextOrigin, midMainFrame);
            [self.mainTabsView addSubview:dividerImageView];
            
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
