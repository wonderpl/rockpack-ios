//
//  SYNLoginOnBoardingController.m
//  rockpack
//
//  Created by Michael Michailidis on 21/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNLoginOnBoardingController.h"

@interface SYNLoginOnBoardingController ()

@end

@implementation SYNLoginOnBoardingController
@synthesize scrollView = _scrollView;

-(void)loadView
{
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 100.0)];
    scrollView.backgroundColor = [UIColor redColor];
    
    
    
    
    self.view = scrollView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIScrollView*)scrollView
{
    return (UIScrollView*)self.view;
}

@end
