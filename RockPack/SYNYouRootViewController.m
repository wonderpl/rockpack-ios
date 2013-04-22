//
//  SYNYouRootViewController.m
//  rockpack
//
//  Created by Nick Banks on 24/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "Channel.h"
#import "ChannelOwner.h"
#import "SYNAccountSettingsMainTableViewController.h"
#import "SYNAccountSettingsPopoverBackgroundView.h"
#import "SYNChannelThumbnailCell.h"
#import "SYNChannelDetailViewController.h"
#import "SYNDeviceManager.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNYouRootViewController.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+ImageProcessing.h"
#import "Video.h"
#import "SYNUserProfileViewController.h"
#import "SYNSubscriptionsViewController.h"
#import "SYNChannelMidCell.h"
#import "SYNYouHeaderView.h"

#define kInterChannelSpacing 138.0

@interface SYNYouRootViewController ()

@property (nonatomic, assign) BOOL userPinchedOut;
@property (nonatomic, strong) IBOutlet UICollectionView *channelThumbnailCollectionView;
@property (nonatomic, strong) IBOutlet UIPopoverController* accountSettingsPopover;
@property (nonatomic, strong) NSIndexPath *pinchedIndexPath;
@property (nonatomic, strong) SYNIntegralCollectionViewFlowLayout* leftLandscapeLayout;
@property (nonatomic, strong) SYNIntegralCollectionViewFlowLayout* leftPortraitLayout;
@property (nonatomic, strong) SYNIntegralCollectionViewFlowLayout* rightLandscapeLayout;
@property (nonatomic, strong) SYNIntegralCollectionViewFlowLayout* rightPortraitLayout;
@property (nonatomic, strong) SYNSubscriptionsViewController* subscriptionsViewController;
@property (nonatomic, strong) SYNUserProfileViewController* userProfileController;
@property (nonatomic, strong) SYNYouHeaderView* headerCheannelsView;
@property (nonatomic, strong) SYNYouHeaderView* headerSubscriptionsView;
@property (nonatomic, strong) UIImageView *pinchedView;


@end

@implementation SYNYouRootViewController

@synthesize subscriptionsViewController;

#pragma mark - View lifecycle

- (id) initWithViewId: (NSString *) vid
{
    if(self = [super initWithViewId: vid])
    {
        self.title = kProfileTitle;
    }
    return self;
}


#pragma mark - View lifecycle

- (void) loadView
{
    //    UIImageView *headerView = [UI]
    
    // User Profile
    
    self.userProfileController = [[SYNUserProfileViewController alloc] init];

    // Main Collection View
    
    SYNIntegralCollectionViewFlowLayout* flowLayout = [[SYNIntegralCollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.headerReferenceSize = CGSizeMake(0.0, 0.0);
    flowLayout.footerReferenceSize = CGSizeMake(0.0, 0.0);
    flowLayout.itemSize = CGSizeMake(184.0, kInterChannelSpacing);
    flowLayout.sectionInset = UIEdgeInsetsMake(10.0, 8.0, 5.0, 25.0);
    flowLayout.minimumLineSpacing = 10.0;
    flowLayout.minimumInteritemSpacing = 0.0;
    
    self.leftLandscapeLayout = flowLayout;
    
    flowLayout = [[SYNIntegralCollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.headerReferenceSize = CGSizeMake(0.0, 0.0);
    flowLayout.footerReferenceSize = CGSizeMake(0.0, 0.0);
    flowLayout.itemSize = CGSizeMake(184.0, kInterChannelSpacing);
    flowLayout.sectionInset = UIEdgeInsetsMake(10.0, 25.0, 5.0, 8.0);
    flowLayout.minimumLineSpacing = 10.0;
    flowLayout.minimumInteritemSpacing = 0.0;
    
    self.rightLandscapeLayout = flowLayout;
    
    flowLayout = [[SYNIntegralCollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.headerReferenceSize = CGSizeMake(0.0, 0.0);
    flowLayout.footerReferenceSize = CGSizeMake(0.0, 0.0);
    flowLayout.itemSize = CGSizeMake(184.0, kInterChannelSpacing);
    flowLayout.sectionInset = UIEdgeInsetsMake(10.0, 4.0, 5.0, 4.0);
    flowLayout.minimumLineSpacing = 10.0;
    flowLayout.minimumInteritemSpacing = 0.0;
    
    self.leftPortraitLayout = flowLayout;
    
    flowLayout = [[SYNIntegralCollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.headerReferenceSize = CGSizeMake(0.0, 0.0);
    flowLayout.footerReferenceSize = CGSizeMake(0.0, 0.0);
    flowLayout.itemSize = CGSizeMake(184.0, kInterChannelSpacing);
    flowLayout.sectionInset = UIEdgeInsetsMake(10.0, 4.0, 5.0, 4.0);
    flowLayout.minimumLineSpacing = 10.0;
    flowLayout.minimumInteritemSpacing = 0.0;
    
    self.rightPortraitLayout = flowLayout;
    
    CGFloat correctWidth = [[SYNDeviceManager sharedInstance] isLandscape] ? 600.0 : 400.0;
    
    self.headerCheannelsView = [SYNYouHeaderView headerViewForWidth:correctWidth];
    [self.headerCheannelsView setTitle:@"YOUR CHANNELS" andNumber:2];
    [self.headerCheannelsView setBackgroundImage:([[SYNDeviceManager sharedInstance] isLandscape] ? [UIImage imageNamed:@"HeaderProfileChannelsLandscape"] : [UIImage imageNamed:@"HeaderProfilePortraitBoth"])];
    
    CGRect collectionViewFrame = CGRectMake(0.0,
                                            self.headerCheannelsView.frame.origin.y + self.headerCheannelsView.currentHeight,
                                            correctWidth,
                                            [[SYNDeviceManager sharedInstance] currentScreenHeight] - 20.0 - kYouCollectionViewOffsetY);
    
    self.channelThumbnailCollectionView = [[UICollectionView alloc] initWithFrame: collectionViewFrame
                                                             collectionViewLayout: flowLayout];
    
    self.channelThumbnailCollectionView.dataSource = self;
    self.channelThumbnailCollectionView.delegate = self;
    self.channelThumbnailCollectionView.backgroundColor = [UIColor clearColor];
    self.channelThumbnailCollectionView.showsVerticalScrollIndicator = NO;

    // Subscriptions Collection View
    
    self.subscriptionsViewController = [[SYNSubscriptionsViewController alloc] initWithViewId: kProfileViewId];
    CGRect subColViewFrame = self.subscriptionsViewController.view.frame;
    subColViewFrame.origin.x = collectionViewFrame.origin.x + collectionViewFrame.size.width + 10.0;
    subColViewFrame.origin.y = collectionViewFrame.origin.y;
    subColViewFrame.size.height = collectionViewFrame.size.height;
    subColViewFrame.size.width = [[SYNDeviceManager sharedInstance] currentScreenWidth] - subColViewFrame.origin.x - 10.0;
    
    [self.subscriptionsViewController setViewFrame:subColViewFrame];
    
    self.headerSubscriptionsView = [SYNYouHeaderView headerViewForWidth: 384];
    [self.headerSubscriptionsView setTitle:@"YOUR SUBSCRIPTIONS" andNumber: 2];
    [self.headerSubscriptionsView setBackgroundImage:([[SYNDeviceManager sharedInstance] isLandscape] ? [UIImage imageNamed:@"HeaderProfileSubscriptionsLandscape"] : [UIImage imageNamed: @"HeaderProfilePortraitBoth"])];
    CGRect headerSubFrame = self.headerSubscriptionsView.frame;
    headerSubFrame.origin.x = subColViewFrame.origin.x;
    self.headerSubscriptionsView.frame = headerSubFrame;
    
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                         0.0,
                                                         [[SYNDeviceManager sharedInstance] currentScreenWidth],
                                                         [[SYNDeviceManager sharedInstance] currentScreenHeightWithStatusBar])];
    
    self.subscriptionsViewController.headerView = self.headerSubscriptionsView;
    
    [self.view addSubview:self.headerCheannelsView];
    
    [self.view addSubview:self.headerSubscriptionsView];
    
    [self.view addSubview:self.userProfileController.view];
    
    [self.view addSubview:self.channelThumbnailCollectionView];
    
    [self.view addSubview:self.subscriptionsViewController.view];
    
    CGRect userProfileFrame = self.userProfileController.view.frame;
    userProfileFrame.origin.y = 80.0;
    self.userProfileController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    self.userProfileController.view.frame = userProfileFrame;
    [self.view addSubview:self.userProfileController.view];
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.trackedViewName = @"You - Root";
    
    // Init collection view
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNChannelMidCell"
                                             bundle: nil];
    
    [self.channelThumbnailCollectionView registerNib: thumbnailCellNib
                          forCellWithReuseIdentifier: @"SYNChannelMidCell"];
    
    UIPinchGestureRecognizer *pinchOnChannelView = [[UIPinchGestureRecognizer alloc] initWithTarget: self
                                                                                             action: @selector(handlePinchGesture:)];
    
    [self.view addGestureRecognizer: pinchOnChannelView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountSettingsPressed:) name:kAccountSettingsPressed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountSettingsLogout:) name:kAccountSettingsLogout object:nil];
    
    
    [self.channelThumbnailCollectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    [self.subscriptionsViewController.collectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [self.userProfileController setChannelOwner:appDelegate.currentUser];
    
    self.subscriptionsViewController.collectionView.delegate = self;
    
    [self updateLayoutForOrientation:[[SYNDeviceManager sharedInstance] orientation]];
    
}


- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    CGSize subSize = self.subscriptionsViewController.collectionView.contentSize;
    CGSize thumbSize = self.channelThumbnailCollectionView.contentSize;
    subSize.height = thumbSize.height;
    self.subscriptionsViewController.collectionView.contentSize = CGSizeMake(subSize.width, 1800.0);
    
    [self reloadCollectionViews];
}


- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    [self updateLayoutForOrientation:toInterfaceOrientation];
}


- (void) updateLayoutForOrientation: (UIDeviceOrientation )orientation
{
    CGRect newFrame;
    CGFloat viewHeight;
    SYNIntegralCollectionViewFlowLayout* leftLayout;
    SYNIntegralCollectionViewFlowLayout* rightLayout;
    
    //Setup the headers
    if (UIDeviceOrientationIsPortrait(orientation))
    {
        
        newFrame = self.headerCheannelsView.frame;
        newFrame.size.width = 384.0f;
        self.headerCheannelsView.frame = newFrame;
        
        newFrame = self.headerSubscriptionsView.frame;
        newFrame.origin.x = 384.0f ;
        newFrame.size.width = 384.0f;
        self.headerSubscriptionsView.frame = newFrame;
        
        viewHeight = 1004;
        
        leftLayout = self.leftPortraitLayout;
        rightLayout = self.rightPortraitLayout;
        
    }
    else
    {
        newFrame = self.headerCheannelsView.frame;
        newFrame.size.width = 612.0f;
        self.headerCheannelsView.frame = newFrame;
        
        newFrame = self.headerSubscriptionsView.frame;
        newFrame.origin.x = 612.0f ;
        newFrame.size.width = 412.0f;
        self.headerSubscriptionsView.frame = newFrame;
        
        viewHeight = 748;
        
        leftLayout = self.leftLandscapeLayout;
        rightLayout = self.rightLandscapeLayout;
    }
    
    //Apply correct backgorund images
    [self.headerSubscriptionsView setBackgroundImage:([[SYNDeviceManager sharedInstance] isLandscape] ? [UIImage imageNamed:@"HeaderProfileSubscriptionsLandscape"] : [UIImage imageNamed: @"HeaderProfilePortraitBoth"])];
    
    [self.headerCheannelsView setBackgroundImage:[[SYNDeviceManager sharedInstance] isLandscape] ? [UIImage imageNamed: @"HeaderProfileChannelsLandscape"] : [UIImage imageNamed: @"HeaderProfilePortraitBoth"]];
    
    NSIndexPath* indexPath = nil;
    if(self.channelThumbnailCollectionView.contentOffset.y > self.subscriptionsViewController.channelThumbnailCollectionView.contentOffset.y)
    {
        UICollectionViewCell* visibleCell = ([[self.channelThumbnailCollectionView visibleCells] count] > 0) ? [[self.channelThumbnailCollectionView visibleCells] objectAtIndex:0] : nil;
        if(visibleCell != nil){
            indexPath = [self.channelThumbnailCollectionView indexPathForCell:visibleCell];
        }
    }
    
    // Setup Channel feed collection view
    newFrame = self.channelThumbnailCollectionView.frame;
    newFrame.size.width = self.headerCheannelsView.frame.size.width;
    newFrame.size.height = viewHeight - newFrame.origin.y;
    self.channelThumbnailCollectionView.frame = newFrame;
    self.channelThumbnailCollectionView.collectionViewLayout = leftLayout;
    [leftLayout invalidateLayout];
    
    if (indexPath)
    {
        [self.channelThumbnailCollectionView scrollToItemAtIndexPath: indexPath
                                                    atScrollPosition: UICollectionViewScrollPositionTop
                                                            animated: NO];
    }
    
    if (!indexPath)
    {
        UICollectionViewCell* visibleCell = ([[self.subscriptionsViewController.channelThumbnailCollectionView visibleCells] count] > 0) ? [[self.subscriptionsViewController.channelThumbnailCollectionView visibleCells] objectAtIndex: 0] : nil;
        if(visibleCell != nil)
        {
            indexPath = [self.subscriptionsViewController.channelThumbnailCollectionView indexPathForCell: visibleCell];
        }
    }
    else
    {
        indexPath = nil;
    }
    
    //Setup subscription feed collection view
    newFrame = self.subscriptionsViewController.view.frame;
    newFrame.size.width = self.headerSubscriptionsView.frame.size.width;
    newFrame.size.height = viewHeight - newFrame.origin.y;
    newFrame.origin.x = self.headerSubscriptionsView.frame.origin.x;
    self.subscriptionsViewController.view.frame = newFrame;
    self.subscriptionsViewController.channelThumbnailCollectionView.collectionViewLayout = rightLayout;
    [rightLayout invalidateLayout];
    
    if (indexPath)
    {
        [self.subscriptionsViewController.channelThumbnailCollectionView scrollToItemAtIndexPath: indexPath
                                                                                atScrollPosition: UICollectionViewScrollPositionTop
                                                                                        animated: NO];
    }
}


- (NSFetchedResultsController *) fetchedResultsController
{
    NSError *error = nil;
    
    // Return cached version if we have already created one
    if (fetchedResultsController != nil)
        return fetchedResultsController;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    ChannelOwner* meAsOwner = (ChannelOwner*)appDelegate.currentUser;
    
    // Edit the entity name as appropriate.
    fetchRequest.entity = [NSEntityDescription entityForName: @"Channel"
                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    NSPredicate* ownedByUserPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"channelOwner.uniqueId == '%@'", meAsOwner.uniqueId]];
    
    
    fetchRequest.predicate = ownedByUserPredicate;
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"title"
                                                                 ascending: YES]];
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                        managedObjectContext: appDelegate.mainManagedObjectContext
                                                                          sectionNameKeyPath: nil
                                                                                   cacheName: nil];
    fetchedResultsController.delegate = self;
    
    ZAssert([fetchedResultsController performFetch: &error],
            @"YouRootViewController failed: %@\n%@", [error localizedDescription], [error userInfo]);
    
    
    return fetchedResultsController;
}


- (void) accountSettingsPressed: (NSNotification*) notification
{
    [self showAccountSettingsPopover];
}


- (void) reloadCollectionViews
{
    [super reloadCollectionViews];
    
    NSInteger totalChannels = self.fetchedResultsController.fetchedObjects.count;
    
    [self.headerCheannelsView setTitle: @"YOUR CHANNELS"
                             andNumber: totalChannels];
    
    [self.subscriptionsViewController reloadCollectionViews];
}

- (void) accountSettingsLogout: (NSNotification*) notification
{
    [self.accountSettingsPopover dismissPopoverAnimated: NO];
    self.accountSettingsPopover = nil;
    [appDelegate logout];
}


- (void) showAccountSettingsPopover
{
    if(self.accountSettingsPopover)
        return;
    
    SYNAccountSettingsMainTableViewController* mainTable = [[SYNAccountSettingsMainTableViewController alloc] init];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController: mainTable];
    
    self.accountSettingsPopover = [[UIPopoverController alloc] initWithContentViewController: navigationController];
    self.accountSettingsPopover.popoverContentSize = CGSizeMake(380, 576);
    self.accountSettingsPopover.delegate = self;
    
    self.accountSettingsPopover.popoverBackgroundViewClass = [SYNAccountSettingsPopoverBackgroundView class];
    
    CGRect rect = CGRectMake(self.view.frame.size.width * 0.5,
                             self.view.frame.size.height * 0.5 + 30.0, 1, 1);
    
    [self.accountSettingsPopover presentPopoverFromRect: rect
                                                 inView: self.view
                               permittedArrowDirections: 0
                                               animated: YES];
}


#pragma mark - UICollectionView DataSource

- (NSInteger) collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return sectionInfo.numberOfObjects;
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return self.fetchedResultsController.sections.count;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    Channel *channel = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    SYNChannelMidCell *channelThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelMidCell"
                                                                                        forIndexPath: indexPath];
    
    channelThumbnailCell.channelImageViewImage = channel.coverThumbnailLargeURL;
    [channelThumbnailCell setChannelTitle:channel.title];
    
    
    return channelThumbnailCell;
    
}


- (void) collectionView: (UICollectionView *) collectionView
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    Channel *channel;
    
    if(collectionView == self.channelThumbnailCollectionView)
    {
        channel = [self.fetchedResultsController objectAtIndexPath: indexPath];
        
    }
    else
    {
        channel = [self.subscriptionsViewController channelAtIndexPath:indexPath];
    }
    
    SYNChannelDetailViewController *channelVC = [[SYNChannelDetailViewController alloc] initWithChannel: channel];
    
    [self animatedPushViewController: channelVC];
    
}


- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    CGPoint offset;
    if ([scrollView isEqual: self.channelThumbnailCollectionView])
    {
        offset = self.channelThumbnailCollectionView.contentOffset;
        offset.y = self.channelThumbnailCollectionView.contentOffset.y;
        [self.subscriptionsViewController.collectionView setContentOffset: offset];
    }
    else if ([scrollView isEqual:self.subscriptionsViewController.collectionView])
    {
        offset = self.subscriptionsViewController.collectionView.contentOffset;
        offset.y = self.subscriptionsViewController.collectionView.contentOffset.y;
        [self.channelThumbnailCollectionView setContentOffset: offset];
    }
}


- (void) displayNameButtonPressed: (UIButton*) button
{
    SYNChannelThumbnailCell* parent = (SYNChannelThumbnailCell*)[[button superview] superview];
    
    NSIndexPath* indexPath = [self.channelThumbnailCollectionView indexPathForCell: parent];
    
    Channel *channel = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kShowUserChannels
                                                        object: self
                                                      userInfo: @{@"ChannelOwner" : channel.channelOwner}];
}


// Custom zoom out transition
- (void) transitionToItemAtIndexPath: (NSIndexPath *) indexPath
{
    Channel *channel = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    SYNChannelDetailViewController *channelVC = [[SYNChannelDetailViewController alloc] initWithChannel: channel];
    
    channelVC.view.alpha = 0.0f;
    
    [self.navigationController pushViewController: channelVC
                                         animated: NO];
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         // Contract thumbnail view
         self.view.alpha = 0.0f;
         channelVC.view.alpha = 1.0f;
         self.pinchedView.alpha = 0.0f;
         self.pinchedView.transform = CGAffineTransformMakeScale(10.0f, 10.0f);
         
     }
                     completion: ^(BOOL finished)
     {
         [self.pinchedView removeFromSuperview];
     }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteBackButtonShow
                                                        object: self];
}


- (void) handlePinchGesture: (UIPinchGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        // At this stage, we don't know whether the user is pinching in or out
        self.userPinchedOut = FALSE;
        
        DebugLog (@"UIGestureRecognizerStateBegan");
        // figure out which item in the table was selected
        NSIndexPath *indexPath = [self.channelThumbnailCollectionView indexPathForItemAtPoint: [sender locationInView: self.channelThumbnailCollectionView]];
        
        if (!indexPath)
        {
            return;
        }
        
        self.pinchedIndexPath = indexPath;
        
        Channel *channel = [self.fetchedResultsController objectAtIndexPath: indexPath];
        SYNChannelThumbnailCell *channelCell = (SYNChannelThumbnailCell *)[self.channelThumbnailCollectionView cellForItemAtIndexPath: indexPath];
        
        // Get the various frames we need to calculate the actual position
        CGRect imageViewFrame = channelCell.imageView.frame;
        CGRect viewFrame = channelCell.superview.frame;
        CGRect cellFrame = channelCell.frame;
        
        CGPoint offset = self.channelThumbnailCollectionView.contentOffset;
        
        // Now add them together to get the real pos in the top view
        imageViewFrame.origin.x += cellFrame.origin.x + viewFrame.origin.x - offset.x;
        imageViewFrame.origin.y += cellFrame.origin.y + viewFrame.origin.y - offset.y;
        
        self.pinchedView = [[UIImageView alloc] initWithFrame: imageViewFrame];
        self.pinchedView.alpha = 0.7f;
        [self.pinchedView setAsynchronousImageFromURL: [NSURL URLWithString: channel.coverThumbnailLargeURL]
                                     placeHolderImage: nil];
        // now add the item to the view
        [self.view addSubview: self.pinchedView];
    }
    else if (sender.state == UIGestureRecognizerStateChanged)
    {
        DebugLog (@"UIGestureRecognizerStateChanged");
        float scale = sender.scale;
        
        if (scale < 1.0)
        {
            return;
        }
        else
        {
            self.userPinchedOut = TRUE;
            
            // we zoomed it, so let's update the coordinates of the dragged view
            self.pinchedView.transform = CGAffineTransformMakeScale(scale, scale);
        }
    }
    else if (sender.state == UIGestureRecognizerStateEnded)
    {
        DebugLog (@"UIGestureRecognizerStateEnded");
        
        if (self.userPinchedOut == TRUE)
        {
            [self transitionToItemAtIndexPath: self.pinchedIndexPath];
        }
    }
    else if (sender.state == UIGestureRecognizerStateCancelled)
    {
        DebugLog (@"UIGestureRecognizerStateCancelled");
        [self.pinchedView removeFromSuperview];
    }
}


- (void) hideAutocompletePopover
{
    if (!self.accountSettingsPopover)
        return;
    
    [self.accountSettingsPopover dismissPopoverAnimated: YES];
}

- (void) popoverControllerDidDismissPopover: (UIPopoverController *) popoverController
{
    if (popoverController == self.accountSettingsPopover)
    {
        
        self.accountSettingsPopover = nil;
    }
    
}

- (void) observeValueForKeyPath: (NSString *) keyPath
                       ofObject: (id) object
                         change: (NSDictionary *) change
                        context: (void *)context
{
    if ([keyPath isEqualToString: @"contentSize"])
    {
        // CGSize newContentSize = [[change valueForKey:NSKeyValueChangeNewKey] CGSizeValue];
        
        //        CGSize s1Size = self.channelThumbnailCollectionView.contentSize;
        //        CGSize s2Size = self.subscriptionsViewController.collectionView.contentSize;
        //
        //        if(s1Size.height == s2Size.height)
        //            return;
        //
        //
        //        self.subscriptionsViewController.collectionView.contentSize = CGSizeMake(s2Size.width, s1Size.height);
    }
}

@end
