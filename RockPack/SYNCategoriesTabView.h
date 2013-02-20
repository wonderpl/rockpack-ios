//
//  SYNCategoriesTabView.h
//  rockpack
//
//  Created by Michael Michailidis on 12/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNTabViewDelegate.h"
#import "SYNTabView.h"

@interface SYNCategoriesTabView : SYNTabView


@property (nonatomic, weak) id<SYNTabViewDelegate> tapDelegate;



-(id)initWithSize:(CGFloat)totalWidth;

-(void)createCategoriesTab:(NSArray*)categories;

-(void)createSubcategoriesTab:(NSSet*)subcategories;

@end
