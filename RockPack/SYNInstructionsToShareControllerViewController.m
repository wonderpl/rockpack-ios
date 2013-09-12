//
//  SYNInstructionsToShareControllerViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 12/09/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNInstructionsToShareControllerViewController.h"
#import "UIFont+SYNFont.h"

@interface SYNInstructionsToShareControllerViewController ()

@property (strong, nonatomic) IBOutlet UILabel *instructionsLabel;
@property (strong, nonatomic) IBOutlet UILabel *subLabel;
@property (strong, nonatomic) IBOutlet UIButton *okButton;
@property (strong, nonatomic) IBOutlet UIImageView *videoImageView;


@end

@implementation SYNInstructionsToShareControllerViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.subLabel.font = [UIFont rockpackFontOfSize:self.subLabel.font.pointSize];
    self.instructionsLabel.font = [UIFont rockpackFontOfSize:self.instructionsLabel.font.pointSize];
    
    
}

-(IBAction)okayButtonPressed:(id)sender
{
    
}


@end
