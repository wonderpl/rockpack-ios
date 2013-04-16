//
//  SYNTabView.h
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNTabViewDelegate.h"

@interface SYNTabView : UIView <SYNTabViewDelegate>


@property (nonatomic, weak) id<SYNTabViewDelegate> tapDelegate;

-(id)initWithSize:(CGFloat)totalWidth;


-(void)createCategoriesTab:(NSArray*)categories;

-(void)createSubcategoriesTab:(NSSet*)subcategories;

-(void)setSelectedWithId:(NSString*)selectedId;

/**
	triggers a re-layout of the tab view to suit the selected orientation.
 
    Override in subclass with implementation
	@param orientation orientation to adapt to.
 */
-(void)refreshViewForOrientation:(UIInterfaceOrientation)orientation;


@end
