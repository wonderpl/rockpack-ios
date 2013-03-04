//
//  SYNTabViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNTabViewController.h"

@interface SYNTabViewController ()

@end

@implementation SYNTabViewController


@synthesize delegate;
@dynamic tabView;

#pragma mark - Tab View Delegate Methods


-(void)handleMainTap:(UITapGestureRecognizer*)recogniser {
    // implement in subclass
}
-(void)handleSecondaryTap:(UITapGestureRecognizer*)recogniser {
    // implement in subclass
}

-(void)handleNewTabSelectionWithId:(NSString*)itemId {
    // implement in cubclass
}

-(void)setSelectedWithId:(NSString*)selectedId {
    [self.tabView setSelectedWithId:selectedId];
}

-(SYNTabView*)tabView
{
    return (SYNTabView*)self.view;
}

-(BOOL)showSubcategories
{
    return YES;
}

@end
