//
//  SYNBottomTabViewController.m
//  RockPack
//
//  Created by Nick Banks on 13/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "AudioToolbox/AudioToolbox.h"
#import "ChannelOwner.h"
#import "MKNetworkEngine.h"
#import "SYNActivityPopoverViewController.h"
#import "SYNContainerViewController.h"
#import "SYNChannelsRootViewController.h"
#import "SYNChannelsUserViewController.h"
#import "SYNFriendsRootViewController.h"
#import "SYNFeedRootViewController.h"
#import "SYNMovableView.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNSearchRootViewController.h"
#import "SYNSearchTabViewController.h"
#import "SYNVideosRootViewController.h"
#import "SYNYouRootViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNChannelsAddVideosViewController.h"
#import "SYNCategoriesTabViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SYNDeviceManager.h"

@interface SYNContainerViewController () <UIPopoverControllerDelegate,
                                          UITextViewDelegate>

@property (nonatomic) BOOL didNotSwipeMessageInbox;
@property (nonatomic) BOOL shouldAnimateViewTransitions;
@property (nonatomic, assign) BOOL didNotSwipeShareMenu;
@property (nonatomic, assign) double lowPassResults;
@property (nonatomic, assign, getter = isShowingBackButton) BOOL showingBackButton;

@property (nonatomic, getter = isTabBarHidden) BOOL tabBarHidden;

@property (nonatomic, strong) SYNChannelsUserViewController* channelsUserViewController;
@property (nonatomic, strong) SYNSearchRootViewController* searchViewController;
@property (nonatomic, strong) UINavigationController* channelsUserNavigationViewController;
@property (nonatomic, strong) UINavigationController* seachViewNavigationViewController;



@property (nonatomic, strong) UIPopoverController *actionButtonPopover;

@property (nonatomic, weak) UIViewController *selectedViewController;
@property (strong, nonatomic) MKNetworkOperation *downloadOperation;

@property (nonatomic, readonly) CGFloat currentScreenOffset;




@end

@implementation SYNContainerViewController

@synthesize selectedViewController;
@synthesize currentScreenOffset;
@synthesize videoQueueController;
@synthesize channelsUserNavigationViewController;
@synthesize channelsUserViewController, searchViewController;
@synthesize scrollingDirection;
@synthesize currentPageOffset;
@synthesize currentPage;

@dynamic showingViewController;
@dynamic page;
@dynamic scrollView;

// Initialise all the elements common to all 4 tabs

#pragma mark - View lifecycle


-(void)loadView
{
    CGRect scrollerFrame = CGRectMake(0.0, 0.0, 1024.0, 748.0);
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:scrollerFrame];
    scrollView.autoresizingMask = UIViewAutoresizingNone;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    
    self.view = scrollView;
}
 	
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // == Feed Page == //
    
    SYNFeedRootViewController *feedRootViewController = [[SYNFeedRootViewController alloc] initWithViewId: kFeedViewId];
    
    // == Videos Page == //
    
    SYNVideosRootViewController *videosRootViewController = [[SYNVideosRootViewController alloc] initWithViewId: kVideosViewId ];
    videosRootViewController.tabViewController = [[SYNCategoriesTabViewController alloc] init];
    
    // == Channels Page == //
    
    SYNChannelsRootViewController *channelsRootViewController = [[SYNChannelsRootViewController alloc] initWithViewId: kChannelsViewId];
    channelsRootViewController.tabViewController = [[SYNCategoriesTabViewController alloc] init];
    [channelsRootViewController addChildViewController:channelsRootViewController.tabViewController];
    
    // == You Page == //
    
    SYNYouRootViewController *myRockpackViewController = [[SYNYouRootViewController alloc] initWithViewId: kProfileViewId];
    
    // == Friends Page == //
    
    // TODO: Implement Friends Section
    //SYNFriendsRootViewController *friendsRootViewController = [[SYNFriendsRootViewController alloc] initWithViewId: @"Friends"];
    
    
    
    
    // == Search (out of normal controller array)
    
    
    self.searchViewController = [[SYNSearchRootViewController alloc] initWithViewId: kSearchViewId];
    self.searchViewController.tabViewController = [[SYNSearchTabViewController alloc] init];
    self.seachViewNavigationViewController = [self wrapInNavigationController:self.searchViewController];
    
    
    // == Channels User (out of normal controller array)
    
    self.channelsUserViewController = [[SYNChannelsUserViewController alloc] initWithViewId: kUserChanneslViewId];
    self.channelsUserNavigationViewController = [self wrapInNavigationController:self.channelsUserViewController];
    
    
    self.shouldAnimateViewTransitions = YES;
    
    
    self.didNotSwipeMessageInbox = YES;
    self.didNotSwipeShareMenu = YES;
    
    
    // == Populate Scroller == //
    
    
    CGRect scrollerFrame = CGRectMake(0.0, 0.0, 1024.0, 748.0);
    self.scrollView.frame = scrollerFrame;
    UINavigationController* feedNavController = [self wrapInNavigationController:feedRootViewController];
    feedNavController.view.frame = CGRectMake (0.0f, 0.0f, 1024.0f, 748.0f);
    [self addChildViewController:feedNavController];
    
    [self addChildViewController:[self wrapInNavigationController:channelsRootViewController]];
    
    [self addChildViewController:[self wrapInNavigationController:myRockpackViewController]];
    
    
    [self packViewControllersForInterfaceOrientation:UIDeviceOrientationLandscapeLeft];
    
    self.selectedViewController = self.childViewControllers[0];
    
    
    // == Register Notifications == //
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUserChannel:) name:kShowUserChannels object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backButtonShow:) name:kNoteBackButtonShow object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backButtonHide:) name:kNoteBackButtonHide object:nil];
}

-(void) viewWillAppear:(BOOL)animated
{
    [self packViewControllersForInterfaceOrientation:[[SYNDeviceManager sharedInstance] orientation]];
}


-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self packViewControllersForInterfaceOrientation:toInterfaceOrientation];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"%@",[self.view description]);
}

#pragma mark - Placement of Views

-(void)packViewControllersForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    CGRect newFrame;
    if(UIDeviceOrientationIsLandscape(orientation))
    {
        newFrame = CGRectMake(0.0f, 0.0f, 1024.0f, 748.0f);
    }
    else
    {
        newFrame = CGRectMake(0.0, 0.0f, 768.0f, 1004.0f);
    }
    self.scrollView.frame = newFrame;
    for(UIViewController* controller in self.childViewControllers)
    {
        controller.view.frame = newFrame;
        newFrame.origin.x += newFrame.size.width;
        if ([controller isKindOfClass:[UINavigationController class]] )
        {
            UINavigationController* navController = (UINavigationController*)controller;
            navController.topViewController.view.frame = controller.view.bounds;
        }
    }
    
    self.scrollView.contentSize = CGSizeMake(newFrame.origin.x, newFrame.size.height);
    self.currentPageOffset = CGPointMake(self.currentPage * newFrame.size.width,0);
    [self.scrollView setContentOffset:self.currentPageOffset];
    self.currentPage = self.page;
    scrollingDirection = ScrollingDirectionNone;
}

-(void)addChildViewController:(UIViewController *)childController
{
    [childController willMoveToParentViewController:self];
    
    [super addChildViewController:childController];
    
    [self.scrollView addSubview:childController.view];
    
    [childController didMoveToParentViewController:self];
}


-(void)backButtonShow:(NSNotification*)notification
{
    self.scrollView.scrollEnabled = NO;
}

-(void)backButtonHide:(NSNotification*)notification
{
    
    
}

- (void) createChannelFromVideoQueue
{
    if([self.selectedViewController isKindOfClass:[UINavigationController class]])
    {
        
        SYNAbstractViewController* child = (SYNAbstractViewController*)((UINavigationController*)self.selectedViewController).topViewController;
        [child createChannel:[self.videoQueueController getChannelFromCurrentQueue]];
        
    }

}

-(void)addVideosToExistingChannel
{
    if([self.selectedViewController isKindOfClass:[UINavigationController class]])
    {
        
        SYNAbstractViewController* child = (SYNAbstractViewController*)((UINavigationController*)self.selectedViewController).topViewController;
        [child addToChannel:[self.videoQueueController getChannelFromCurrentQueue]];
        
    }
}






- (IBAction) recordAction: (UIButton*) button
{
    button.selected = !button.selected;
}



- (void) popCurrentViewController: (id) sender
{

    UINavigationController *navVC = (UINavigationController *)self.selectedViewController;
    
    SYNAbstractViewController *abstractVC = (SYNAbstractViewController *)navVC.topViewController;
    
    [abstractVC animatedPopViewController];
    
    self.scrollView.scrollEnabled = YES;
    
}

#pragma mark - Navigate To Views

-(void) navigateToPageByName:(NSString*)pageName
{
    int page = 0;
    for (UINavigationController* nvc in self.childViewControllers)
    {
        if([pageName isEqualToString:nvc.title]) {
            [self setPage:page];
            break;
        }
        page++;
    }
}


#pragma mark - Show Special Views

- (void) showSearchViewControllerWithTerm:(NSString*)searchTerm
{
     
    
    [self replaceShowingNavigationController:self.seachViewNavigationViewController];
    

    [self.searchViewController showSearchResultsForTerm: searchTerm];
    
    
}

- (void) showUserChannel: (NSNotification*) notification
{
    NSDictionary* userInfo = [notification userInfo];
    
    ChannelOwner* channelOwner = (ChannelOwner*)[userInfo objectForKey: @"ChannelOwner"];
    
    if (!channelOwner)
        return;
    
    self.selectedViewController = self.channelsUserNavigationViewController;
        
    
    
    [self.channelsUserViewController fetchUserChannels: channelOwner];
}


- (void) replaceShowingNavigationController:(UIViewController*)viewController
{
    UINavigationController* showingNavController = [self showingViewController].navigationController;

    
    CGFloat showingOffset = showingNavController.view.frame.origin.x;
    
    CGRect vcFrame = viewController.view.frame;
    vcFrame.origin.x = showingOffset;
    viewController.view.frame = vcFrame;
    
    viewController.view.alpha = 0.0;
    
    [self.scrollView addSubview:viewController.view];
    
    self.scrollView.scrollEnabled = NO;
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseIn
                     animations: ^{
                         showingNavController.view.alpha = 0.0;
                     }
                     completion: ^(BOOL finished) {
                         self.selectedViewController = self.seachViewNavigationViewController;
                         
                         [UIView animateWithDuration: 0.7f
                                               delay: 0.2f
                                             options: UIViewAnimationOptionCurveEaseOut
                                          animations: ^{
                                              viewController.view.alpha = 1.0;
                                          }
                                          completion: nil];
                     }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if(self.currentPageOffset.x < self.scrollView.contentOffset.x - 8.0)
    {
        
        scrollingDirection = ScrollingDirectionRight;
    }
    else if(self.currentPageOffset.x > self.scrollView.contentOffset.x + 8.0)
    {
        
        scrollingDirection = ScrollingDirectionLeft;
    }
    
    // Code to handle multipage scroll without paging stop in between.
    CGFloat width = [[SYNDeviceManager sharedInstance] currentScreenWidth];
    CGFloat pageInProgress = self.scrollView.contentOffset.x / width;
    CGFloat pageDiff = pageInProgress - self.currentPage;
    if(fabsf(pageDiff) > 1.0f)
    {
        self.currentPage = [self page];
        CGPoint newOffset = self.scrollView.contentOffset;
        newOffset.x = currentPage * width;
        self.currentPageOffset = newOffset;
        self.selectedViewController = self.childViewControllers[self.currentPage];
        [self.showingViewController viewCameToScrollFront];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    scrollingDirection = ScrollingDirectionNone;
    
    self.selectedViewController = self.childViewControllers[self.page];
    
    self.currentPageOffset = self.scrollView.contentOffset;
    self.currentPage = self.page;
    
    [self.showingViewController viewCameToScrollFront];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}

#pragma mark - Getters/Setters

-(SYNAbstractViewController*)showingViewController
{
    SYNAbstractViewController* controllerOnView;
    if([self.selectedViewController isKindOfClass:[UINavigationController class]])
    {
        controllerOnView = (SYNAbstractViewController*)((UINavigationController*)self.selectedViewController).visibleViewController;
    }
    else
    {
        controllerOnView = (SYNAbstractViewController*)self.selectedViewController;
    }
    return controllerOnView;
}
-(SYNAbstractViewController*)nextShowingViewController
{
    UINavigationController* navigationController;
    SYNAbstractViewController* controllerOnView;
    if(self.scrollingDirection == ScrollingDirectionRight && (self.currentPage+1) < self.childViewControllers.count) {
        navigationController = self.childViewControllers[(self.currentPage+1)];
    } else if(self.scrollingDirection == ScrollingDirectionLeft && (self.currentPage-1) >= 0) {
        navigationController = self.childViewControllers[(self.currentPage-1)];
    }
    controllerOnView = (SYNAbstractViewController*)(navigationController.visibleViewController);
    return controllerOnView;
}
-(void)setPage:(NSInteger)page
{
    if(!self.scrollView.scrollEnabled)
        return;
    
    CGPoint newPoint = CGPointMake(page * [[SYNDeviceManager sharedInstance] currentScreenWidth], 0.0);
    [self.scrollView setContentOffset:newPoint animated:YES];
}



-(NSInteger)page
{
    CGFloat currentScrollerOffset = self.scrollView.contentOffset.x;
    int pageWidth = (int)self.scrollView.contentSize.width / self.childViewControllers.count;
    NSInteger page = roundf((currentScrollerOffset / pageWidth)); // 0 indexed
    return page;
    
}

-(void)setSelectedViewController:(UIViewController *)selectedVC
{
    selectedViewController = selectedVC;
    NSNotification* notification = [NSNotification notificationWithName:kScrollerPageChanged object:self userInfo:@{kCurrentPage:@(self.page)}];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

-(UIScrollView*)scrollView
{
    return (UIScrollView*)self.view;
}

- (NSString*) description
{
    return NSStringFromClass([self class]);
}


#pragma mark - Helper Methods

-(UINavigationController*)wrapInNavigationController:(SYNAbstractViewController*)abstractViewController
{
    
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:abstractViewController];
    navigationController.title = abstractViewController.title;
    navigationController.navigationBarHidden = YES;
    navigationController.view.autoresizesSubviews = YES;
    navigationController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    return navigationController;
}


@end
