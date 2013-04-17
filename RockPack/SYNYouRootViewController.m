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
#import "SYNChannelsDetailViewController.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNYouRootViewController.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+ImageProcessing.h"
#import "Video.h"
#import "SYNUserProfileViewController.h"

@interface SYNYouRootViewController ()

@property (nonatomic, assign) BOOL userPinchedOut;
@property (nonatomic, strong) IBOutlet UICollectionView *channelThumbnailCollectionView;
@property (nonatomic, strong) NSIndexPath *pinchedIndexPath;
@property (nonatomic, strong) UIImageView *pinchedView;

@property (nonatomic, strong) SYNUserProfileViewController* userProfileController;

@property (nonatomic, strong) IBOutlet UIPopoverController* accountSettingsPopover;

@end

@implementation SYNYouRootViewController

#pragma mark - View lifecycle

- (id) initWithViewId: (NSString *) vid
{
    if(self = [super initWithViewId: vid])
    {
        self.title = @"My Rockpack";
    }
    return self;
}


#pragma mark - View lifecycle

- (void) loadView
{
    //    UIImageView *headerView = [UI]
    
    SYNIntegralCollectionViewFlowLayout* flowLayout = [[SYNIntegralCollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.headerReferenceSize = CGSizeMake(0.0, 0.0);
    flowLayout.footerReferenceSize = CGSizeMake(0.0, 0.0);
    flowLayout.itemSize = CGSizeMake(251.0, 302.0);
    flowLayout.sectionInset = UIEdgeInsetsMake(10.0, 3.0, 5.0, 3.0);
    flowLayout.minimumLineSpacing = 3.0;
    flowLayout.minimumInteritemSpacing = 0.0;
    
    CGRect collectionViewFrame = CGRectMake(0.0, 158.0, 1024.0, 528.0);
    
    self.channelThumbnailCollectionView = [[UICollectionView alloc] initWithFrame: collectionViewFrame
                                                             collectionViewLayout: flowLayout];
    self.channelThumbnailCollectionView.dataSource = self;
    self.channelThumbnailCollectionView.delegate = self;
    self.channelThumbnailCollectionView.backgroundColor = [UIColor clearColor];
    
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1024.0, 748.0)];
    
    [self.view addSubview:self.channelThumbnailCollectionView];
    
    
    self.userProfileController = [[SYNUserProfileViewController alloc] init];
    
    CGRect userProfileFrame = self.userProfileController.view.frame;
    userProfileFrame.origin.y = 60.0;
    self.userProfileController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    self.userProfileController.view.frame = userProfileFrame;
    [self.view addSubview:self.userProfileController.view];
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.trackedViewName = @"You - Root";
    
    // Init collection view
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNChannelThumbnailCell"
                                             bundle: nil];
    
    [self.channelThumbnailCollectionView registerNib: thumbnailCellNib
                          forCellWithReuseIdentifier: @"SYNChannelThumbnailCell"];
    
    UIPinchGestureRecognizer *pinchOnChannelView = [[UIPinchGestureRecognizer alloc] initWithTarget: self
                                                                                             action: @selector(handlePinchGesture:)];
    
    [self.view addGestureRecognizer: pinchOnChannelView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountSettingsPressed:) name:kAccountSettingsPressed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountSettingsLogout:) name:kAccountSettingsLogout object:nil];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear:animated];
    
    
    
    [self.userProfileController setChannelOwner:appDelegate.currentUser];
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
    NSPredicate* subscribedByUserPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"subscribedByUser == YES"]];
    NSArray* predicates = @[ownedByUserPredicate, subscribedByUserPredicate];
    
                                              
    fetchRequest.predicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"title" ascending: YES]];
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                        managedObjectContext: appDelegate.mainManagedObjectContext
                                                                          sectionNameKeyPath: @"subscribedByUser"
                                                                                   cacheName: nil];
    fetchedResultsController.delegate = self;
    
    ZAssert([fetchedResultsController performFetch: &error],
            @"YouRootViewController failed: %@\n%@", [error localizedDescription], [error userInfo]);
    
    return fetchedResultsController;
}


-(void)accountSettingsPressed:(NSNotification*)notification
{
    [self showAccountSettingsPopover];
}

-(void)accountSettingsLogout:(NSNotification*)notification
{
    [self.accountSettingsPopover dismissPopoverAnimated:NO];
    self.accountSettingsPopover = nil;
    [appDelegate logout];
}


-(void)showAccountSettingsPopover
{
    if(self.accountSettingsPopover)
        return;
    
    SYNAccountSettingsMainTableViewController* mainTable = [[SYNAccountSettingsMainTableViewController alloc] init];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:mainTable];
    
    
    self.accountSettingsPopover = [[UIPopoverController alloc] initWithContentViewController: navigationController];
    self.accountSettingsPopover.popoverContentSize = CGSizeMake(380, 576);
    self.accountSettingsPopover.delegate = self;
    
    self.accountSettingsPopover.popoverBackgroundViewClass = [SYNAccountSettingsPopoverBackgroundView class];
    
    CGRect rect = CGRectMake(self.view.frame.size.width*0.5,
                             self.view.frame.size.height*0.5 + 30.0, 1, 1);
    
    
    [self.accountSettingsPopover presentPopoverFromRect: rect
                                                 inView: self.view
                               permittedArrowDirections: 0
                                               animated: YES];
    
    
}


#pragma mark - Collection view support

- (NSInteger) collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return sectionInfo.numberOfObjects;
}

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return self.fetchedResultsController.sections.count;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView cellForItemAtIndexPath: (NSIndexPath *) indexPath {
    
    Channel *channel = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    SYNChannelThumbnailCell *channelThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelThumbnailCell"
                                                                                              forIndexPath: indexPath];
    
    channelThumbnailCell.channelImageViewImage = channel.coverThumbnailLargeURL;
    [channelThumbnailCell setChannelTitle:channel.title];
    
    channelThumbnailCell.displayNameLabel.text = [NSString stringWithFormat:@"%@", channel.channelOwner.displayName];
    channelThumbnailCell.viewControllerDelegate = self;
    
    return channelThumbnailCell;
    
}

-(void)displayNameButtonPressed:(UIButton*)button
{
    SYNChannelThumbnailCell* parent = (SYNChannelThumbnailCell*)[[button superview] superview];
    
    NSIndexPath* indexPath = [self.channelThumbnailCollectionView indexPathForCell:parent];
    
    Channel *channel = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowUserChannels
                                                        object:self
                                                      userInfo:@{@"ChannelOwner":channel.channelOwner}];
    
}


- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    Channel *channel = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    SYNChannelsDetailViewController *channelVC = [[SYNChannelsDetailViewController alloc] initWithChannel: channel];
    
    [self animatedPushViewController: channelVC];
}


// Custom zoom out transition
- (void) transitionToItemAtIndexPath: (NSIndexPath *) indexPath
{
    Channel *channel = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    SYNAbstractChannelsDetailViewController *channelVC = [[SYNAbstractChannelsDetailViewController alloc] initWithChannel: channel];
    
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


-(void)hideAutocompletePopover
{
    if(!self.accountSettingsPopover)
        return;
    
    [self.accountSettingsPopover dismissPopoverAnimated:YES];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if(popoverController == self.accountSettingsPopover)
    {
        
        self.accountSettingsPopover = nil;
    }
    
}



@end
