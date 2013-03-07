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
#import "SYNSuggestionsPopoverBackgroundView.h"
#import "SYNBottomTabViewController.h"

#import "SYNVideoViewerViewController.h"

#import <QuartzCore/QuartzCore.h>

#define kAutocompleteTime 0.3

typedef void(^AnimationCompletionBlock)(BOOL finished);

@interface SYNMasterViewController ()

@property (nonatomic, strong) IBOutlet UIView* topBarView;


@property (nonatomic, strong) SYNVideoViewerViewController *videoViewerViewController;

@property (nonatomic, strong) IBOutlet UILabel* inboxLabel;
@property (nonatomic, strong) IBOutlet UILabel* notificationsLabel;

@property (nonatomic, strong) NSTimer* autocompleteTimer;


@property (nonatomic, strong) IBOutlet UIView* overlayView;

@property (nonatomic, strong) IBOutlet UIButton* inboxButton;
@property (nonatomic, strong) IBOutlet UIButton* notificationButton;

@property (nonatomic, strong) SYNAutocompleteViewController* autocompleteController;
@property (nonatomic, strong) IBOutlet UIView* topButtonsContainer;
@property (nonatomic, strong) IBOutlet UIView* slidersView;
@property (nonatomic, strong) IBOutlet UITextField* searchTextField;
@property (nonatomic, strong) IBOutlet UIButton* backButton;

@property (nonatomic, strong) SYNInboxOverlayViewController* inboxOverlayViewController;
@property (nonatomic, strong) SYNShareOverlayViewController* shareOverlayViewController;
@property (nonatomic, weak) UIViewController* currentOverlayController;



@property (nonatomic, strong) UIPopoverController* notificationsPopoverController;
@property (nonatomic, strong) UIPopoverController* autocompletePopoverController;

@end

@implementation SYNMasterViewController

@synthesize rootViewController = rootViewController;
@synthesize notificationsPopoverController = notificationsPopoverController;
@synthesize autocompleteTimer;

#pragma mark - Initialise

-(id)initWithRootViewController:(UIViewController*)root
{
    self = [super initWithNibName:@"SYNMasterViewController" bundle:nil];
    if (self) {
        
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        self.rootViewController = root;
        
        self.inboxOverlayViewController = [[SYNInboxOverlayViewController alloc] init];
        self.shareOverlayViewController = [[SYNShareOverlayViewController alloc] init];
        
        self.autocompleteController = [[SYNAutocompleteViewController alloc] init];
        
        self.autocompleteController.tableView.delegate = self;
        
        
        
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
    
    self.slidersView.userInteractionEnabled = NO;
    
    // == Add the Root Controller which will contain all others (Tabs in our case) == //
    
    [self.containerView addSubview:rootViewController.view];
    
    self.backButton.alpha = 0.0;
    
    self.topButtonsContainer.userInteractionEnabled = YES;
    
    // == Set Up Labels == /
    
    UIFont* boldFont = [UIFont boldRockpackFontOfSize:17.0f];
    
    self.inboxLabel.font = boldFont;
    self.notificationsLabel.font = boldFont;
    
    // == Set up Recognisers == //
    
    UISwipeGestureRecognizer* rightSwipeRecogniser = [[UISwipeGestureRecognizer alloc] initWithTarget: self
                                                                                               action: @selector(swipeGesturePerformed:)];
    
    [rightSwipeRecogniser setDirection: UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipeRecogniser];
    
    rightSwipeRecogniser.delegate = self;
    
    
    UISwipeGestureRecognizer* leftSwipeRecogniser = [[UISwipeGestureRecognizer alloc] initWithTarget: self
                                                                                              action: @selector(swipeGesturePerformed:)];
    
    [leftSwipeRecogniser setDirection: UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer: leftSwipeRecogniser];
    
    
    leftSwipeRecogniser.delegate = self;
    
    
    // == Set Up Notifications == //
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backButtonRequested:) name:kNoteBackButtonShow object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backButtonRequested:) name:kNoteBackButtonHide object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabPressed:) name:kNoteTabPressed object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sharePanelRequested:) name:kNoteSharePanelRequested object:nil];
    
    
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
        self.notificationsPopoverController.popoverBackgroundViewClass = [SYNSuggestionsPopoverBackgroundView class];
        
        [self.notificationsPopoverController presentPopoverFromRect: button.frame
                                                             inView: self.view
                                           permittedArrowDirections: UIPopoverArrowDirectionUp
                                                           animated: YES];
    }
    
}

- (IBAction) userTouchedInboxButton: (UIButton*) button
{
    
    
    if(button.selected)
    {
        button.selected = NO;
        [self hideOverlay:self.inboxOverlayViewController];
    }
    else
    {
        button.selected = YES;
        [self showOrSwapOverlay:self.inboxOverlayViewController];
    }
    
    
}

-(void)showOrSwapOverlay: (UIViewController*) overlayViewController
{
    if(self.currentOverlayController && self.currentOverlayController != overlayViewController)
    {
        [self hideOverlay:self.currentOverlayController withCompletionBlock:^(BOOL finished) {
            [self showOverlay:overlayViewController];
        }];
    }
    else
    {
        [self showOverlay:overlayViewController];
    }
}


// Show Overlay

-(void)showOverlay: (UIViewController*) overlayViewController
{
    [self showOverlay: overlayViewController withCompletionBlock:nil];
}

-(void)showOverlay: (UIViewController *) overlayViewController withCompletionBlock:(AnimationCompletionBlock)block
{
    self.currentOverlayController = overlayViewController;
    
    CGRect overlayViewFrame = overlayViewController.view.frame;
    
    
    [[SYNSoundPlayer sharedInstance] playSoundByName:kSoundNewSlideIn];
    
    // Take out of screen
    overlayViewController.view.frame =  CGRectMake(-overlayViewFrame.size.width,
                                                   0.0,
                                                   overlayViewFrame.size.width,
                                                   overlayViewFrame.size.height);
    
    [self.slidersView addSubview:overlayViewController.view];
    
    [UIView animateWithDuration: kRockieTalkieAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         
                         overlayViewController.view.frame =  CGRectMake(0.0, 0.0, overlayViewFrame.size.width, overlayViewFrame.size.height);
                         
                     } completion: ^(BOOL finished) {
                         if(block) block(finished);
                     }];
}

// Hide Overlay

-(void)hideOverlay: (UIViewController*) overlayViewController
{
    [self hideOverlay:overlayViewController withCompletionBlock:nil];
}

-(void)hideOverlay: (UIViewController *) overlayViewController withCompletionBlock:(AnimationCompletionBlock)block
{
    CGRect overlayViewFrame = overlayViewController.view.frame;
    
    
    [[SYNSoundPlayer sharedInstance] playSoundByName:kSoundNewSlideOut];
    
    [UIView animateWithDuration: kRockieTalkieAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         
                         overlayViewController.view.frame =  CGRectMake(-overlayViewFrame.size.width, 0.0, overlayViewFrame.size.width, overlayViewFrame.size.height);
                         
                     } completion: ^(BOOL finished) {
                         [overlayViewController.view removeFromSuperview];
                         self.currentOverlayController = nil;
                         if(block) block(finished);
                     }];
}



#pragma mark - Video Overlay View

-(void)addVideoOverlayWithFetchedResultsController:(NSFetchedResultsController*)fetchedResultsController andIndexPath:(NSIndexPath *)indexPath
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kVideoQueueHide
                                                        object:self];
    
    SYNBottomTabViewController* bottomTabViewController = (SYNBottomTabViewController*)self.rootViewController;
    
    
    self.videoViewerViewController = [[SYNVideoViewerViewController alloc] initWithFetchedResultsController: fetchedResultsController
                                                                                          selectedIndexPath: (NSIndexPath *) indexPath];
    [self.overlayView addSubview:self.videoViewerViewController.view];
    
    
    
    
    self.videoViewerViewController.view.alpha = 0.0f;
    
    
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         
                         self.videoViewerViewController.view.alpha = 1.0f;
                     }
                     completion: ^(BOOL finished) {
                         
                        
                        [self.videoViewerViewController.closeButton addTarget: self
                                                                       action: @selector(removeVideoOverlayController)
                                                             forControlEvents: UIControlEventTouchUpInside];
                          
                        self.overlayView.userInteractionEnabled = YES;
                         
                         // == Add video queue == //
                         
                         UIView* queueView = bottomTabViewController.videoQueueController.view;
                         
                         [queueView removeFromSuperview];
                         
                         queueView.center = CGPointMake(queueView.center.x, queueView.center.y + queueView.frame.size.height * 0.5);
                         
                         [self.overlayView addSubview:queueView];
                         
                     }];
}

-(void)removeVideoOverlayController
{
    SYNBottomTabViewController* bottomTabViewController = (SYNBottomTabViewController*)self.rootViewController;
    
    UIView* child = self.overlayView.subviews[0];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kVideoQueueHide
                                                        object:self];
    
    [UIView animateWithDuration: 0.25f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         
                         child.alpha = 0.0f;
                     }
                     completion: ^(BOOL finished) {
         
                         self.overlayView.userInteractionEnabled = NO;
                        
                         self.videoViewerViewController = nil;
                         
                         
                         [bottomTabViewController repositionQueueView];
                         
                     }];
}








#pragma mark - TextField Delegate Methods

- (IBAction) clearSearchField: (id) sender
{
    self.searchTextField.text = @"";
    
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
    
    [self.autocompleteTimer invalidate];
    
    self.autocompleteTimer = nil;
    
    [appDelegate.networkEngine getAutocompleteForHint:self.searchTextField.text forResource:EntityTypeVideo withComplete:^(NSArray* array) {
        
        NSArray* suggestionsReturned = [array objectAtIndex:1];
        
        NSMutableArray* wordsReturned = [NSMutableArray array];
        
        for (NSArray* suggestion in suggestionsReturned) {
            [wordsReturned addObject:[suggestion objectAtIndex:0]];
        }
        
        
        [self.autocompleteController addWords:wordsReturned];
        
        if(!self.autocompletePopoverController)
            [self showAutocompletePopover];
        
        
        
        
    } andError:^(NSError* error) {
        [self.notificationsPopoverController dismissPopoverAnimated:YES];
    }];
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    

    
    NSString* searchTerm = self.searchTextField.text;
    
    // remove whitespace from beginning and end of string so as to check easily if it is blank
    searchTerm = [searchTerm stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    
    if ([searchTerm isEqualToString:@""])
        return NO;
    
    [((SYNBottomTabViewController*)self.rootViewController) showSearchViewControllerWithTerm: self.searchTextField.text];
    
    [textField resignFirstResponder];
    
    if(self.autocompletePopoverController)
        [self.autocompletePopoverController dismissPopoverAnimated:NO];
    
    
    return YES;
}



#pragma mark - Gesture Recogniser Delegate

-(void)swipeGesturePerformed:(UIGestureRecognizer*)recogniser
{
    UISwipeGestureRecognizerDirection direction = ((UISwipeGestureRecognizer*)recogniser).direction;
    if(direction == UISwipeGestureRecognizerDirectionRight)
    {
        
        self.inboxButton.selected = YES;
        if(!self.currentOverlayController) {
            [self showOverlay:self.inboxOverlayViewController withCompletionBlock:nil];
        }
        
    }
    else if(direction == UISwipeGestureRecognizerDirectionLeft)
    {
        self.inboxButton.selected = NO;
        if(self.currentOverlayController) {
            [self hideOverlay:self.currentOverlayController withCompletionBlock:nil];
        }
    }
}

- (BOOL) gestureRecognizer: (UIGestureRecognizer *) gestureRecognizer shouldReceiveTouch: (UITouch *) touch
{
    // TODO: Look into the exact conditions where the user can swipe
    return YES;
}


- (BOOL) gestureRecognizerShouldBegin: (UIGestureRecognizer *) gestureRecognizer
{
    // TODO: Look into the exact conditions where the user can swipe
    return YES;
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

- (void) showBackButton:(BOOL)show
{
    CGPoint currentPoint = self.topButtonsContainer.center;
    
    CGPoint targetPoint;
    CGFloat targetAlpha;
    
    
    if(show)
    {
        targetPoint = CGPointMake(currentPoint.x + 60.0, self.topButtonsContainer.center.y);
        targetAlpha = 1.0;
        
    }
    else
    {
        targetPoint = CGPointMake(currentPoint.x - 60.0, self.topButtonsContainer.center.y);
        targetAlpha = 0.0;
    }
    
    [UIView animateWithDuration: 0.4f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
                    {
                         
                         self.topButtonsContainer.center = targetPoint;
                         self.backButton.alpha = targetAlpha;
                         
                     } completion: ^(BOOL finished) {
                         
                         
                         
                     }];
    
}


-(void)tabPressed:(NSNotification*)notification
{
    self.searchTextField.text = @"";
}

-(void)sharePanelRequested:(NSNotification*)notification
{
    
    [self showOrSwapOverlay:self.shareOverlayViewController];
}


#pragma mark - Autocomplete Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* wordsSelected = [self.autocompleteController getWordAtIndex:indexPath.row];
    self.searchTextField.text = wordsSelected;
    
    [self textFieldShouldReturn:self.searchTextField];
}


-(void)showAutocompletePopover
{
    
    // 1. Add a UINavigationController to add the title at the top of the Popover.
    
    UINavigationController* controllerForTitle = [[UINavigationController alloc] initWithRootViewController:self.autocompleteController];
    
    self.autocompletePopoverController = [[UIPopoverController alloc] initWithContentViewController: controllerForTitle];
    self.autocompletePopoverController.popoverContentSize = CGSizeMake(280, 326);
    self.autocompletePopoverController.delegate = self;
    
    
    self.autocompletePopoverController.popoverBackgroundViewClass = [SYNSuggestionsPopoverBackgroundView class];
    
    [self.autocompletePopoverController presentPopoverFromRect: self.searchTextField.frame
                                                        inView: self.view
                                      permittedArrowDirections: UIPopoverArrowDirectionUp
                                                      animated: YES];
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
