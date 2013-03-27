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

@property (nonatomic, readonly) SYNUserTabView* userTabView;

@end

@implementation SYNUserTabViewController
@synthesize owner;
@synthesize userTabView;

-(void)loadView
{
    
    
    SYNUserTabView* nuserTabView = [[SYNUserTabView alloc] initWithSize:1024.0];
    nuserTabView.tapDelegate = self;
    
    self.view = nuserTabView;
    
    self.view.frame = CGRectMake(0.0, 44.0,
                                 self.view.frame.size.width,
                                 self.view.frame.size.height);
    
    
}

-(void)setOwner:(ChannelOwner *)nowner
{
    [self.userTabView showOwnerData:nowner];
}

-(void)handleNewTabSelectionWithId:(NSString *)itemId
{
    [self.delegate handleNewTabSelectionWithId:itemId];
}

-(SYNUserTabView*)userTabView
{
    return (SYNUserTabView*)self.view;
}


@end
