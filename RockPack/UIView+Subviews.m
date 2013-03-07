//
//  UIView+Subviews.m
//  rockpack
//
//  Created by Nick Banks on 06/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "UIView+Subviews.h"

@implementation UIView (Subviews)

- (NSMutableArray*) allSubViews
{
    NSMutableArray *subviewArray = [[NSMutableArray alloc] init];
    [subviewArray addObject: self];
    
    for (UIView *subview in self.subviews)
    {
        [subviewArray addObjectsFromArray: (NSArray*)[subview allSubViews]];
    }
    
    return subviewArray;
}

@end
