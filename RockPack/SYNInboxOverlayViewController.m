//
//  SYNInboxOverlayViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 21/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNInboxOverlayViewController.h"

@interface SYNInboxOverlayViewController ()

@property (nonatomic, strong) IBOutlet UILabel* serchLabel;

@end

@implementation SYNInboxOverlayViewController

-(id)init
{
    self = [super initWithNibName:@"SYNInboxOverlayViewController" bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
