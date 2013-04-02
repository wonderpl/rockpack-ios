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
#import "SYNInboxOverlayViewController.h"
#import "SYNShareOverlayViewController.h"
#import "SYNBottomTabViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNAutocompleteViewController.h"
#import "SYNSoundPlayer.h"
#import "SYNAutocompletePopoverBackgroundView.h"
#import "SYNBottomTabViewController.h"

#import "SYNVideoViewerViewController.h"
#import "SYNAccountSettingsMainTableViewController.h"
#import "SYNCategoryChooserViewController.h"


#import <QuartzCore/QuartzCore.h>

#define kAutocompleteTime 0.2

typedef void(^AnimationCompletionBlock)(BOOL finished);

@interface SYNMasterViewController ()

@property (nonatomic, strong) IBOutlet UIButton* backButton;
@property (nonatomic, strong) IBOutlet UIButton* clearTextButton;
@property (nonatomic, strong) IBOutlet UIButton* inboxButton;
@property (nonatomic, strong) IBOutlet UIButton* notificationButton;
@property (nonatomic, strong) IBOutlet UIImageView* glowTextImageView;
@property (nonatomic, strong) IBOutlet UILabel* inboxLabel;
@property (nonatomic, strong) IBOutlet UILabel* notificationsLabel;
@property (nonatomic, strong) IBOutlet UITextField* searchTextField;
@property (nonatomic, strong) IBOutlet UIView* overlayView;
@property (nonatomic, strong) IBOutlet UIView* slidersView;
@property (nonatomic, strong) IBOutlet UIView* topBarView;
@property (nonatomic, strong) IBOutlet UIView* topButtonsContainer;
@property (nonatomic, strong) NSTimer* autocompleteTimer;
@property (nonatomic, strong) SYNAutocompleteViewController* autocompleteController;
@property (nonatomic, strong) SYNInboxOverlayViewController* inboxOverlayViewController;
@property (nonatomic, strong) SYNShareOverlayViewController* shareOverlayViewController;
@property (nonatomic, strong) SYNVideoViewerViewController *videoViewerViewController;
@property (nonatomic, strong) SYNCategoryChooserViewController *categoryChooserViewController;
@property (nonatomic, strong) UIPopoverController* autocompletePopoverController;
@property (nonatomic, strong) UIPopoverController* notificationsPopoverController;
@property (nonatomic, weak) UIViewController* currentOverlayViewController;


@end

@implementation SYNMasterViewController

@synthesize rootViewController = rootViewController;
@synthesize notificationsPopoverController = notificationsPopoverController;
@synthesize autocompleteTimer;

#pragma mark - Initialise

-(id)initWithRootViewController:(UIViewController*)root
{
    if ((self = [super initWithNibName: @"SYNMasterViewController" bundle: nil]))
    {
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        self.rootViewController = root;

        // == Set up Inbox Overlay
        self.inboxOverlayViewController = [[SYNInboxOverlayViewController alloc] init];
        CGRect inboxOverlayFrame = self.inboxOverlayViewController.view.frame;
        inboxOverlayFrame.origin.x = -(inboxOverlayFrame.size.width);
        inboxOverlayFrame.origin.y = 45.0;
        self.inboxOverlayViewController.view.frame = inboxOverlayFrame;
        
        // == Set up Share Overlay
        self.shareOverlayViewController = [[SYNShareOverlayViewController alloc] init];
        CGRect shareOverlayFrame = self.inboxOverlayViewController.view.frame;
        shareOverlayFrame.origin.x = -(shareOverlayFrame.size.width);
        shareOverlayFrame.origin.y = 45.0;
        self.shareOverlayViewController.view.frame = shareOverlayFrame;
        
        self.autocompleteController = [[SYNAutocompleteViewController alloc] init];
        
        self.autocompleteController.tableView.delegate = self;
        
        self.overEverythingView.userInteractionEnabled = NO;
        
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
    
    self.slidersView.userInteractionEnabled = YES;
    
    // == Add the Root Controller which will contain all others (Tabs in our case) == //
    
    [self.containerView addSubview:rootViewController.view];
    
    self.backButton.alpha = 0.0;
    
    self.topButtonsContainer.userInteractionEnabled = YES;
    
    // == Set Up Labels == /
    
    UIFont* boldFont = [UIFont boldRockpackFontOfSize:17.0f];
    
    self.inboxLabel.font = boldFont;
    self.notificationsLabel.font = boldFont;
    
    self.clearTextButton.alpha = 0.0;
    self.glowTextImageView.alpha = 0.0;
    self.glowTextImageView.userInteractionEnabled = NO;
    
    // == Set Up Notifications == //
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backButtonRequested:) name:kNoteBackButtonShow object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backButtonRequested:) name:kNoteBackButtonHide object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabPressed:) name:kNoteTabPressed object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sharePanelRequested:) name:kNoteSharePanelRequested object:nil];
    
    
    // Add swipe-away gesture
    UISwipeGestureRecognizer* inboxLeftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget: self
                                                                                                action: @selector(panelSwipedAway:)];
    inboxLeftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.slidersView addGestureRecognizer: inboxLeftSwipeGesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Overlays (Inbox/Popover)


- (IBAction) userTouchedNotificationButton: (UIButton*) button
{
    button.selected = !button.selected;
    
    if (button.selected)
    {
        SYNActivityPopoverViewController *actionPopoverController = [[SYNActivityPopoverViewController alloc] init];
        // Need show the popover controller
        self.notificationsPopoverController = [[UIPopoverController alloc] initWithContentViewController: actionPopoverController];
        self.notificationsPopoverController.popoverContentSize = CGSizeMake(320, 166);
        self.notificationsPopoverController.delegate = self;
        self.notificationsPopoverController.popoverBackgroundViewClass = [SYNAutocompletePopoverBackgroundView class];
        
        [self.notificationsPopoverController presentPopoverFromRect: button.frame
                                                             inView: self.view
                                           permittedArrowDirections: UIPopoverArrowDirectionUp
                                                           animated: YES];
    }
    
}


- (IBAction) userTouchedInboxButton: (UIButton*) button
{
    if (button.selected)
    {
        button.selected = NO;
        [self hideOverlay: self.inboxOverlayViewController];
    }
    else
    {
        button.selected = YES;
        [self showOrSwapOverlay: self.inboxOverlayViewController];
    }
}


- (void) showOrSwapOverlay: (UIViewController*) overlayViewController
{
    if (self.currentOverlayViewController && self.currentOverlayViewController != overlayViewController)
    {
        [self hideOverlay: self.currentOverlayViewController
         withCompletionBlock: ^(BOOL finished)
         {
             [self showOverlay:overlayViewController];
         }];
    }
    else
    {
        [self showOverlay:overlayViewController];
    }
}


// Show Overlay

- (void) showOverlay: (UIViewController*) overlayViewController
{
    [self showOverlay: overlayViewController withCompletionBlock:nil];
}

- (void) showOverlay: (UIViewController *) overlayViewController
         withCompletionBlock: (AnimationCompletionBlock) block
{
    self.currentOverlayViewController = overlayViewController;
    
    CGRect overlayViewFrame = overlayViewController.view.frame;
    
    // Don't reshow panel if it is alreay showing
    if (overlayViewFrame.origin.x < 0)
    {
        [[SYNSoundPlayer sharedInstance] playSoundByName:kSoundNewSlideIn];
        
        // Take out of screen
        overlayViewController.view.frame =  CGRectMake(-overlayViewFrame.size.width,
                                                       overlayViewController.view.frame.origin.y,
                                                       overlayViewFrame.size.width,
                                                       overlayViewFrame.size.height);
        
        [self.slidersView addSubview: overlayViewController.view];
        
        [UIView animateWithDuration: kRockieTalkieAnimationDuration
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^{
                             
                             overlayViewController.view.frame =  CGRectMake(0.0,
                                                                            overlayViewFrame.origin.y,
                                                                            overlayViewFrame.size.width,
                                                                            overlayViewFrame.size.height);
                             
                         } completion: ^(BOOL finished) {
                             if(block) block(finished);
                         }];
    }
}

// Hide Overlay

- (void) hideOverlay: (UIViewController*) overlayViewController
{
    [self hideOverlay: overlayViewController
          withCompletionBlock: nil];
}

- (void) hideOverlay: (UIViewController *) overlayViewController
         withCompletionBlock: (AnimationCompletionBlock) block
{
    // If we are hding the inbox panel, ensure that we deselect the con
    if (self.currentOverlayViewController == self.inboxOverlayViewController)
    {
        self.inboxButton.selected = FALSE;
    }
    
    CGRect overlayViewFrame = overlayViewController.view.frame;
    
    [[SYNSoundPlayer sharedInstance] playSoundByName: kSoundNewSlideOut];
    
    [UIView animateWithDuration: kRockieTalkieAnimationDuration
     delay: 0.0f
     options: UIViewAnimationOptionCurveEaseInOut
     animations: ^
     {
         overlayViewController.view.frame =  CGRectMake(-overlayViewFrame.size.width,
                                                        overlayViewFrame.origin.y,
                                                        overlayViewFrame.size.width,
                                                        overlayViewFrame.size.height);
     }
     completion: ^(BOOL finished)
     {
         [overlayViewController.view removeFromSuperview];
         self.currentOverlayViewController = nil;
         if (block)
         {
             block(finished);
         }
     }];
}

- (void) sharePanelRequested: (NSNotification*) notification
{
    [self showOrSwapOverlay:self.shareOverlayViewController];
}


- (void) panelSwipedAway: (NSNotification*) notification
{
    NSLog (@"Swiped");
    
    if (self.inboxButton.selected == TRUE)
    {
        self.inboxButton.selected = FALSE;
        [self hideOverlay: self.inboxOverlayViewController];
    }
    else
    {
        [self hideOverlay: self.shareOverlayViewController];
    }
}


#pragma mark - Video Overlay View
- (void) addVideoOverlayToViewController: (UIViewController *) originViewController
            withFetchedResultsController: (NSFetchedResultsController*) fetchedResultsController
                            andIndexPath: (NSIndexPath *) indexPath;
{
    // Remember the view controller that we came from
    self.originViewController = originViewController;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kVideoQueueHide
                                                        object:self];
    
    SYNBottomTabViewController* bottomTabViewController = (SYNBottomTabViewController*)self.rootViewController;
    
    self.videoViewerViewController = [[SYNVideoViewerViewController alloc] initWithFetchedResultsController: fetchedResultsController
                                                                                          selectedIndexPath: (NSIndexPath *) indexPath];
    [self.overlayView addSubview:self.videoViewerViewController.view];
    
    self.videoViewerViewController.view.alpha = 0.0f;
    self.videoViewerViewController.overlayParent = self;
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
         self.videoViewerViewController.view.alpha = 1.0f;
     }
     completion: ^(BOOL finished)
     {
        self.overlayView.userInteractionEnabled = YES;
         
         // == Add video queue == //
         
         UIView* queueView = bottomTabViewController.videoQueueController.view;
         
         [queueView removeFromSuperview];
         
         queueView.center = CGPointMake(queueView.center.x, queueView.center.y + queueView.frame.size.height * 0.5);
         
         [self.view insertSubview:queueView aboveSubview:self.overlayView];
     }];
}

- (void) removeVideoOverlayController
{
    SYNBottomTabViewController* bottomTabViewController = (SYNBottomTabViewController*)self.rootViewController;
    
    UIView* child = self.overlayView.subviews[0];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kVideoQueueHide
                                                        object: self];
    
    [UIView animateWithDuration: 0.25f
     delay: 0.0f
     options: UIViewAnimationOptionCurveEaseInOut
     animations: ^
     {
         child.alpha = 0.0f;
     }
     completion: ^(BOOL finished)
     {
         self.overlayView.userInteractionEnabled = NO;
         self.videoViewerViewController = nil;
         [child removeFromSuperview];
         [bottomTabViewController.videoQueueController.view removeFromSuperview];
         [bottomTabViewController repositionQueueView];
     }];

}

- (void) addCategoryChooserOverlayToViewController: (UIViewController *) originViewController
{
    // Remember the view controller that we came from
    self.originViewController = originViewController;

    self.categoryChooserViewController = [[SYNCategoryChooserViewController alloc] init];
    
    [self.overlayView addSubview: self.categoryChooserViewController.view];
    
    self.categoryChooserViewController.view.alpha = 0.0f;
    self.categoryChooserViewController.overlayParent = self;
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         self.categoryChooserViewController.view.alpha = 1.0f;
     }
                     completion: ^(BOOL finished)
     {
         self.overlayView.userInteractionEnabled = YES;
     }];
}

- (void) removeCategoryChooserOverlayController
{
    SYNBottomTabViewController* bottomTabViewController = (SYNBottomTabViewController*)self.rootViewController;
    
    UIView* child = self.overlayView.subviews[0];
    
    [UIView animateWithDuration: 0.25f
     delay: 0.0f
     options: UIViewAnimationOptionCurveEaseInOut
     animations: ^
     {
         child.alpha = 0.0f;
     }
     completion: ^(BOOL finished)
     {
         self.overlayView.userInteractionEnabled = NO;
         self.videoViewerViewController = nil;
         [child removeFromSuperview];
         [bottomTabViewController.videoQueueController.view removeFromSuperview];
         [bottomTabViewController repositionQueueView];
     }];

}


#pragma mark - TextField Delegate Methods

- (IBAction) clearSearchField: (id) sender
{
    self.searchTextField.text = @"";
    
    [UIView animateWithDuration:0.1 animations:^{
        self.glowTextImageView.alpha = 0.0;
    }];
    
    self.clearTextButton.alpha = 0.0;
    
    [self.searchTextField resignFirstResponder];
}


- (void) textViewDidChange: (UITextView *) textView
{
    
}



- (void) textViewDidBeginEditing: (UITextView *) textView
{
    [textView setText: @""];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)newCharacter
{
    // 1. Do not accept blank characters at the beggining of the field
    
    if([newCharacter isEqualToString:@" "] && self.searchTextField.text.length == 0)
        return NO;
    
    
//    if(self.searchTextField.text.length < 1)
//        return YES;
    
    if(self.autocompleteTimer) {
        [self.autocompleteTimer invalidate];
    }
    
    self.autocompleteTimer = [NSTimer scheduledTimerWithTimeInterval:kAutocompleteTime
                                                              target:self
                                                            selector:@selector(performAutocompleteSearch:)
                                                            userInfo:nil
                                                             repeats:NO];
    return YES;
}

-(void)performAutocompleteSearch:(NSTimeInterval*)interval
{
    
    if(self.searchTextField.text.length == 0) {
        [UIView animateWithDuration:0.5 animations:^{
            self.clearTextButton.alpha = 0.0;
        }];
        
    } else {
        [UIView animateWithDuration:0.1 animations:^{
            self.clearTextButton.alpha = 1.0;
        }];
    }
        
    
    [self.autocompleteTimer invalidate];
    
    self.autocompleteTimer = nil;
    
    
    [appDelegate.networkEngine getAutocompleteForHint:self.searchTextField.text
                                          forResource:EntityTypeVideo
                                         withComplete:^(NSArray* array) {
        
                                             NSArray* suggestionsReturned = [array objectAtIndex:1];
        
                                             NSMutableArray* wordsReturned = [NSMutableArray array];
                                             
                                             if(suggestionsReturned.count == 0) {
                                                 
                                                 [self.autocompleteController clearWords];
                                                 
                                                 [self.autocompletePopoverController dismissPopoverAnimated:NO];
                                                 
                                                 self.autocompletePopoverController = nil;
                                                 
                                                 return;
                                             }
        
                                             for (NSArray* suggestion in suggestionsReturned)
                                                 [wordsReturned addObject:[suggestion objectAtIndex:0]];
                                             
                                             [self.autocompleteController addWords:wordsReturned];
        
                                             [self showAutocompletePopover];
        
        
                                         } andError:^(NSError* error) {
                                             
                                             [self.notificationsPopoverController dismissPopoverAnimated:YES];
                                         
                                         }];
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    
    if ([self.searchTextField.text isEqualToString:@""])
        return NO;
    
    [self.autocompleteTimer invalidate];
    self.autocompleteTimer = nil;
    
    [((SYNBottomTabViewController*)self.rootViewController) showSearchViewControllerWithTerm: self.searchTextField.text];
    
    [textField resignFirstResponder];
    
    [UIView animateWithDuration:0.1 animations:^{
        self.glowTextImageView.alpha = 0.0;
    }];
    
    if(self.autocompletePopoverController) {
        [self.autocompletePopoverController dismissPopoverAnimated:NO];
        self.autocompletePopoverController = nil;
    }
        
    
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.1 animations:^{
        self.glowTextImageView.alpha = 1.0;
    }];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.1 animations:^{
        self.glowTextImageView.alpha = 0.0;
    }];
}


#pragma mark - Notification Handlers

-(void)backButtonRequested:(NSNotification*)notification
{
    
    NSString* notificationName = [notification name];
    
    SYNBottomTabViewController* bottomTabController = (SYNBottomTabViewController*)self.rootViewController;
    
    if([notificationName isEqualToString:kNoteBackButtonShow])
    {
        [self.backButton addTarget:bottomTabController action:@selector(popCurrentViewController:) forControlEvents:UIControlEventTouchUpInside];
        [self showBackButton:YES];
    }
    else
    {
        [self.backButton removeTarget:bottomTabController action:@selector(popCurrentViewController:) forControlEvents:UIControlEventTouchUpInside];
        [self showBackButton:NO];
    }
}

- (void) showBackButton: (BOOL) show
{
    CGRect targetFrame;
    CGFloat targetAlpha;
    
    if (show)
    {
        targetFrame = self.topButtonsContainer.frame;
        targetFrame.origin.x = 15;
        targetAlpha = 1.0;
    }
    else
    {
        targetFrame = self.topButtonsContainer.frame;
        targetFrame.origin.x = (-60);
        targetAlpha = 0.0;
    }
    
    [UIView animateWithDuration: 0.4f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
                     {
                        self.topButtonsContainer.frame = targetFrame;
                        self.backButton.alpha = targetAlpha;
                     }
                     completion: ^(BOOL finished)
                     {
                     }];

}


- (void) tabPressed: (NSNotification*) notification
{
    self.searchTextField.text = @"";
}


#pragma mark - Autocomplete Methods

- (void) tableView: (UITableView *) tableView
         didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    NSString* wordsSelected = [self.autocompleteController getWordAtIndex: indexPath.row];
    self.searchTextField.text = wordsSelected;
    
    [self textFieldShouldReturn: self.searchTextField];
}


-(void)showAutocompletePopover
{
    // 1. This only adds the popover and not the data, so if it is on, exit
    if(self.autocompletePopoverController)
        return;
    
    // 2. Add a UINavigationController to add the title at the top of the Popover.
    
    UINavigationController* controllerForTitle = [[UINavigationController alloc] initWithRootViewController:self.autocompleteController];
    
    self.autocompletePopoverController = [[UIPopoverController alloc] initWithContentViewController: controllerForTitle];
    self.autocompletePopoverController.popoverContentSize = CGSizeMake(280, 326);
    self.autocompletePopoverController.delegate = self;
    
    
    self.autocompletePopoverController.popoverBackgroundViewClass = [SYNAutocompletePopoverBackgroundView class];
    
    [self.autocompletePopoverController presentPopoverFromRect: self.searchTextField.frame
                                                        inView: self.view
                                      permittedArrowDirections: UIPopoverArrowDirectionUp
                                                      animated: YES];
}

-(void)hideAutocompletePopover
{
    if(!self.autocompletePopoverController)
        return;
    
    [self.autocompletePopoverController dismissPopoverAnimated:YES];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if(popoverController == self.notificationsPopoverController)
    {
        self.notificationButton.selected = NO;
        self.notificationsPopoverController = nil;
    }
    else if(popoverController == self.autocompletePopoverController)
    {
        self.autocompletePopoverController = nil;
    }
}

@end
