//
//  SYNTopBarViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNMasterViewController.h"

@interface SYNMasterViewController ()

@property (nonatomic, strong) IBOutlet UIView* containerView;
@property (nonatomic, strong) IBOutlet UIView* topBarView;

@end

@implementation SYNMasterViewController

@synthesize rootViewController = _rootViewController;



-(id)initWithRootViewController:(UIViewController*)root
{
    self = [super initWithNibName:@"SYNMasterViewController" bundle:nil];
    if (self) {
        self.rootViewController = root;
    }
    return self;
}

#pragma mark - Root View Controller

-(void)setRootViewController:(UIViewController *)rootViewController
{
    _rootViewController = rootViewController;
    [self.containerView addSubview:_rootViewController.view];
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
