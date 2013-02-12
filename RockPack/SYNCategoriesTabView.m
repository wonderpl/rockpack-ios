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

@implementation SYNCategoriesTabView

-(id)initWithCategories:(NSArray*)categories
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat itemWidth = screenSize.width / categories.count;
    
    
    self = [super initWithFrame:CGRectMake(0.0, 0.0, screenSize.width, 200.0)];
    
    if (self) {
       
        SYNCategoryItemView* tab = nil;
        CGFloat nextOrigin = 0.0;
        for (Category* category in categories)
        {
            tab = [[SYNCategoryItemView alloc] initWithCategory:category andFrame:CGRectMake(nextOrigin, 0.0, itemWidth, 200.0)];
            tab.backgroundColor = [UIColor greenColor];
            [self addSubview:tab];
            
            nextOrigin += itemWidth;
            
        }
        
        
    }
    return self;
}



@end
