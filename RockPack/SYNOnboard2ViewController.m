//
//  SYNOnboard2ViewController.m
//  rockpack
//
//  Created by Nick Banks on 20/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOnboard2ViewController.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNOnboard2ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *onboardMessageLabel;

@end

@implementation SYNOnboard2ViewController

- (void) viewDidLoad
{
    // Set up onboard text
    self.onboardMessageLabel.text = NSLocalizedString(@"startscreen_onboard_2", @"Text for onboard screen 1");
    
    // Set font
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.onboardMessageLabel.font = [UIFont rockpackFontOfSize: 20.0];
    }
    else
    {
        self.onboardMessageLabel.font = [UIFont rockpackFontOfSize: 12.0];
    }
    
    // Colour of onboard text
    self.onboardMessageLabel.textColor = [UIColor whiteColor];
    
    // Colour of small DropShadow on text
    self.onboardMessageLabel.shadowColor = [UIColor colorWithRed: 0.0f
                                                           green: 0.0f
                                                            blue: 0.0f
                                                           alpha:0.2f];
    
    // Offset of small DropShadow's
    
    self.onboardMessageLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    
    // Colour of onboard text shadow (R, G, B)
    self.onboardMessageLabel.layer.shadowColor = [UIColor colorWithRed: 0.0f
                                                                 green: 0.0f
                                                                  blue: 0.0f
                                                                 alpha: 1.0f].CGColor;
    
    // Offset of onboard text shadow (X, Y)
    self.onboardMessageLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    
    // Radius of onboard text shadow (0 -> n)
    self.onboardMessageLabel.layer.shadowRadius = 10.0f;
    
    // Opacity of onboard text shadow (0 - 1)
    self.onboardMessageLabel.layer.shadowOpacity = 0.3f;
}


@end
