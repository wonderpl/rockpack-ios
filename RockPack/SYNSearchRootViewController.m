//
//  SYNSearchRootViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 27/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "AppConstants.h"
#import "GAI.h"
#import "SYNDeviceManager.h"
#import "SYNSearchChannelsViewController.h"
#import "SYNSearchRootViewController.h"
#import "SYNSearchTabView.h"
#import "SYNSearchVideosViewController.h"
#import "SYNSearchBoxViewController.h"

@interface SYNSearchRootViewController ()

@property (nonatomic) NSInteger tabSelected;
@property (nonatomic, strong) NSString* currentSelectionId;
@property (nonatomic, strong) NSString* lastSearchTerm;
@property (nonatomic, strong) SYNSearchChannelsViewController* searchChannelsController;
@property (nonatomic, strong) SYNSearchTabView* channelsSearchTabView;
@property (nonatomic, strong) SYNSearchTabView* videoSearchTabView;
@property (nonatomic, strong) SYNSearchVideosViewController* searchVideosController;
@property (nonatomic, strong) UIView* tabsContainer;
@property (nonatomic, weak) SYNAbstractViewController* currentController;
@property (nonatomic, weak) UIView* currentOverlayView;

@end


@implementation SYNSearchRootViewController

@synthesize tabsContainer;
@synthesize videoSearchTabView, channelsSearchTabView;




- (void) loadView
{
    CGRect frame = CGRectMake(0.0, 0.0,[SYNDeviceManager.sharedInstance currentScreenWidth],
                               [SYNDeviceManager.sharedInstance currentScreenHeight]);
    
    self.view = [[UIView alloc] initWithFrame: frame];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight; 
}


- (void) viewDidLoad
{
    
    
    [super viewDidLoad];
    
    self.videoSearchTabView = [SYNSearchTabView tabViewWithSearchType:SearchTabTypeVideos];
    self.channelsSearchTabView = [SYNSearchTabView tabViewWithSearchType:SearchTabTypeChannels];
    
    CGRect channelTabRect = self.channelsSearchTabView.frame;
    channelTabRect.origin.x = self.videoSearchTabView.frame.size.width; // place at the middle of the 2 tabs (where the first ends)
    self.channelsSearchTabView.frame = channelTabRect;
    
    tabsContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0,
                                                            self.channelsSearchTabView.frame.size.width * 2.0,
                                                            self.channelsSearchTabView.frame.size.height)];
    
    tabsContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [tabsContainer addSubview:self.channelsSearchTabView];
    [tabsContainer addSubview:self.videoSearchTabView];
    
    [self.videoSearchTabView addTarget: self
                                action: @selector(videoTabPressed:)
                      forControlEvents: UIControlEventTouchUpInside];
    
    [self.channelsSearchTabView addTarget: self
                                   action: @selector(channelTabPressed:)
                         forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat correctTabsY = [SYNDeviceManager.sharedInstance isIPad] ? 104.0 : self.channelsSearchTabView.frame.size.height/2 + 65.0f;
    tabsContainer.center = CGPointMake(self.view.center.x, correctTabsY);
    tabsContainer.frame = CGRectIntegral(tabsContainer.frame);
    
    [self.view addSubview:tabsContainer];
    
    [self.view bringSubviewToFront:self.addButton];
    
    // == Adding the main subviews == //
    
    self.searchVideosController = [[SYNSearchVideosViewController alloc] initWithViewId:viewId];
    self.searchVideosController.itemToUpdate = self.videoSearchTabView;
    self.searchVideosController.parent = self;
    [self addChildViewController:self.searchVideosController];
    [self.view insertSubview:self.searchVideosController.view belowSubview:tabsContainer];
    
    self.searchVideosController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if ([SYNDeviceManager.sharedInstance isIPhone])
    {
        CGRect collectionViewFrame = CGRectMake(0, 108.0f, 320.0f,self.view.frame.size.height - 108.0f);
        self.searchVideosController.videoThumbnailCollectionView.frame = collectionViewFrame;
        self.searchVideosController.videoThumbnailCollectionView.backgroundColor = [UIColor colorWithWhite:0.97f alpha:1.0f];
        UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)self.currentController.videoThumbnailCollectionView.collectionViewLayout;
        UIEdgeInsets insets= layout.sectionInset;
        insets.top = 2.0f;
        insets.bottom = 10.0f;
        layout.sectionInset = insets;
    }
    else
    {
        CGRect collectionViewFrame = self.searchVideosController.view.frame;
        collectionViewFrame.size = self.view.frame.size;
        self.searchVideosController.view.frame = collectionViewFrame;
    }
    
    
    self.searchChannelsController = [[SYNSearchChannelsViewController alloc] initWithViewId:viewId]; // this is "Search"
    self.searchChannelsController.itemToUpdate = self.channelsSearchTabView;
    self.searchChannelsController.parent = self;
    [self addChildViewController:self.searchChannelsController];
    [self.view insertSubview:self.searchChannelsController.view belowSubview:tabsContainer];
    self.searchChannelsController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    
    if ([SYNDeviceManager.sharedInstance isIPhone])
    {
        
        // FIXME: This magic number layout is not so good. self.view needs to be setup with the correct frame, and then we can start doing a relative layout.
        CGRect collectionViewFrame = CGRectMake(0, 48.0f, 320.0f, self.view.frame.size.height - 103.0f);
        self.searchChannelsController.channelThumbnailCollectionView.frame = collectionViewFrame;
        self.searchChannelsController.channelThumbnailCollectionView.backgroundColor = [UIColor colorWithWhite:0.97f alpha:1.0f];
        UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)self.searchChannelsController.channelThumbnailCollectionView.collectionViewLayout;
        UIEdgeInsets insets = layout.sectionInset;
        insets.top = 5.0f;
        insets.bottom = 10.0f;
        layout.sectionInset = insets;
        
    }
    
    
    

}

- (void) viewWillAppear: (BOOL) animated
{
    // TODO: Check why we have to invert
    
    [super viewWillAppear: animated];
    
    // FIXME: Replace with something more elegant (i.e. anything else)
    if (appDelegate.searchRefreshDisabled == TRUE)
    {
        return;
    }
    
    // Google analytics support
//    [GAI.sharedInstance.defaultTracker sendView: @"Search - Root"];
    
    viewIsOnScreen = YES;
    
    if (searchTerm)
        [self performSearchForCurrentSearchTerm];
    
    if (!self.currentController)
        [self videoTabPressed:nil];
    
        
    if([[SYNDeviceManager sharedInstance] isIPhone])
    {
//        [[NSNotificationCenter defaultCenter] postNotificationName: kNoteAllNavControlsHide
//                                                        object: self];
//        
//        [self.view addSubview:self.searchBoxViewController.searchBoxView];
        [self.searchBoxViewController.searchBoxView revealCloseButton];
    }
    
}


- (void) viewWillDisappear: (BOOL) animated
{
    self.lastSearchTerm = searchTerm;
    
    [super viewWillDisappear:animated];
    
    // FIXME: Replace with something more elegant (i.e. anything else)
    if (appDelegate.searchRefreshDisabled == TRUE)
    {
        return;
    }
    
    
    if([[SYNDeviceManager sharedInstance] isIPhone])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: kNoteAllNavControlsShow
                                                        object: self];
    }
    
}


- (void) dealloc
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


- (void) animatedPushViewController: (SYNAbstractViewController *) vc
{
    [super animatedPushViewController: vc];
}



- (void) videoTabPressed: (UIControl*) control
{
   if (self.videoSearchTabView.selected)
       return;
    
    self.videoSearchTabView.selected = YES;
    self.channelsSearchTabView.selected = NO;
    
    [self showVideoSearchResults];
    
}


- (void) channelTabPressed: (UIControl*) control
{
    [GAI.sharedInstance.defaultTracker sendView: @"Search - Channels"];
    
    if (self.channelsSearchTabView.selected)
        return;
    
    self.channelsSearchTabView.selected = YES;
    self.videoSearchTabView.selected = NO;
    
    [self showChannelsSearchResult];
}


- (void) showVideoSearchResults
{
    if (self.currentController == self.searchVideosController)
        return;
    
    
    
    [self.searchVideosController.view setHidden:NO];
    [self.searchChannelsController.view setHidden:YES];
    
    self.currentController = self.searchVideosController;
    
    
    
}


- (void) showChannelsSearchResult
{
    if (self.currentController == self.searchChannelsController)
        return;
    
    
    
    [self.searchVideosController.view setHidden:YES];
    [self.searchChannelsController.view setHidden:NO];
    
    self.currentController = self.searchChannelsController;
    
    
    
}


- (void) showSearchResultsForTerm: (NSString*) newSearchTerm
{
    if (searchTerm && [searchTerm isEqualToString:newSearchTerm])
        return;
    
    searchTerm = newSearchTerm;
    
    if (!searchTerm)
        return;
    
    if (!viewIsOnScreen)
        return;
    
    [self performSearchForCurrentSearchTerm];
}


#pragma mark - Main Search Call

- (void) performSearchForCurrentSearchTerm
{
    BOOL success = [appDelegate.searchRegistry clearImportContextFromEntityName:@"Channel"];
    if (!success)
    {
        DebugLog(@"Could not clean Channel from search context");
    }
    
    
    success = [appDelegate.searchRegistry clearImportContextFromEntityName:@"VideoInstance"];
    if (!success)
    {
        DebugLog(@"Could not clean VideoInstances from search context");
    }
    
    [self.searchVideosController performNewSearchWithTerm:searchTerm];
    [self.searchChannelsController performNewSearchWithTerm:searchTerm];
}




#pragma mark - Accessor



- (BOOL) alwaysDisplaysSearchBox
{
    return YES;
}

@end
