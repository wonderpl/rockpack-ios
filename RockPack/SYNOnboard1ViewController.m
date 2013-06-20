//
//  SYNOnboard1ViewController.m
//  rockpack
//
//  Created by Nick Banks on 20/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOnboard1ViewController.h"

@interface SYNOnboard1ViewController ()

@end

@implementation SYNOnboard1ViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Set up onboard text
    self.onboardMessageLabel.text = NSLocalizedString(@"startscreen_onboard_1", @"Text for onboard screen 1");
    
}

@end
