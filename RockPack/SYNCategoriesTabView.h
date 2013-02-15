//
//  SYNCategoriesTabView.h
//  rockpack
//
//  Created by Michael Michailidis on 12/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNTabViewDelegate.h"

@interface SYNCategoriesTabView : UIView <SYNTabViewDelegate>


@property (nonatomic, weak) id<SYNTabViewDelegate> tapDelegate;

@property (nonatomic, strong) UIView* mainTabsView;
@property (nonatomic, strong) UIView* secondaryTabsView;
@property (nonatomic, strong) UIView* secondaryTabsBGView;

-(id)initWithCategories:(NSArray*)categories andSize:(CGSize)size;

-(void)createSubcategoriesTab:(NSSet*)subcategories;

@end
