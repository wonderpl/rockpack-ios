//
//  SYNSubcategoryItemView.m
//  rockpack
//
//  Created by Michael Michailidis on 12/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSubcategoryItemView.h"

@implementation SYNSubcategoryItemView
@synthesize mainLabel;

- (id)initWithCategory:(Subcategory *)subcategory andFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.categoryId = subcategory.uniqueId;
        
        self.mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        self.mainLabel.textAlignment = NSTextAlignmentCenter;
        self.mainLabel.text = subcategory.name;
        
        [self addSubview:mainLabel];
        
    }
    return self;
}



@end
