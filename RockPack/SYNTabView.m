//
//  SYNTabView.m
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNTabView.h"

#define kDefaultTabsHeight 20.0

@implementation SYNTabView

@synthesize tapDelegate;

- (id) initWithSize: (CGFloat) totalWidth
{
    if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, totalWidth, kDefaultTabsHeight)]))
    {
        // Custom init here
    }
    
    return self;
}


#pragma mark - Tab View Delegate Methods

- (void) handleMainTap: (UITapGestureRecognizer*) recogniser
{
    // implement in subclass
}


- (void) handleSecondaryTap: (UITapGestureRecognizer*) recogniser
{
    // implement in subclass
}


- (void) handleNewTabSelectionWithId: (NSString *) itemId
{
    // implement in subclass
}


- (void) handleNewTabSelectionWithGenre: (Genre*) name
{
    // implement in subclass
}

#pragma mark - Basic Categories creation

- (void) createCategoriesTab: (NSArray*) categories
{
    // implement in subclass
}


- (void) createSubcategoriesTab: (NSArray*) subcategories
{
    // implement in subclass
}


- (void) setSelectedWithId: (NSString*) selectedId
{
    // implement in subclass
}


- (BOOL) showSubGenres
{
    return YES;
}


#pragma mark - orientation layout update

- (void) refreshViewForOrientation: (UIInterfaceOrientation) orientation
{
    // implement in subclass
}

@end
