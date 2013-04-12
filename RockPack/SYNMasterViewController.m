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
#import "SYNSideNavigationViewController.h"
#import "SYNContainerViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNAutocompleteViewController.h"
#import "SYNSoundPlayer.h"
#import "SYNAutocompletePopoverBackgroundView.h"
#import "SYNContainerViewController.h"

#import "SYNVideoViewerViewController.h"
#import "SYNAccountSettingsMainTableViewController.h"
#import "SYNCategoryChooserViewController.h"
#import "SYNRefreshButton.h"


#import <QuartzCore/QuartzCore.h>

#define kAutocompleteTime 0.2

typedef void(^AnimationCompletionBlock)(BOOL finished);

@interface SYNMasterViewController ()

@property (nonatomic, strong) IBOutlet UIButton* backButton;
@property (nonatomic, strong) IBOutlet UIButton* clearTextButton;
@property (nonatomic, strong) IBOutlet UIButton* addToChannelButton;
@property (nonatomic, strong) IBOutlet UITextField* searchTextField;
@property (nonatomic, strong) IBOutlet UIView* overlayView;
@property (nonatomic, strong) IBOutlet UIView* navigatioContainerView;
@property (nonatomic, strong) IBOutlet UIView* topBarView;
@property (nonatomic, strong) IBOutlet UIView* dotsView;
@property (nonatomic, strong) IBOutlet UILabel* pageTitleLabel;
@property (nonatomic, strong) IBOutlet UIView* movableButtonsContainer;


@property (nonatomic, strong) SYNRefreshButton* refreshButton;

@property (nonatomic, strong) NSTimer* autocompleteTimer;

@property (nonatomic) CGRect addToChannelFrame;

@property (nonatomic, strong) SYNAutocompleteViewController* autocompleteController;


@property (nonatomic, strong) SYNVideoViewerViewController *videoViewerViewController;
@property (nonatomic, strong) SYNCategoryChooserViewController *categoryChooserViewController;
@property (nonatomic, strong) UIPopoverController* autocompletePopoverController;

@property (nonatomic, strong) SYNSideNavigationViewController* sideNavigationViewController;
@property (nonatomic) BOOL sideNavigationOn;


@end

@implementation SYNMasterViewController

@synthesize containerViewController;
@synthesize autocompleteTimer;
@synthesize pageTitleLabel;
@synthesize addToChannelFrame;
@synthesize sideNavigationOn;

#pragma mark - Initialise

-(id)initWithContainerViewController:(SYNContainerViewController*)root
{
    if ((self = [super initWithNibName: @"SYNMasterViewController" bundle: nil]))
    {
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        self.containerViewController = root;

        
        // == Side Navigation == //
        
        self.sideNavigationViewController = [[SYNSideNavigationViewController alloc] init];
        CGRect sideNavigationFrame = self.sideNavigationViewController.view.frame;
        sideNavigationFrame.origin.x = 1024.0;
        sideNavigationFrame.origin.y = 45.0;
        self.sideNavigationViewController.view.frame = sideNavigationFrame;
        self.sideNavigationViewController.user = appDelegate.currentUser;
        
        UISwipeGestureRecognizer* swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(sideNavigationSwiped)];
        swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
        [self.sideNavigationViewController.view addGestureRecognizer:swipeGesture];
        
        
        sideNavigationOn = NO;
        
        
        self.autocompleteController = [[SYNAutocompleteViewController alloc] init];
        
        self.autocompleteController.tableView.delegate = self;
        
        self.overEverythingView.userInteractionEnabled = NO;
        
        
        
    }
    return self;
}




#pragma mark - Life Cycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // == Refresh button == //
    
    self.refreshButton = [SYNRefreshButton refreshButton];
    [self.refreshButton addTarget:self action:@selector(refreshButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    CGRect refreshButtonFrame = self.refreshButton.frame;
    refreshButtonFrame.origin.x = 54.0f;
    self.refreshButton.frame = refreshButtonFrame;
    [self.movableButtonsContainer addSubview:self.refreshButton];
    
    self.clearTextButton.alpha = 0.0;
    
    // == Fade in from splash screen (not in AppDelegate so that the Orientation is known) == //
    
    UIImageView *splashView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 1024, 748)];
    splashView.image = [UIImage imageNamed:  @"Default-Landscape.png"];
	[self.view addSubview: splashView];
    
    [UIView animateWithDuration: kSplashAnimationDuration
                          delay: kSplashViewDuration
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         splashView.alpha = 0.0f;
                     } completion: ^(BOOL finished) {
                         splashView.alpha = 0.0f;
                         [splashView removeFromSuperview];
                     }];
    
    self.navigatioContainerView.userInteractionEnabled = YES;
    
    
    
    // == Add the Root Controller which will contain all others (Tabs in our case) == //
    
    CGRect containerViewFrame = self.containerViewController.view.frame;
    containerViewFrame.origin.y = 32.0;
    self.containerViewController.view.frame = containerViewFrame;
    [self.containerView addSubview:containerViewController.view];
    
    self.backButton.alpha = 0.0;
    
    self.movableButtonsContainer.userInteractionEnabled = YES;
    
    
    
    self.pageTitleLabel.font = [UIFont boldRockpackFontOfSize:30];
    self.pageTitleLabel.textColor = [UIColor colorWithRed:(40.0/255.0)
                                                    green:(45.0/255.0)
                                                     blue:(51.0/255.0)
                                                    alpha:(1.0)];
    
    
    // == Add to Channel Button == //
    
    originalAddButtonX = self.addToChannelButton.frame.origin.x;
    addToChannelFrame = self.addToChannelButton.frame;
    
    
    // == Set up Dots View == //
    
    self.dotsView.backgroundColor = [UIColor clearColor];
    
    
    for(int i = 0; i < 3; i++)
    {
        UIImageView* dotImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavigationDot"]];
        CGRect dotImageViewFrame = dotImageView.frame;
        dotImageViewFrame.origin.x = i * 30.0;
        dotImageView.frame = dotImageViewFrame;
        [self.dotsView addSubview:dotImageView];
        
        UITapGestureRecognizer* tapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dotTapped:)];
        [dotImageView addGestureRecognizer:tapGestureRecogniser];
     }
    
    [self pageChanged:self.containerViewController.page];
    
    
    // == Set Up Notifications == //
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backButtonRequested:) name:kNoteBackButtonShow object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backButtonRequested:) name:kNoteBackButtonHide object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabPressed:) name:kNoteTabPressed object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollerPageChanged:) name:kScrollerPageChanged object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigateToPage:) name:kNavigateToPage object:nil];
    
    
    [self.containerViewController.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
    
    // Add swipe-away gesture
    UISwipeGestureRecognizer* inboxLeftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget: self
                                                                                                action: @selector(panelSwipedAway)];
    inboxLeftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.navigatioContainerView addGestureRecognizer: inboxLeftSwipeGesture];
    
    
}

-(void)refreshButtonPressed
{
    
    [self.refreshButton startRefreshCycle];
    
    [self.containerViewController.showingViewController refresh];
}

-(void)scrollerPageChanged:(NSNotification*)notification
{
    NSNumber* pageNumber = [[notification userInfo] objectForKey:kCurrentPage];
    if(!pageNumber)
        return;
    
    [self pageChanged:[pageNumber integerValue]];
    
    
}

-(void)pageChanged:(NSInteger)pageNumber
{
    int totalDots = self.dotsView.subviews.count;
    UIImageView* dotImageView;
    for (int i = 0; i < totalDots; i++)
    {
        dotImageView = (UIImageView*)self.dotsView.subviews[i];
        if (i == pageNumber) {
            dotImageView.image = [UIImage imageNamed:@"NavigationDotCurrent"];
            continue;
        }
        
        dotImageView.image = [UIImage imageNamed:@"NavigationDot"];
        
    }
    
    originalAddButtonX = self.addToChannelButton.frame.origin.x;
    
    self.pageTitleLabel.text = [self.containerViewController.showingViewController.title uppercaseString];
}



-(void)panelSwipedAway
{
    [self hideSideNavigation];
}

-(IBAction)addToChannelPressed:(id)sender
{
    
    
    
}


#pragma mark - Navigation Panel Methods

-(IBAction)showAndHideSideNavigation:(UIButton*)sender
{
    if(sideNavigationOn) {
        [self hideSideNavigation];
        sender.highlighted = NO;
    }

    else {
        [self showSideNavigation];
        sender.highlighted = YES;
    }
        
}

- (void) showSideNavigation
{
    
    if(sideNavigationOn)
        return;
    
    self.sideNavigationOn = YES;
    
    [self.navigatioContainerView addSubview:self.sideNavigationViewController.view];
    
    [[SYNSoundPlayer sharedInstance] playSoundByName:kSoundNewSlideIn];
    
    
    [UIView animateWithDuration: kRockieTalkieAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations: ^{
                         
                         CGRect sideNavigationFrame = self.sideNavigationViewController.view.frame;
                         
                         sideNavigationFrame.origin.x = sideNavigationFrame.origin.x -sideNavigationFrame.size.width;
                         self.sideNavigationViewController.view.frame =  sideNavigationFrame;
                         
                     } completion: ^(BOOL finished) {
                         
                     }];
}



-(void)sideNavigationSwiped
{
    [self hideSideNavigation];
}

- (void) hideSideNavigation
{
    
    if(!sideNavigationOn)
        return;
    
    self.sideNavigationOn = NO;
    
    [[SYNSoundPlayer sharedInstance] playSoundByName: kSoundNewSlideOut];
    
    [UIView animateWithDuration: kRockieTalkieAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations: ^ {
                         
                         CGRect sideNavigationFrame = self.sideNavigationViewController.view.frame;
                         sideNavigationFrame.origin.x = 1024;
                         self.sideNavigationViewController.view.frame =  sideNavigationFrame;
                         
                     } completion: ^(BOOL finished) {
                         
                         [self.sideNavigationViewController reset];
                         [self.sideNavigationViewController.view removeFromSuperview];
                         
                         
                     }];
}






#pragma mark - Video Overlay View

- (void) addVideoOverlayToViewController: (UIViewController *) originViewController
            withFetchedResultsController: (NSFetchedResultsController*) fetchedResultsController
                            andIndexPath: (NSIndexPath *) indexPath {
    
    // Remember the view controller that we came from
    self.originViewController = originViewController;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kVideoQueueHide
                                                        object:self];
    
    
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
         
         UIView* queueView = self.containerViewController.videoQueueController.view;
         
         [queueView removeFromSuperview];
         
         queueView.center = CGPointMake(queueView.center.x, queueView.center.y + queueView.frame.size.height * 0.5);
         
         [self.view insertSubview:queueView aboveSubview:self.overlayView];
     }];
}

- (void) removeVideoOverlayController
{
    SYNContainerViewController* bottomTabViewController = (SYNContainerViewController*)self.containerViewController;
    
    UIView* child = self.overlayView.subviews[0];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kVideoQueueHide
                                                        object: self];
    
    [UIView animateWithDuration: 0.25f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         child.alpha = 0.0f;
                     } completion: ^(BOOL finished) {
                         self.overlayView.userInteractionEnabled = NO;
                         self.videoViewerViewController = nil;
                         [child removeFromSuperview];
                         [bottomTabViewController.videoQueueController.view removeFromSuperview];
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
                     animations: ^{
                         self.categoryChooserViewController.view.alpha = 1.0f;
                     } completion: ^(BOOL finished) {
                         self.overlayView.userInteractionEnabled = YES;
                     }];
}

- (void) removeCategoryChooserOverlayController
{
    SYNContainerViewController* bottomTabViewController = (SYNContainerViewController*)self.containerViewController;
    
    UIView* child = self.overlayView.subviews[0];
    
    [UIView animateWithDuration: 0.25f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         child.alpha = 0.0f;
                     } completion: ^(BOOL finished) {
                         self.overlayView.userInteractionEnabled = NO;
                         self.videoViewerViewController = nil;
                         [child removeFromSuperview];
                         [bottomTabViewController.videoQueueController.view removeFromSuperview];
                     }];

}


#pragma mark - TextField Delegate Methods

-(IBAction)showSearchBoxField:(id)sender
{
    
}

- (IBAction) clearSearchField: (id) sender
{
    self.searchTextField.text = @"";
    
    
    
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
                                             
                                             
                                         
                                         }];
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    
    if ([self.searchTextField.text isEqualToString:@""])
        return NO;
    
    [self.autocompleteTimer invalidate];
    self.autocompleteTimer = nil;
    
    [((SYNContainerViewController*)self.containerViewController) showSearchViewControllerWithTerm: self.searchTextField.text];
    
    [textField resignFirstResponder];
    
    
    
    if(self.autocompletePopoverController) {
        [self.autocompletePopoverController dismissPopoverAnimated:NO];
        self.autocompletePopoverController = nil;
    }
        
    
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
}


#pragma mark - Notification Handlers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"contentOffset"]) {
        
        CGPoint newContentOffset = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
        // NSLog(@"Change: %f", newContentOffset.x);
        CGRect addButtonFrame;
        CGFloat diff = newContentOffset.x - self.containerViewController.currentPageOffset.x;
        SYNAbstractViewController* nextViewController = [self.containerViewController nextShowingViewController];
        
        if((nextViewController.needsAddButton && !self.containerViewController.showingViewController.needsAddButton) ||
           (!nextViewController.needsAddButton && self.containerViewController.showingViewController.needsAddButton)) {
            
            addButtonFrame = self.addToChannelButton.frame;
            addButtonFrame.origin.x = originalAddButtonX - diff;
            self.addToChannelButton.frame = addButtonFrame;
        }
    }
}

-(void)dotTapped:(UIGestureRecognizer*)recogniser
{
    
}

-(void)backButtonRequested:(NSNotification*)notification
{
    
    NSString* notificationName = [notification name];
    
    
    if([notificationName isEqualToString:kNoteBackButtonShow])
    {
        [self.backButton addTarget:containerViewController action:@selector(popCurrentViewController:) forControlEvents:UIControlEventTouchUpInside];
        [self showBackButton:YES];
    }
    else
    {
        [self.backButton removeTarget:containerViewController action:@selector(popCurrentViewController:) forControlEvents:UIControlEventTouchUpInside];
        [self showBackButton:NO];
    }
}


-(void)navigateToPage:(NSNotification*)notification
{
    
    NSString* pageName = [[notification userInfo] objectForKey:@"pageName"];
    if(!pageName)
        return;
    
    [self.containerViewController navigateToPageByName:pageName];
    
}

- (void) showBackButton: (BOOL) show
{
    CGRect targetFrame;
    CGFloat targetAlpha;
    
    if (show)
    {
        targetFrame = self.movableButtonsContainer.frame;
        targetFrame.origin.x = 30.0;
        targetAlpha = 1.0;
    }
    else
    {
        targetFrame = self.movableButtonsContainer.frame;
        targetFrame.origin.x = -44;
        targetAlpha = 0.0;
    }
    
    [UIView animateWithDuration: 0.6f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
                     {
                        self.movableButtonsContainer.frame = targetFrame;
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
    
}

#pragma mark - Helper Methods

-(void)showAddButton
{
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         
                         self.addToChannelButton.frame = self.addToChannelFrame;
        
                   } completion:^(BOOL finished) {
                       
                       
                
                   }];
    
}

-(void)hideAddButton
{
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         
                         self.addToChannelButton.alpha = 0.0;
                         
                     } completion:^(BOOL finished) {
                         
                         [self moveAddButtonOutOfWay];
                         
                     }];
    
}

-(void)moveAddButtonOutOfWay
{
    
    self.addToChannelButton.frame = CGRectMake(self.view.frame.size.width + 2.0,
                                               addToChannelFrame.origin.y,
                                               addToChannelFrame.size.width,
                                               addToChannelFrame.size.height);
}

@end
