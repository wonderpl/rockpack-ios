//
//  SYNOnboard1ViewController.m
//  rockpack
//
//  Created by Nick Banks on 20/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOnboard4ViewController.h"

@interface SYNOnboard4ViewController ()

@end

@implementation SYNOnboard4ViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Set up onboard text
    self.onboardMessageLabel.text = NSLocalizedString(@"startscreen_onboard_4", @"Text for onboard screen 4");
    self.onboardTitleLabel.text = NSLocalizedString(@"startscreen_onboard_4_title", @"Text for onboard screen 4");

}


@end
