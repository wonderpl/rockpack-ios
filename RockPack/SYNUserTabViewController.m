//
//  SYNUserTabViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 18/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNUserTabViewController.h"
#import "SYNUserTabView.h"
#import "SYNSearchItemView.h"
#import "SYNSearchTabView.h"

@interface SYNUserTabViewController ()

@end

@implementation SYNUserTabViewController

-(void)loadView
{
    
    
    SYNUserTabView* userTabView = [[SYNUserTabView alloc] initWithSize:1024.0];
    userTabView.tapDelegate = self;
    
    self.view = userTabView;
    
    self.view.frame = CGRectMake(0.0, 44.0,
                                 self.view.frame.size.width,
                                 self.view.frame.size.height);
    
    
}

-(void)handleNewTabSelectionWithId:(NSString *)itemId
{
    [self.delegate handleNewTabSelectionWithId:itemId];
}




@end
