//
//  SYNSearchTabViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchTabViewController.h"
#import "SYNSearchTabView.h"

@interface SYNSearchTabViewController ()

@end



@implementation SYNSearchTabViewController

-(void)loadView
{
    // Calculate height
    
    SYNSearchTabView* categoriesTabView = [[SYNSearchTabView alloc] initWithSize:1024.0];
    categoriesTabView.tapDelegate = self;
    
    self.view = categoriesTabView;
    
    // align to top
    self.view.frame = CGRectMake(0.0, 44.0, self.view.frame.size.width, self.view.frame.size.height);
    
    
}

-(void)handleNewTabSelectionWithId:(NSString *)itemId
{
    [self.delegate handleNewTabSelectionWithId:itemId];
}

@end
