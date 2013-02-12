//
//  SYNCategoriesTabView.h
//  rockpack
//
//  Created by Michael Michailidis on 12/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNCategoriesTabView : UIView

@property (nonatomic) CGSize screenSize;

-(id)initWithCategories:(NSArray*)categories;

@end
