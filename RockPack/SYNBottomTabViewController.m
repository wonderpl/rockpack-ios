//
//  SYNBottomTabViewController.m
//  RockPack
//
//  Created by Nick Banks on 13/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "AudioToolbox/AudioToolbox.h"
#import "MKNetworkEngine.h"
#import "SYNActivityPopoverViewController.h"
#import "SYNBottomTabViewController.h"
#import "SYNChannelsRootViewController.h"
#import "SYNVideosRootViewController.h"
#import "SYNFriendsRootViewController.h"
#import "SYNHomeRootViewController.h"
#import "SYNMovableView.h"
#import "SYNYouRootViewController.h"
#import "SYNVideoDB.h"
#import "SYNVideoDownloadEngine.h"
#import "UIFont+SYNFont.h"
#import "SYNSearchTabViewController.h"
#import "SYNSearchRootViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SYNVideoQueueViewController.h"

@interface SYNBottomTabViewController () <UIPopoverControllerDelegate,
                                          UITextViewDelegate>

@property (nonatomic) BOOL didNotSwipeMessageInbox;
@property (nonatomic) BOOL shouldAnimateViewTransitions;
@property (nonatomic, assign) BOOL didNotSwipeShareMenu;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) double lowPassResults;
@property (nonatomic, assign, getter = isShowingBackButton) BOOL showingBackButton;
@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, strong) SYNSearchRootViewController* searchViewController;


@property (nonatomic, strong) SYNVideoQueueViewController* videoQueueController;

@property (nonatomic, strong) IBOutlet UIButton *recordButton;
@property (nonatomic, strong) IBOutlet UIButton *writeMessageButton;

@property (nonatomic, strong) IBOutlet UIView* containerView;

@property (nonatomic, strong) UIPopoverController *actionButtonPopover;

@property (nonatomic, weak) UIViewController *selectedViewController;
@property (strong, nonatomic) MKNetworkOperation *downloadOperation;
@property (strong, nonatomic) SYNVideoDownloadEngine *downloadEngine;

@property (nonatomic, strong) IBOutlet UIView* tabsViewContainer;

@end

@implementation SYNBottomTabViewController

@synthesize selectedIndex = _selectedIndex;
@synthesize selectedViewController = _selectedViewController;
@synthesize videoQueueController = videoQueueController;

// Initialise all the elements common to all 4 tabs

#pragma mark - View lifecycle
 	
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // == Home Tab
    
    SYNHomeRootViewController *homeRootViewController = [[SYNHomeRootViewController alloc] initWithViewId:@"Home"];
    UINavigationController *homeRootNavigationViewController = [[UINavigationController alloc] initWithRootViewController: homeRootViewController];
    homeRootNavigationViewController.navigationBarHidden = TRUE;
    homeRootNavigationViewController.view.autoresizesSubviews = TRUE;
    homeRootNavigationViewController.view.frame = CGRectMake (0, 0, 1024, 784);
    
    // == Channels Tab
    
    SYNChannelsRootViewController *channelsRootViewController = [[SYNChannelsRootViewController alloc] initWithViewId:@"Channels"];
    channelsRootViewController.tabViewController = [[SYNCategoriesTabViewController alloc] init];
    UINavigationController *channelsRootNavigationViewController = [[UINavigationController alloc] initWithRootViewController: channelsRootViewController];
    channelsRootNavigationViewController.navigationBarHidden = TRUE;
    channelsRootNavigationViewController.view.autoresizesSubviews = TRUE;
    channelsRootNavigationViewController.view.frame = CGRectMake (0, 0, 1024, 686);
    
    // == Videos Tab
    
    SYNVideosRootViewController *videosRootViewController = [[SYNVideosRootViewController alloc] initWithViewId:@"Videos"];
    videosRootViewController.tabViewController = [[SYNCategoriesTabViewController alloc] init];
    UINavigationController *videosRootNavigationViewController = [[UINavigationController alloc] initWithRootViewController: videosRootViewController];
    videosRootNavigationViewController.navigationBarHidden = TRUE;
    videosRootNavigationViewController.view.autoresizesSubviews = TRUE;
    videosRootNavigationViewController.view.frame = CGRectMake (0, 0, 1024, 686);
    
    
    // == You Tab
    
    SYNYouRootViewController *youRootViewController = [[SYNYouRootViewController alloc] initWithViewId:@"You"];
    UINavigationController *youRootRootNavigationViewController = [[UINavigationController alloc] initWithRootViewController: youRootViewController];
    youRootRootNavigationViewController.navigationBarHidden = TRUE;
    youRootRootNavigationViewController.view.autoresizesSubviews = TRUE;
    youRootRootNavigationViewController.view.frame = CGRectMake (0, 0, 1024, 686);
    
    // == Friends tab
    // TODO: Nest Friends Bar
    SYNFriendsRootViewController *friendsRootViewController = [[SYNFriendsRootViewController alloc] initWithViewId:@"Friends"];
    
    
    
    // == Register Controllers
    
    self.viewControllers = @[homeRootNavigationViewController,
                             channelsRootNavigationViewController,
                             videosRootNavigationViewController,
                             youRootRootNavigationViewController,
                             friendsRootViewController];
    
    
    // == Search (out of normal controller array)
    
    self.searchViewController = [[SYNSearchRootViewController alloc] initWithViewId:@"Search"];
    self.searchViewController.tabViewController = [[SYNSearchTabViewController alloc] init];
    
    // For the moment no navigation controller
//    UINavigationController *searchRootNavigationViewController = [[UINavigationController alloc] initWithRootViewController: self.searchViewController];
//    searchRootNavigationViewController.navigationBarHidden = TRUE;
//    searchRootNavigationViewController.view.autoresizesSubviews = TRUE;
//    searchRootNavigationViewController.view.frame = CGRectMake (0, 0, 1024, 686);
    
    
    
    // == Video Queue
    
    videoQueueController = [[SYNVideoQueueViewController alloc] init];
    videoQueueController.delegate = self;
//    
//    CGRect lowerFrame = CGRectMake(0, 573 + 62 + kVideoQueueEffectiveHeight, 1024, kVideoQueueEffectiveHeight);
//    videoQueueController.view.frame = lowerFrame;
    
    [self.view insertSubview:videoQueueController.view belowSubview:self.tabsViewContainer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoQueueHide:) name:kVideoQueueHide object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoQueueShow:) name:kVideoQueueShow object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoQueueAdd:) name:kVideoQueueAdd object:nil];
    
    // Set Initial View Controller
    
    self.shouldAnimateViewTransitions = YES;
    
    [self setSelectedIndex:2];
    
    
    self.didNotSwipeMessageInbox = TRUE;
    self.didNotSwipeShareMenu = TRUE;
    
    
    
    
}


#pragma mark - Video Queue Handlers

-(void)videoQueueHide:(NSNotification*)notification
{
    [self.videoQueueController hideVideoQueue:YES];
}

-(void)videoQueueShow:(NSNotification*)notification
{
    [self.videoQueueController showVideoQueue:YES];
}

-(void)videoQueueAdd:(NSNotification*)notification
{
    VideoInstance* videoInstanceToAdd = (VideoInstance*)[notification.userInfo objectForKey:@"VideoInstance"];
    [self.videoQueueController addVideoToQueue:videoInstanceToAdd];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
}


#pragma mark - Tab & Container switching mechanism

// Add the five tab view controllers as sub-view controllers of this view controller
- (void) setViewControllers: (NSArray *) newViewControllers
{
	UIViewController *oldSelectedViewController = self.selectedViewController;
    
	// Remove the old child view controllers.
	for (UIViewController *viewController in _viewControllers)
	{
		[viewController willMoveToParentViewController: nil];
		[viewController removeFromParentViewController];
	}
    
	_viewControllers = [newViewControllers copy];
    
	// This follows the same rules as UITabBarController for trying to
	// re-select the previously selected view controller.
	NSUInteger newIndex = [_viewControllers indexOfObject: oldSelectedViewController];
	if (newIndex != NSNotFound)
    {
		_selectedIndex = newIndex;
    }
	else if (newIndex < [_viewControllers count])
    {
		_selectedIndex = newIndex;
    }
	else
    {
		_selectedIndex = 0;
    }
    
	// Add the new child view controllers.
	for (UIViewController *viewController in _viewControllers)
	{
		[self addChildViewController: viewController];
		[viewController didMoveToParentViewController: self];
	}
}


// Set the selected tab (with no animation)

- (void) setSelectedIndex: (NSInteger) newSelectedIndex
{
	[self setSelectedIndex: newSelectedIndex
                  animated: NO];
}


// Set the selected tab (with animation if required)

- (void) setSelectedIndex: (NSUInteger) newSelectedIndex
                 animated: (BOOL) animated
{
	
    
    
    if(_selectedIndex == newSelectedIndex)
        return;
    
    
    _selectedIndex = newSelectedIndex;
    
    
    
    for (UIButton* tabButton in self.tabsViewContainer.subviews)
        tabButton.selected = NO;

    if(_selectedIndex < 0 || _selectedIndex > self.tabsViewContainer.subviews.count)
        return;
    
    
    UIButton* toButton = (UIButton *)self.tabsViewContainer.subviews[_selectedIndex];
    toButton.selected = TRUE;
    
    
    self.selectedViewController = (UIViewController*)self.viewControllers[_selectedIndex];
    
    
}

-(void)setSelectedViewController:(UIViewController *)newSelectedViewController
{
    
    
    // if we try and push the same controller, escape
    
    if(_selectedViewController == newSelectedViewController)
        return;
    
    
    
    // even if nill, that is OK. It will just animate the selectedViewController out.
    
    if(newSelectedViewController)
        [self.containerView addSubview:newSelectedViewController.view];
    
    if (self.shouldAnimateViewTransitions)
    {
        self.view.userInteractionEnabled = NO;
        
        newSelectedViewController.view.alpha = 0.0f;
        
        [UIView animateWithDuration: kTabAnimationDuration
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^{
                             
                             _selectedViewController.view.alpha = 0.0f;
                             
                             if(newSelectedViewController)
                                 newSelectedViewController.view.alpha = 1.0f;
                             
                         } completion: ^(BOOL finished) {
                             
                             [_selectedViewController.view removeFromSuperview];
                             
                             self.view.userInteractionEnabled = YES;
                             
                             _selectedViewController = newSelectedViewController;
                             
                         }];
    }
    else
    {
        
        [_selectedViewController.view removeFromSuperview];
        
        
        _selectedViewController = newSelectedViewController;
    }
    
}







// Use the tag index of the button (100 - 103) to calculate the button index

- (IBAction) tabButtonPressed: (UIButton *) sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNoteTabPressed object:self];
    
	[self setSelectedIndex: sender.tag - kBottomTabIndexOffset
                  animated: YES];
}


- (IBAction) recordAction: (UIButton*) button
{
    button.selected = !button.selected;
}


- (void) popoverControllerDidDismissPopover: (UIPopoverController *) popoverController
{
	// Any cleanup
    // self.notificationsButton.selected = FALSE;
}


- (void) popCurrentViewController: (id) sender
{
    // TODO: Might want to abstract al the push and pop into the master
    
    if(self.selectedViewController == self.searchViewController)
    {
        [self.searchViewController animatedPopViewController];
        return;
    }
    
    UINavigationController *navVC = (UINavigationController *)self.selectedViewController;
    
    SYNAbstractViewController *abstractVC = (SYNAbstractViewController *)navVC.topViewController;
    
    [abstractVC animatedPopViewController];
}




-(void) showSearchViewControllerWithTerm:(NSString*)searchTerm
{
    [self setSelectedIndex:-1]; // turn all off
    
    if(self.selectedViewController != self.searchViewController)
        self.selectedViewController = self.searchViewController;
    
    [self.searchViewController showSearchResultsForTerm:searchTerm];
    
    
}

@end
