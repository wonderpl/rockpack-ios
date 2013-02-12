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

@property (nonatomic) CGSize screenSize;
@property (nonatomic, weak) id<SYNTabViewDelegate> tapDelegate;
@property (nonatomic, strong) NSMutableArray* subviewsArray;

-(id)initWithCategories:(NSArray*)categories andSize:(CGSize)size;

-(void)createSubcategoriesTab:(NSSet*)subcategories;

@end
