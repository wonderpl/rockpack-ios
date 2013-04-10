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
#import "SYNHomeRootViewController.h"
#import "SYNMovableView.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNSearchRootViewController.h"
#import "SYNSearchTabViewController.h"
#import "SYNUserTabView.h"
#import "SYNUserTabViewController.h"
#import "SYNVideosRootViewController.h"
#import "SYNYouRootViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNChannelsAddVideosViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNContainerViewController () <UIPopoverControllerDelegate,
                                          UITextViewDelegate>

@property (nonatomic) BOOL didNotSwipeMessageInbox;
@property (nonatomic) BOOL shouldAnimateViewTransitions;
@property (nonatomic, assign) BOOL didNotSwipeShareMenu;
@property (nonatomic, assign) double lowPassResults;
@property (nonatomic, assign, getter = isShowingBackButton) BOOL showingBackButton;
@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, getter = isTabBarHidden) BOOL tabBarHidden;

@property (nonatomic, strong) SYNChannelsUserViewController* channelsUserViewController;
@property (nonatomic, strong) SYNSearchRootViewController* searchViewController;
@property (nonatomic, strong) UINavigationController* channelsUserNavigationViewController;
@property (nonatomic, strong) UINavigationController* seachViewNavigationViewController;


@property (nonatomic, readonly) UIScrollView* scrollView;


@property (nonatomic, strong) UIPopoverController *actionButtonPopover;

@property (nonatomic, weak) UIViewController *selectedViewController;
@property (strong, nonatomic) MKNetworkOperation *downloadOperation;




@end

@implementation SYNContainerViewController

@synthesize selectedViewController;
@synthesize videoQueueController;
@synthesize channelsUserNavigationViewController;
@synthesize channelsUserViewController, searchViewController;
@dynamic scrollView;
@dynamic page;
@dynamic showingViewController;

// Initialise all the elements common to all 4 tabs

#pragma mark - View lifecycle


-(void)loadView
{
    CGRect scrollerFrame = CGRectMake(0.0, 0.0, 1024.0, 748.0);
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:scrollerFrame];
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
    
    SYNHomeRootViewController *feedRootViewController = [[SYNHomeRootViewController alloc] initWithViewId: @"Home"];
    
    // == Videos Page == //
    
    SYNVideosRootViewController *videosRootViewController = [[SYNVideosRootViewController alloc] initWithViewId: @"Videos"];
    videosRootViewController.tabViewController = [[SYNCategoriesTabViewController alloc] init];
    
    // == Channels Page == //
    
    SYNChannelsRootViewController *channelsRootViewController = [[SYNChannelsRootViewController alloc] initWithViewId: @"Channels"];
    channelsRootViewController.tabViewController = [[SYNCategoriesTabViewController alloc] init];
    
    // == You Page == //
    
    SYNYouRootViewController *myRockpackViewController = [[SYNYouRootViewController alloc] initWithViewId: @"You"];
    myRockpackViewController.tabViewController = [[SYNUserTabViewController alloc] init];
    
    // == Friends Page == //
    
    // TODO: Implement Friends Section
    //SYNFriendsRootViewController *friendsRootViewController = [[SYNFriendsRootViewController alloc] initWithViewId: @"Friends"];
    
    
    
    
    // == Search (out of normal controller array)
    
    
    self.searchViewController = [[SYNSearchRootViewController alloc] initWithViewId:@"Search"];
    self.searchViewController.tabViewController = [[SYNSearchTabViewController alloc] init];
    self.seachViewNavigationViewController = [self wrapInNavigationController:self.searchViewController];
    
    
    // == Channels User (out of normal controller array)
    
    self.channelsUserViewController = [[SYNChannelsUserViewController alloc] initWithViewId:@"UserChannels"];
    self.channelsUserViewController.tabViewController = [[SYNUserTabViewController alloc] init];
    self.channelsUserNavigationViewController = [self wrapInNavigationController:self.channelsUserViewController];
    
    
    self.shouldAnimateViewTransitions = YES;
    
    
    self.didNotSwipeMessageInbox = YES;
    self.didNotSwipeShareMenu = YES;
    
    
    // == Populate Scroller == //
    
    NSMutableArray* allControllers = [[NSMutableArray alloc] initWithCapacity:3];
    [allControllers addObject:[self wrapInNavigationController:feedRootViewController]];
    [allControllers addObject:[self wrapInNavigationController:channelsRootViewController]];
    [allControllers addObject:[self wrapInNavigationController:myRockpackViewController]];
    
    self.viewControllers = [NSArray arrayWithArray:allControllers];
    
    CGFloat currentVCOffset = 0.0;
    CGRect currentVCRect;
    for (UIViewController * vc in self.viewControllers)
    {
        currentVCRect = vc.view.frame;
        currentVCRect.origin.x = currentVCOffset;
        
        vc.view.frame = currentVCRect;
        
        [self.scrollView addSubview:vc.view];
        
        currentVCOffset += 1024.0;
    }
    
    self.scrollView.contentSize = CGSizeMake(currentVCOffset, 748.0);
    
    self.selectedViewController = self.viewControllers[0];
    
    
    // == Register Notifications == //
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUserChannel:) name:kShowUserChannels object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backButtonShow:) name:kNoteBackButtonShow object:nil];
}





-(void)backButtonShow:(NSNotification*)notification
{
    self.scrollView.scrollEnabled = NO;
}

- (void) createChannelFromVideoQueue
{
    if([self.selectedViewController isKindOfClass:[UINavigationController class]])
    {
        
        SYNAbstractViewController* child = (SYNAbstractViewController*)((UINavigationController*)self.selectedViewController).topViewController;
        [child createChannel: [self.videoQueueController getChannelFromCurrentQueue]];
        
    }

}

-(void)addVideosToExistingChannel
{
    if([self.selectedViewController isKindOfClass:[UINavigationController class]])
    {
        
        SYNAbstractViewController* child = (SYNAbstractViewController*)((UINavigationController*)self.selectedViewController).topViewController;
        [child addToChannel: [self.videoQueueController getChannelFromCurrentQueue]];
        
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


#pragma mark - Show Special Views

- (void) showSearchViewControllerWithTerm:(NSString*)searchTerm
{
     
    
    self.selectedViewController = self.seachViewNavigationViewController;
    
    [self replaceShowingViewControllerWith:self.seachViewNavigationViewController];

    
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



- (void) replaceShowingViewControllerWith:(UIViewController*)viewController
{
    SYNAbstractViewController* showing = [self showingViewController];

    CGRect showingRect = showing.view.frame;
    
    viewController.view.frame = showingRect;
    //viewController.view.alpha = 0.0;
    
    [self.scrollView addSubview:viewController.view];
    
    //self.scrollView.scrollEnabled = NO;
    
//    [UIView animateWithDuration: 0.3f
//                          delay: 0.0f
//                        options: UIViewAnimationOptionCurveEaseInOut
//                     animations: ^{
//                         
//                         showing.view.alpha = 0.0;
//                         viewController.view.alpha = 1.0;
//                         
//                     } completion: ^(BOOL finished) {
//                     
//                     }];
    
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    
    self.selectedViewController = self.viewControllers[self.page];
    
    
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
    int pageWidth = (int)self.scrollView.contentSize.width / self.viewControllers.count;
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

-(UINavigationController*)wrapInNavigationController:(SYNAbstractViewController*)anstractViewController
{
    
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:anstractViewController];
    navigationController.navigationBarHidden = YES;
    navigationController.view.autoresizesSubviews = YES;
    navigationController.view.frame = CGRectMake (0, 0, 1024, 686);
    return navigationController;
}


@end
