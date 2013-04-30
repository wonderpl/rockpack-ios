//
//  SYNAccountSettingsModalContainer.m
//  rockpack
//
//  Created by Michael Michailidis on 30/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAccountSettingsModalContainer.h"

@interface SYNAccountSettingsModalContainer ()

@end

@implementation SYNAccountSettingsModalContainer


-(id)initWithNavigationController:(UINavigationController*)navigationController
{
    if(self = [super init])
    {
        childNavigationController = navigationController;
        childNavigationController.delegate = self;
        [self addChildViewController:childNavigationController];
        
        
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = CGRectMake(0.0, 0.0, 320.0, 600.0);
    
    self.view.backgroundColor = [UIColor greenColor];
    
    [self.view addSubview:childNavigationController.view];
	
}



@end
