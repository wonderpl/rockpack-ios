//
//  SYNCategoriesTabView.m
//  rockpack
//
//  Created by Michael Michailidis on 12/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCategoriesTabView.h"
#import "Category.h"
#import "SYNCategoryItemView.h"
#import "SYNSubcategoryItemView.h"

@implementation SYNCategoriesTabView
@synthesize tapDelegate;
@synthesize subviewsArray;

-(id)initWithCategories:(NSArray*)categories andSize:(CGSize)size
{
    
    CGFloat itemWidth = size.width / categories.count;
    
    
    self = [super initWithFrame:CGRectMake(0.0, 0.0, size.width, 200.0)];
    
    if (self) {
       
        SYNCategoryItemView* tab = nil;
        CGFloat nextOrigin = 0.0;
        
        UITapGestureRecognizer *singleFingerTap = nil; 
        
        for (Category* category in categories)
        {
            tab = [[SYNCategoryItemView alloc] initWithCategory:category andFrame:CGRectMake(nextOrigin, 0.0, itemWidth, 50.0)];
            [self addSubview:tab];
            
            singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMainTap:)];
            [tab addGestureRecognizer:singleFingerTap];
            
            nextOrigin += itemWidth;
            
        }
        
        self.subviewsArray = [[NSMutableArray alloc] init];
        
        
    }
    return self;
}

-(void)createSubcategoriesTab:(NSSet*)subcategories
{
    // Clean current subviews
    
    for (UIView* sview in self.subviewsArray)
    {
        [sview removeFromSuperview];
    }
    
    CGFloat itemWidth = self.frame.size.width / subcategories.count;
    
    
    SYNSubcategoryItemView* tab = nil;
    CGFloat nextOrigin = 0.0;
        
    UITapGestureRecognizer *singleFingerTap = nil;
    
    CGFloat currentHeight = self.frame.size.height;
        
    for (Subcategory* subcategory in subcategories)
    {
        tab = [[SYNSubcategoryItemView alloc] initWithCategory:subcategory andFrame:CGRectMake(nextOrigin, currentHeight, itemWidth, 60.0)];
        [self addSubview:tab];
            
        singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMainTap:)];
        [tab addGestureRecognizer:singleFingerTap];
            
        nextOrigin += itemWidth;
        
        [self.subviewsArray addObject:tab];
        
            
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
