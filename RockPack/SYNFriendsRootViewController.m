//
//  SYNFriendsViewController.m
//  rockpack
//
//  Created by Nick Banks on 21/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//


#import "AppConstants.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "NSDate-Utilities.h"
#import "SYNAppDelegate.h"
#import "SYNFriendThumbnailCell.h"
#import "SYNFriendsRootViewController.h"
#import "SYNHomeSectionHeaderView.h"
#import "SYNVideoThumbnailWideCell.h"
#import "Video.h"
#import "VideoInstance.h"

@interface SYNFriendsRootViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSMutableArray *videosArray;
@property (nonatomic, strong) SYNHomeSectionHeaderView *supplementaryView;
@property (nonatomic, strong) IBOutlet UICollectionView *friendThumbnailCollectionView;
@property (nonatomic, strong) NSFetchedResultsController *friendFetchedResultsController;
@property (nonatomic, strong) NSArray *forenameArray;
@property (nonatomic, strong) NSArray *surnameArray;
@property (nonatomic, strong) NSArray *thumbnailURLArray;

@end


@implementation SYNFriendsRootViewController

@synthesize friendFetchedResultsController = _friendFetchedResultsController;

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.trackedViewName = @"Friends - Root";
    
    // Init collection view
    UINib *friendThumbnailCellNib = [UINib nibWithNibName: @"SYNFriendThumbnailCell"
                                                  bundle: nil];
    
    [self.friendThumbnailCollectionView registerNib: friendThumbnailCellNib
                        forCellWithReuseIdentifier: @"SYNFriendThumbnailCell"];

    // Register collection view header view
    UINib *headerViewNib = [UINib nibWithNibName: @"SYNHomeSectionHeaderView"
                                          bundle: nil];
    
    [self.friendThumbnailCollectionView registerNib: headerViewNib
                        forSupplementaryViewOfKind: UICollectionElementKindSectionHeader
                               withReuseIdentifier: @"SYNHomeSectionHeaderView"];
    
    self.forenameArray = @[@"GREGORY", @"KISH", @"PAUL", @"PAUL", @"GREGORY", @"KISH", @"PAUL", @"PAUL"];
    
    self.surnameArray = @[@"TALON", @"PATEL", @"CACKETT", @"CACKETT", @"TALON", @"PATEL", @"CACKETT", @"CACKETT"];
    
    self.thumbnailURLArray =  @[@"http://demo.dev.rockpack.com.s3.amazonaws.com/images/Gregory.png",
                                @"http://demo.dev.rockpack.com.s3.amazonaws.com/images/Kish.png",
                                @"http://demo.dev.rockpack.com.s3.amazonaws.com/images/Paul.png",
                                @"http://demo.dev.rockpack.com.s3.amazonaws.com/images/Paul.png",
                                @"http://demo.dev.rockpack.com.s3.amazonaws.com/images/Gregory.png",
                                @"http://demo.dev.rockpack.com.s3.amazonaws.com/images/Kish.png",
                                @"http://demo.dev.rockpack.com.s3.amazonaws.com/images/Paul.png",
                                @"http://demo.dev.rockpack.com.s3.amazonaws.com/images/Paul.png"];
}

#pragma mark - Core Data support

// Single cached MOC for all the view controllers
- (NSManagedObjectContext *) mainManagedObjectContext
{
    static dispatch_once_t onceQueue;
    static NSManagedObjectContext *mainManagedObjectContext = nil;
    
    dispatch_once(&onceQueue, ^
                  {
                      SYNAppDelegate *delegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
                      mainManagedObjectContext = delegate.mainManagedObjectContext;
                  });
    
    return mainManagedObjectContext;
}


// Generalised version of videoInstanceFetchedResultsController, you can override the predicate and sort descriptors
// by overiding the videoInstanceFetchedResultsControllerPredicate and videoInstanceFetchedResultsControllerSortDescriptors methods
- (NSFetchedResultsController *) vFetchedResultsController
{
    NSError *error = nil;
    
    // Return cached version if we have already created one
    if (_friendFetchedResultsController != nil)
    {
        return _friendFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    fetchRequest.entity = [NSEntityDescription entityForName: @"VideoInstance"
                                      inManagedObjectContext: self.mainManagedObjectContext];
    
    // Add any sort descriptors and predicates
    fetchRequest.predicate = self.friendFetchedResultsControllerPredicate;
    fetchRequest.sortDescriptors = self.friendFetchedResultsControllerSortDescriptors;
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    self.friendFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                                     managedObjectContext: self.mainManagedObjectContext
                                                                                       sectionNameKeyPath: self.friendFetchedResultsControllerSectionNameKeyPath
                                                                                                cacheName: nil];
    _friendFetchedResultsController.delegate = self;
    
    ZAssert([_friendFetchedResultsController performFetch: &error], @"friendFetchedResultsController:performFetch failed: %@\n%@", [error localizedDescription], [error userInfo]);
    
    return _friendFetchedResultsController;
}

- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{
    NSLog (@"controller updated");
}

// Abstract functions, should be overidden in subclasses
- (NSPredicate *) friendFetchedResultsControllerPredicate
{
    AssertOrLog (@"videoInstanceFetchedResultsControllerPredicate:Abstract function called");
    return nil;
}

- (NSArray *) friendFetchedResultsControllerSortDescriptors
{
    AssertOrLog (@"videoInstanceFetchedResultsControllerSortDescriptors:Abstract function called");
    return nil;
}

// No section name key path by default
- (NSString *) friendFetchedResultsControllerSectionNameKeyPath
{
    return nil;
}



#pragma mark - Collection view support

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    // There are two sectiona, one for favourites, one for friends
    return 2;
}

- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger) section
{
    // For purposes of the demo assume that there are 8 favourites and 64 friends
    NSInteger items = 64;
    
    if (section == 0)
    {
        items = 8;
    }
    
    return items;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    // SYNFriendThumbnailCell
    SYNFriendThumbnailCell *friendThumbnailCell = nil;
    
    if (collectionView == self.friendThumbnailCollectionView)
    {
        // No, but it was our collection view
        friendThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNFriendThumbnailCell"
                                                                                      forIndexPath: indexPath];
        
        // Leave the last favourites tile blank
        if (!((indexPath.section == 0) && (indexPath.row == 7)))
        {
            friendThumbnailCell.friendImageViewImage = self.thumbnailURLArray[indexPath.row % 8];
            friendThumbnailCell.forename.text = self.forenameArray[indexPath.row % 8];
            friendThumbnailCell.surname.text = self.surnameArray[indexPath.row % 8];
            
            if (indexPath.section == 0)
            {
                friendThumbnailCell.favouriteButton.selected = TRUE;
            }
        }
        else
        {
            friendThumbnailCell.favouriteButton.hidden = TRUE;
        }

        friendThumbnailCell.viewControllerDelegate = self;
    }
    
    return friendThumbnailCell;
}


- (void) collectionView: (UICollectionView *) collectionView
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    DebugLog (@"Selecting image well cell does nothing");
}

- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout*) collectionViewLayout
           referenceSizeForHeaderInSection: (NSInteger) section
{
    if (collectionView == self.friendThumbnailCollectionView)
    {
        return CGSizeMake(1024, 65);
    }
    else
    {
        return CGSizeMake(0, 0);
    }
}


// Used for the collection view header
- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
    UICollectionReusableView *sectionSupplementaryView = nil;
    
    if (collectionView == self.friendThumbnailCollectionView)
    {
        SYNHomeSectionHeaderView *headerSupplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind: kind
                                                                                               withReuseIdentifier: @"SYNHomeSectionHeaderView"
                                                                                                      forIndexPath: indexPath];
        NSString *sectionText;
        
        if (indexPath.section == 0)
        {
            sectionText = @"FAVOURITES (7)";
        }
        else
        {
            sectionText = @"FRIENDS (327)";  
        }
        
        // Special case, remember the first section view
        headerSupplementaryView.viewControllerDelegate = self;
//        headerSupplementaryView.description.text = sectionText;
        sectionSupplementaryView = headerSupplementaryView;
    }
    
    return sectionSupplementaryView;
}

- (void) collectionView: (UICollectionView *) collectionView
         didEndDisplayingSupplementaryView: (UICollectionReusableView *) view
       forElementOfKind: (NSString *) elementKind
            atIndexPath: (NSIndexPath *) indexPath
{
    if (collectionView == self.friendThumbnailCollectionView)
    {
        if (indexPath.section == 0)
        {
            // If out first section header leave the screen, then we need to ensure that we don't try and manipulate it
            //  in future (as it will no longer exist)
            self.supplementaryView = nil;
        }
    }
    else
    {
        // We should not be expecting any other supplementary views
        AssertOrLog(@"No valid collection view found");
    }
}


@end
