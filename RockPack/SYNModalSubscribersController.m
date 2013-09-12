//
//  SYNModalSubscribersController.m
//  rockpack
//
//  Created by Michael Michailidis on 09/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "AMBlurView.h"
#import "SYNAppDelegate.h"
#import "SYNDeviceManager.h"
#import "SYNModalSubscribersController.h"
#import "UIFont+SYNFont.h"

@interface SYNModalSubscribersController ()

@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) AMBlurView *blurViewController;
@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIButton *backButton;

@end


@implementation SYNModalSubscribersController


- (id) initWithContentViewController: (UIViewController *) viewController
{
    if (self = [super initWithNibName: NSStringFromClass([self class])
                               bundle: [NSBundle mainBundle]])
    {
        self.viewController = viewController;
    }
    
    return self;
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.font = [UIFont rockpackFontOfSize: self.titleLabel.font.pointSize];
    
    CGRect containerViewFrame = self.containerView.frame;
    self.viewController.view.frame = containerViewFrame;
    
//        if (PLATFORM_CAN_HANDLE_LIVE_BLUR)
    if (0)
    {
        self.containerView.hidden = YES;
        
        self.blurViewController = [AMBlurView new];
        
        if (IS_IPHONE_5) {
            self.blurViewController.frame = CGRectMake(self.containerView.frame.origin.x, self.containerView.frame.origin.y, self.containerView.frame.size.width, self.containerView.frame.size.height + 67 + 22);
        }
        
        else
        {
            self.blurViewController.frame = CGRectMake(self.containerView.frame.origin.x, self.containerView.frame.origin.y, self.containerView.frame.size.width, self.containerView.frame.size.height + 22);
        }
        
        [self.blurViewController addSubview: self.viewController.view];
        [self.view addSubview:self.blurViewController];
    }
    
    else
    {
        [self.containerView addSubview: self.viewController.view];
    }
    
}


- (IBAction) backButtonPressed: (id) sender
{
    SYNAppDelegate *appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    [appDelegate.viewStackManager hideModalController];
}

@end
