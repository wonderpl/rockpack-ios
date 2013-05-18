//
//  SYNSearchRootViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 27/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchRootViewController.h"

#import "SYNSearchVideosViewController.h"
#import "SYNSearchChannelsViewController.h"
#import "AppConstants.h"
#import "SYNDeviceManager.h"
#import "SYNSearchTabView.h"

@interface SYNSearchRootViewController ()

@property (nonatomic) NSInteger tabSelected;

@property (nonatomic, strong) SYNSearchVideosViewController* searchVideosController;
@property (nonatomic, strong) SYNSearchChannelsViewController* searchChannelsController;

@property (nonatomic, weak) SYNAbstractViewController* currentController;

@property (nonatomic, weak) UIView* currentOverlayView;

@property (nonatomic, strong) NSString* currentSelectionId;

@property (nonatomic, strong) SYNSearchTabView* videoSearchTabView;
@property (nonatomic, strong) SYNSearchTabView* channelsSearchTabView;
@property (nonatomic, strong) UIView* tabsContainer;



@end

@implementation SYNSearchRootViewController
@synthesize tabsContainer;
@synthesize videoSearchTabView, channelsSearchTabView;

-(id)initWithViewId:(NSString *)vid
{
    if (self = [super initWithViewId:vid]) {
        self.title = kSearchTitle;
    }
    return self;
}

-(void)loadView
{
    
    CGRect frame = CGRectMake(0.0, 0.0,[[SYNDeviceManager sharedInstance] currentScreenWidth],
                               [[SYNDeviceManager sharedInstance] currentScreenHeight]);
    
    self.view = [[UIView alloc] initWithFrame:frame];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight;
    
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    self.videoSearchTabView = [SYNSearchTabView tabViewWithSearchType:SearchTabTypeVideos];
    self.channelsSearchTabView = [SYNSearchTabView tabViewWithSearchType:SearchTabTypeChannels];
    
    CGRect channelTabRect = self.channelsSearchTabView.frame;
    channelTabRect.origin.x = self.videoSearchTabView.frame.size.width;
    self.channelsSearchTabView.frame = channelTabRect;
    
    tabsContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0,
                                                            self.channelsSearchTabView.frame.size.width * 2.0,
                                                            self.channelsSearchTabView.frame.size.height)];
    
    
    
    [tabsContainer addSubview:self.channelsSearchTabView];
    [tabsContainer addSubview:self.videoSearchTabView];
    
    [self.videoSearchTabView addTarget:self action:@selector(videoTabPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.channelsSearchTabView addTarget:self action:@selector(channelTabPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat correctTabsY = [[SYNDeviceManager sharedInstance] isIPad] ? 120.0 : self.channelsSearchTabView.frame.size.height/2 + 85.0f;
    tabsContainer.center = CGPointMake(self.view.center.x, correctTabsY);
    tabsContainer.frame = CGRectIntegral(tabsContainer.frame);
    
    
    [self.view addSubview:tabsContainer];
    
    // Google Analytics support
    self.trackedViewName = @"Search - Root";
}

-(void)videoTabPressed:(UIControl*)control
{
    
    
   if(self.videoSearchTabView.selected)
       return;
    
    self.videoSearchTabView.selected = YES;
    self.channelsSearchTabView.selected = NO;
    
    
    [self showVideoSearchResults];
    
}

-(void)channelTabPressed:(UIControl*)control
{
    
    
    if(self.channelsSearchTabView.selected)
        return;
    
    self.channelsSearchTabView.selected = YES;
    self.videoSearchTabView.selected = NO;
    
    [self showChannelsSearchResult];
}

-(void)showVideoSearchResults
{
    
    if(self.currentController == self.searchVideosController)
        return;
    
    SYNAbstractViewController* newController;
    BOOL hasLaidOut = self.searchVideosController.videoThumbnailCollectionView != nil;
    [self.view insertSubview:self.searchVideosController.view belowSubview:tabsContainer];
    newController = self.searchVideosController;
    
    
    if(self.currentController)
        [self.currentController.view removeFromSuperview];
    
    self.currentController = newController;
    if(!hasLaidOut && [[SYNDeviceManager sharedInstance] isIPhone])
    {
        CGRect collectionViewFrame = CGRectMake(0,108.0f,320.0f,self.view.frame.size.height - 108.0f);
        self.searchVideosController.videoThumbnailCollectionView.frame = collectionViewFrame;
        self.searchVideosController.videoThumbnailCollectionView.backgroundColor = [UIColor colorWithWhite:0.97f alpha:1.0f];
        UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)self.currentController.videoThumbnailCollectionView.collectionViewLayout;
        UIEdgeInsets insets= layout.sectionInset;
        insets.top = 10.0f;
        insets.bottom = 10.0f;
        layout.sectionInset = insets;
    }
    
}
-(void)showChannelsSearchResult
{
    if(self.currentController == self.searchChannelsController)
        return;
    
    SYNAbstractViewController* newController;
    BOOL hasLaidOut = self.searchChannelsController.channelThumbnailCollectionView != nil;
    [self.view insertSubview:self.searchChannelsController.view belowSubview:tabsContainer];
    newController = self.searchChannelsController;
    
    if(self.currentController)
        [self.currentController.view removeFromSuperview];
    
    self.currentController = newController;
    
    if(!hasLaidOut && [[SYNDeviceManager sharedInstance] isIPhone])
    {
        CGRect collectionViewFrame = CGRectMake(0,48.0f,320.0f,self.view.frame.size.height - 108.0f);
        self.searchChannelsController.channelThumbnailCollectionView.frame = collectionViewFrame;
        self.searchChannelsController.channelThumbnailCollectionView.backgroundColor = [UIColor colorWithWhite:0.97f alpha:1.0f];
        UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)self.searchChannelsController.channelThumbnailCollectionView.collectionViewLayout;
        UIEdgeInsets insets= layout.sectionInset;
        insets.top = 10.0f;
        insets.bottom = 10.0f;
        layout.sectionInset = insets;
    }
}




-(void)showSearchResultsForTerm:(NSString*)newSearchTerm
{
    
    if(searchTerm && [searchTerm isEqualToString:newSearchTerm])
        return;
    
    
    searchTerm = newSearchTerm;
    
    if(!searchTerm)
        return;
    
    if(!viewIsOnScreen)
        return;
    
    
    [self performSearchForCurrentSearchTerm];
    
    
}




-(void)viewWillAppear:(BOOL)animated
{
    
    // TODO: Check why we have to invert
    
    [super viewWillAppear:animated];
    
    
    self.searchVideosController = [[SYNSearchVideosViewController alloc] initWithViewId:viewId];
    self.searchVideosController.itemToUpdate = self.videoSearchTabView;
    self.searchVideosController.parent = self;
    [self addChildViewController:self.searchVideosController];
    
    self.searchChannelsController = [[SYNSearchChannelsViewController alloc] initWithViewId:viewId];
    self.searchChannelsController.itemToUpdate = self.channelsSearchTabView;
    self.searchChannelsController.parent = self;
    [self addChildViewController:self.searchChannelsController];
    
    viewIsOnScreen = YES;
    
    if(searchTerm)
        [self performSearchForCurrentSearchTerm];
    
    if(!self.currentController)
        [self videoTabPressed:nil];
    
    
}

#pragma mark - Main Search Call

-(void)performSearchForCurrentSearchTerm
{
    
    if(![appDelegate.searchRegistry clearImportContextFromEntityName:@"VideoInstance"])
    {
        DebugLog(@"Could not clean VideoInstances from search context");
    }
    
    if(![appDelegate.searchRegistry clearImportContextFromEntityName:@"Channel"])
    {
        DebugLog(@"Could not clean Channel from search context");
    }
    
    
    
    
    [self.searchVideosController performSearchWithTerm:searchTerm];
    [self.searchChannelsController performSearchWithTerm:searchTerm];
}

#pragma mark - Leaving the View

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNoteSearchBarRequestHide object:self];
    
}

-(void)dealloc
{
    viewIsOnScreen = NO;
    
    searchTerm = nil;
    
    self.videoSearchTabView.selected = NO;
    self.channelsSearchTabView.selected = NO;
    
    
    [self.currentController.view removeFromSuperview];
    
    self.currentController = nil;
    
    
    self.searchVideosController = nil;
    self.searchChannelsController = nil;
}

-(void)animatedPushViewController:(UIViewController *)vc
{
    [super animatedPushViewController:vc];
}




#pragma mark - Autorotation

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    CGFloat newWidth = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? 1024.0 : 768.0;
    tabsContainer.center = CGPointMake(newWidth * 0.5, tabsContainer.center.y);
    [self.searchChannelsController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.searchVideosController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.searchVideosController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.searchChannelsController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.searchVideosController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.searchChannelsController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}


#pragma mark - Accessor

- (BOOL) needsAddButton
{
    return NO;
}



@end
