//
//  SYNCategoryChooserViewController.m
//  rockpack
//
//  Created by Nick Banks on 28/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCategoryChooserViewController.h"
#import "UIFont+SYNFont.h"

@interface SYNCategoryChooserViewController ()

@property (nonatomic, strong) IBOutlet UILabel *header;
@property (nonatomic, strong) IBOutlet UILabel *body;

@end

@implementation SYNCategoryChooserViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Set custom fonts
    self.header.font = [UIFont boldRockpackFontOfSize: 28.0f];
    self.body.font = [UIFont rockpackFontOfSize: 17.0f];
}



- (IBAction) userTouchedPublishButton
{
    
}

- (IBAction) userTouchedSkipButton
{
    
}

@end
