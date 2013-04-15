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
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
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
    
    SYNFeedRootViewController *feedRootViewController = [[SYNFeedRootViewController alloc] initWithViewId: @"Home"];
    
    // == Videos Page == //
    
    SYNVideosRootViewController *videosRootViewController = [[SYNVideosRootViewController alloc] initWithViewId: @"Videos"];
    videosRootViewController.tabViewController = [[SYNCategoriesTabViewController alloc] init];
    
    // == Channels Page == //
    
    SYNChannelsRootViewController *channelsRootViewController = [[SYNChannelsRootViewController alloc] initWithViewId: @"Channels"];
    channelsRootViewController.tabViewController = [[SYNCategoriesTabViewController alloc] init];
    [channelsRootViewController addChildViewController:channelsRootViewController.tabViewController];
    
    // == You Page == //
    
    SYNYouRootViewController *myRockpackViewController = [[SYNYouRootViewController alloc] initWithViewId: @"You"];
    
    // == Friends Page == //
    
    // TODO: Implement Friends Section
    //SYNFriendsRootViewController *friendsRootViewController = [[SYNFriendsRootViewController alloc] initWithViewId: @"Friends"];
    
    
    
    
    // == Search (out of normal controller array)
    
    
    self.searchViewController = [[SYNSearchRootViewController alloc] initWithViewId:@"Search"];
    self.searchViewController.tabViewController = [[SYNSearchTabViewController alloc] init];
    self.seachViewNavigationViewController = [self wrapInNavigationController:self.searchViewController];
    
    
    // == Channels User (out of normal controller array)
    
    self.channelsUserViewController = [[SYNChannelsUserViewController alloc] initWithViewId:@"UserChannels"];
    self.channelsUserNavigationViewController = [self wrapInNavigationController:self.channelsUserViewController];
    
    
    self.shouldAnimateViewTransitions = YES;
    
    
    self.didNotSwipeMessageInbox = YES;
    self.didNotSwipeShareMenu = YES;
    
    
    // == Populate Scroller == //
    
//    NSMutableArray* allControllers = [[NSMutableArray alloc] initWithCapacity:3];
    UINavigationController* feedNavController = [self wrapInNavigationController:feedRootViewController];
    feedNavController.view.frame = CGRectMake (0.0, 60.0, 1024, 686);
    feedNavController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight| UIViewAutoresizingFlexibleWidth;
//    [allControllers addObject:feedNavController];
//    [allControllers addObject:[self wrapInNavigationController:channelsRootViewController]];
//    [allControllers addObject:[self wrapInNavigationController:myRockpackViewController]];
//    
    [self addChildViewController:feedNavController];
    [self addChildViewController:[self wrapInNavigationController:channelsRootViewController]];
    channelsRootViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight| UIViewAutoresizingFlexibleWidth;
    [self addChildViewController:[self wrapInNavigationController:myRockpackViewController]];
    myRockpackViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight| UIViewAutoresizingFlexibleWidth;
    
    
    [self packViewControllersForInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    self.selectedViewController = self.childViewControllers[0];
    
    
    // == Register Notifications == //
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUserChannel:) name:kShowUserChannels object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backButtonShow:) name:kNoteBackButtonShow object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backButtonHide:) name:kNoteBackButtonHide object:nil];
}


-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self packViewControllersForInterfaceOrientation:toInterfaceOrientation];
}

#pragma mark - Placement of Views

-(void)packViewControllersForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    CGRect newFrame;
    if(UIInterfaceOrientationIsLandscape(orientation))
    {
        newFrame = CGRectMake(0.0f, 0.0f, 1024.0f, 748.0f);
    }
    else
    {
        newFrame = CGRectMake(0.0, 0.0f, 768.0f, 1004.0f);
    }
    
    for(UIViewController* controller in self.childViewControllers)
    {
        controller.view.frame = newFrame;
        newFrame.origin.x += newFrame.size.width;
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
    
    CGPoint newPoint = CGPointMake(page * 1024.0, 0.0);
    [self.scrollView setContentOffset:newPoint animated:YES];
}



-(NSInteger)page
{
    CGFloat currentScrollerOffset = self.scrollView.contentOffset.x;
    int pageWidth = (int)self.scrollView.contentSize.width / self.childViewControllers.count;
    NSInteger page = (currentScrollerOffset / pageWidth); // 0 indexed
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
    navigationController.view.frame = CGRectMake (0.0, 0.0, 1024, 686);
    return navigationController;
}

-(CGFloat)currentScreenOffset
{
    return 1024.0;
}


@end
