//
//  SYNModalSubscribersController.m
//  rockpack
//
//  Created by Michael Michailidis on 09/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNModalSubscribersController.h"
#import "UIFont+SYNFont.h"
#import "SYNAppDelegate.h"

@interface SYNModalSubscribersController ()

@property (nonatomic, strong) UIViewController* viewController;
@property (nonatomic, strong) IBOutlet UIView* containerView;
@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutlet UIButton* backButton;

@end

@implementation SYNModalSubscribersController

- (id) initWithContentViewController:(UIViewController*)viewController
{
    if (self = [super initWithNibName:NSStringFromClass([self class]) bundle:[NSBundle mainBundle]])
    {
        
        self.viewController = viewController;
        
        
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.font = [UIFont rockpackFontOfSize:self.titleLabel.font.pointSize];
    [self.titleLabel sizeToFit];
    
    self.titleLabel.center = CGPointMake(self.view.center.x, 34.0);
    
    self.backButton.center = CGPointMake(self.backButton.center.x, 30.0);
    
    
    
    [self.containerView addSubview:self.viewController.view];
}

-(IBAction)backButtonPressed:(id)sender
{
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.viewStackManager hideModallyController];
}

@end
