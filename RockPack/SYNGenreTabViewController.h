//
//  SYNCategoriesBarViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 19/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SYNTabViewController.h"

@class Genre;
@interface SYNGenreTabViewController : SYNTabViewController 

@property (nonatomic) BOOL showOtherInSubcategories;

- (id) initWithHomeButton: (NSString*) homeButtomString;

-(void) deselectAll;
-(Genre*)selectAndReturnGenreForId:(NSInteger)identifier andSubcategories:(BOOL)showSubcategories;


@end
