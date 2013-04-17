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
#import "SYNSoundPlayer.h"
#import "SYNAutocompletePopoverBackgroundView.h"
#import "SYNContainerViewController.h"
#import "SYNBackButtonControl.h"

#import "SYNVideoViewerViewController.h"
#import "SYNAccountSettingsMainTableViewController.h"
#import "SYNCategoryChooserViewController.h"
#import "SYNRefreshButton.h"
#import "SYNAutocompleteViewController.h"
#import "SYNDeviceManager.h"

#import <QuartzCore/QuartzCore.h>

#define kMovableViewOffX -58

typedef void(^AnimationCompletionBlock)(BOOL finished);

@interface SYNMasterViewController ()

@property (nonatomic, strong) SYNBackButtonControl* backButtonControl;

@property (nonatomic, strong) IBOutlet UIButton* closeSearchButton;
@property (nonatomic, strong) IBOutlet UIButton* addToChannelButton;
@property (nonatomic, strong) IBOutlet UIView* overlayView;
@property (nonatomic, strong) IBOutlet UIView* navigatioContainerView;
@property (nonatomic, strong) IBOutlet UIView* topBarView;
@property (nonatomic, strong) IBOutlet UIView* dotsView;
@property (nonatomic, strong) IBOutlet UILabel* pageTitleLabel;
@property (nonatomic, strong) IBOutlet UIView* movableButtonsContainer;
@property (nonatomic, strong) IBOutlet UIButton* sideNavigationButton;
@property (nonatomic) CGFloat sideNavigationOriginCenterX;
@property (nonatomic) BOOL buttonLocked;
@property (nonatomic) BOOL isDragging;


@property (nonatomic, strong) SYNRefreshButton* refreshButton;


@property (nonatomic) CGRect addToChannelFrame;

@property (nonatomic, strong) SYNAutocompleteViewController* autocompleteController;


@property (nonatomic, strong) SYNVideoViewerViewController *videoViewerViewController;
@property (nonatomic, strong) SYNCategoryChooserViewController *categoryChooserViewController;

@property (nonatomic, strong) SYNSideNavigationViewController* sideNavigationViewController;
@property (nonatomic) BOOL sideNavigationOn;


@end

@implementation SYNMasterViewController

@synthesize containerViewController;
@synthesize pageTitleLabel;
@synthesize addToChannelFrame;
@synthesize sideNavigationOn;
@synthesize sideNavigationOriginCenterX;
@synthesize isDragging, buttonLocked;

#pragma mark - Initialise

-(id)initWithContainerViewController:(SYNContainerViewController*)root
{
    if ((self = [super initWithNibName: @"SYNMasterViewController" bundle: nil]))
    {
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        self.containerViewController = root;
        [self addChildViewController:root];

        
        // == Side Navigation == //
        
        self.sideNavigationViewController = [[SYNSideNavigationViewController alloc] init];
        CGRect sideNavigationFrame = self.sideNavigationViewController.view.frame;
        sideNavigationFrame.origin.x = [[SYNDeviceManager sharedInstance] currentScreenWidth];
        sideNavigationFrame.origin.y = 45.0;
        self.sideNavigationViewController.view.frame = sideNavigationFrame;
        self.sideNavigationViewController.user = appDelegate.currentUser;
        
        
        UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sideNavigationPanned:)];
        [self.sideNavigationViewController.view addGestureRecognizer:panGesture];
        
        sideNavigationOn = NO;
        
        
        self.autocompleteController = [[SYNAutocompleteViewController alloc] init];
        CGRect autocompleteControllerFrame = self.autocompleteController.view.frame;
        autocompleteControllerFrame.origin.x = 10.0;
        autocompleteControllerFrame.origin.y = 10.0;
        self.autocompleteController.view.frame = autocompleteControllerFrame;
        
        self.overEverythingView.userInteractionEnabled = NO;
        
        
        
    }
    return self;
}




#pragma mark - Life Cycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // == Refresh button == //
    
    CGRect movableViewFrame = self.movableButtonsContainer.frame;
    movableViewFrame.origin.x = kMovableViewOffX;
    self.movableButtonsContainer.frame = movableViewFrame;
    
    self.refreshButton = [SYNRefreshButton refreshButton];
    [self.refreshButton addTarget:self action:@selector(refreshButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    CGRect refreshButtonFrame = self.refreshButton.frame;
    refreshButtonFrame.origin.x = 70.0f;
    self.refreshButton.frame = refreshButtonFrame;
    [self.movableButtonsContainer addSubview:self.refreshButton];
    
    self.closeSearchButton.alpha = 0.0;
    
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
    [self.containerView addSubview:containerViewController.view];
    
    
    // == Cancel Button == //
    
    self.closeSearchButton.hidden = YES;
    
    
    
    // == Back Button == //
    
    self.backButtonControl = [SYNBackButtonControl backButton];
    [self.movableButtonsContainer addSubview:self.backButtonControl];
    self.backButtonControl.alpha = 0.0;
    
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
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollerPageChanged:) name:kScrollerPageChanged object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigateToPage:) name:kNavigateToPage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTyped:) name:kSearchTyped object:nil];
    
    
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
    if(buttonLocked)
        return;
    
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
    
    if(sideNavigationOn && !isDragging)
        return;
    
    self.sideNavigationOn = YES;
    
    [self.navigatioContainerView addSubview:self.sideNavigationViewController.view];
    
    [[SYNSoundPlayer sharedInstance] playSoundByName:kSoundNewSlideIn];
    
    
    [UIView animateWithDuration: kRockieTalkieAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations: ^{
                         
                         CGRect sideNavigationFrame = self.sideNavigationViewController.view.frame;
                         
                         sideNavigationFrame.origin.x = [[SYNDeviceManager sharedInstance] currentScreenWidth] - sideNavigationFrame.size.width;
                         self.sideNavigationViewController.view.frame =  sideNavigationFrame;
                         
                     } completion: ^(BOOL finished) {
                         
                     }];
}



-(void)sideNavigationSwiped
{
    [self hideSideNavigation];
}
-(void)sideNavigationPanned:(UIPanGestureRecognizer*)recogniser
{
    CGFloat translationX = [recogniser translationInView:self.sideNavigationViewController.view].x;
    
    if(recogniser.state == UIGestureRecognizerStateBegan)
    {
        
        isDragging = YES;
        sideNavigationOriginCenterX = self.sideNavigationViewController.view.center.x;
        
        
    }
    CGFloat newOriginX = sideNavigationOriginCenterX + translationX;
    if(newOriginX < sideNavigationOriginCenterX)
    {
        newOriginX = sideNavigationOriginCenterX;
    }
    
    self.sideNavigationViewController.view.center = CGPointMake( newOriginX ,
                                                                self.sideNavigationViewController.view.center.y);
    
    
    if(recogniser.state == UIGestureRecognizerStateEnded)
    {
        CGFloat border;
        if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
        {
            border = [[UIScreen mainScreen] bounds].size.height;
        }
        else
        {
            border = [[UIScreen mainScreen] bounds].size.width;
        }
        
        if(border - newOriginX < 20.0)
        {
            [self hideSideNavigation];
        }
        else
        {
            [self showSideNavigation];
        }
        isDragging = NO;
    }
    
}


- (void) hideSideNavigation
{
    
    if(!sideNavigationOn && !isDragging)
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
    [originViewController addChildViewController:self.categoryChooserViewController];
    
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


#pragma mark - Search Box Delegate Methods

-(IBAction)showSearchBoxField:(id)sender
{
    
    self.sideNavigationButton.hidden = YES;
    
    
    [self.view addSubview:self.autocompleteController.view];
}

-(void)searchTyped:(NSNotification*)notification
{
    
    
    NSString* termString = [[notification userInfo] objectForKey:kSearchTerm];
    
    if(!termString)
        return;
    
    [self.containerViewController showSearchViewControllerWithTerm:termString];
    
    
}

-(IBAction)cancelButtonPressed:(id)sender
{
    [self.autocompleteController clear];
    [self.autocompleteController.view removeFromSuperview];
    
    
    self.sideNavigationButton.hidden = NO;
    
    
}


#pragma mark - Notification Handlers



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"contentOffset"]) {
        
        CGPoint newContentOffset = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
        
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
        [self.backButtonControl addTarget:containerViewController action:@selector(popCurrentViewController:) forControlEvents:UIControlEventTouchUpInside];
        [self.backButtonControl setBackTitle:self.pageTitleLabel.text];
        [self showBackButton:YES];
    }
    else
    {
        [self.backButtonControl removeTarget:containerViewController action:@selector(popCurrentViewController:) forControlEvents:UIControlEventTouchUpInside];
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
        targetFrame.origin.x = 8.0;
        targetAlpha = 1.0;
    }
    else
    {
        targetFrame = self.movableButtonsContainer.frame;
        targetFrame.origin.x = kMovableViewOffX;
        targetAlpha = 0.0;
    }
    
    [UIView animateWithDuration: 0.6f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
                     {
                         self.movableButtonsContainer.frame = targetFrame;
                         self.backButtonControl.alpha = targetAlpha;
                         self.pageTitleLabel.alpha = !targetAlpha;
                         self.dotsView.alpha = !targetAlpha;
                         self.refreshButton.alpha = !targetAlpha;
                     }
                     completion: ^(BOOL finished)
                     {
                     }];

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
