//
//  SYNTopBarViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNMasterViewController.h"
#import "AppConstants.h"
#import "SYNActivityPopoverViewController.h"

@interface SYNMasterViewController ()

@property (nonatomic, strong) IBOutlet UIView* containerView;
@property (nonatomic, strong) IBOutlet UIView* topBarView;
@property (nonatomic, strong) IBOutlet UIView* overlayView;
@property (nonatomic, strong) IBOutlet UITextField* searchTextField;

@property (nonatomic, strong) UIPopoverController* popoverController;

@end

@implementation SYNMasterViewController

@synthesize rootViewController = rootViewController;
@synthesize popoverController = popoverController;

#pragma mark - Initialise

-(id)initWithRootViewController:(UIViewController*)root
{
    self = [super initWithNibName:@"SYNMasterViewController" bundle:nil];
    if (self) {
        self.rootViewController = root;
    }
    return self;
}



-(void)setRootViewController:(UIViewController *)viewController
{
    rootViewController = viewController;
    
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // == Fade in from splash screen (not in AppDelegate so that the Orientation is known) ==//
    
    UIImageView *splashView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 1024, 748)];
    splashView.image = [UIImage imageNamed:  @"Default-Landscape.png"];
	[self.view addSubview: splashView];
    
    [UIView animateWithDuration: kSplashAnimationDuration
                          delay: kSplashViewDuration
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         splashView.alpha = 0.0f;
                     }
                     completion: ^(BOOL finished) {
         splashView.alpha = 0.0f;
         [splashView removeFromSuperview];
     }];
    
    // == Add the Root Controller which will contain all others (Tabs in our case) == //
    
    [self.containerView addSubview:rootViewController.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Overlay View


- (IBAction) userTouchedInboxButton: (UIButton*) button
{
    button.selected = !button.selected;
    
    if (button.selected)
    {
        // Need to slide rockie talkie out
        //[self slideMessageInboxRight: nil];
    }
    else
    {
        // Need to slide rockie talkie back in
        //[self slideMessageInboxLeft: nil];
    }
}


- (void) slideOverlay: (UIView *) overlayView
{
    
    CGRect overlayViewFrame = overlayView.frame;
    
    // Take out of screen
    overlayView.frame =  CGRectMake(-overlayViewFrame.size.width,
                                    0.0,
                                    overlayViewFrame.size.width,
                                    overlayViewFrame.size.height);
    
    [self.overlayView addSubview:overlayView];
    
    [UIView animateWithDuration: kRockieTalkieAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
         
         overlayView.frame =  CGRectMake(0.0,
                                         0.0,
                                         overlayViewFrame.size.width,
                                         overlayViewFrame.size.height);
         
     } completion: ^(BOOL finished) {
        
     }];
    
}


- (IBAction) userTouchedNotificationButton: (UIButton*) button
{
    button.selected = !button.selected;
    
    if (button.selected)
    {
        SYNActivityPopoverViewController *actionPopoverController = [[SYNActivityPopoverViewController alloc] init];
        // Need show the popover controller
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController: actionPopoverController];
        self.popoverController.popoverContentSize = CGSizeMake(320, 166);
        self.popoverController.delegate = self;
        
        [self.popoverController presentPopoverFromRect: button.frame
                                                inView: self.view
                              permittedArrowDirections: UIPopoverArrowDirectionUp
                                              animated: YES];
    }
    else
    {
        // Need to hide the popover controller
        [self.popoverController dismissPopoverAnimated: YES];
    }
}



#pragma mark - Text Field Methods

- (IBAction) clearSearchField: (id) sender
{
    self.searchTextField.text = @"";
    
    [self.searchTextField resignFirstResponder];
}



@end
