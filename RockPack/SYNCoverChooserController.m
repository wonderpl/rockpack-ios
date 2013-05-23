//
//  SYNCoverChooserController.m
//  rockpack
//
//  Created by Michael Michailidis on 14/05/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "Channel.h"
#import "ChannelCover.h"
#import "CoverArt.h"
#import "GKImagePicker.h"
#import "SDWebImageManager.h"
#import "SYNAppDelegate.h"
#import "SYNCameraPopoverViewController.h"
#import "SYNChannelCoverImageCell.h"
#import "SYNChannelCoverImageSelectorViewController.h"
#import "SYNCoverChooserController.h"
#import "SYNCoverThumbnailCell.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNPopoverBackgroundView.h"
#import "UIImageView+WebCache.h"


@interface SYNCoverChooserController () 

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSFetchedResultsController *channelCoverFetchedResultsController;
@property (nonatomic, strong) NSIndexPath* indexPathSelected;
@property (nonatomic, strong) NSString* selectedImageURL;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;

@end


@implementation SYNCoverChooserController

- (id) initWithSelectedImageURL: (NSString *) selectedImageURL
{
    if ((self = [super init]))
    {
        self.appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        self.selectedImageURL = selectedImageURL;
    }
    
    return self;
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Regster video thumbnail cell
    UINib *coverThumbnailCellNib = [UINib nibWithNibName: @"SYNCoverThumbnailCell"
                                                  bundle: nil];
    
    [self.collectionView registerNib: coverThumbnailCellNib
          forCellWithReuseIdentifier: @"SYNCoverThumbnailCell"];
}


#pragma mark - Delegate

- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger) section
{
    
    id <NSFetchedResultsSectionInfo> sectionInfo;

    switch (section)
    {     
        case 0:
        {
            return 1;
        }
            
        case 1:
        {
            // Rockpack channel covers
            if (self.channelCoverFetchedResultsController.sections.count > 1)
            {
                sectionInfo = self.channelCoverFetchedResultsController.sections [1];
                return sectionInfo.numberOfObjects;
            }
            return 0;
        }
        break;
            
        case 2:
        {
            // User channel covers
            if (self.channelCoverFetchedResultsController.sections.count > 0)
            {
                sectionInfo = self.channelCoverFetchedResultsController.sections [0];
                return sectionInfo.numberOfObjects;
            }
            return 0;
            
        }
        break;       
    }
    
    return 0;
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 3;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    CoverArt *coverArt = nil;
    
    SYNCoverThumbnailCell *coverThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNCoverThumbnailCell"
                                                                                          forIndexPath: indexPath];
    switch (indexPath.section)
    {
        case 0:
        {
            coverThumbnailCell.coverImageView.image = [UIImage imageNamed: @"ChannelCreationCoverNone.png"];
        }
        break;
            
        case 1:
        {
            // Rockpack channel covers
            coverArt = [self.channelCoverFetchedResultsController objectAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row
                                                                                                                  inSection: 1]];
            
            [coverThumbnailCell.coverImageView setImageWithURL: [NSURL URLWithString: coverArt.thumbnailURL]
                                              placeholderImage: [UIImage imageNamed: @"PlaceholderChannelCreation.png"]
                                                       options: SDWebImageRetryFailed];
        }
        break;
            
        case 2:
        {
            // User channel covers
            coverArt = [self.channelCoverFetchedResultsController objectAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row
                                                                                                                      inSection: 0]];
            
            [coverThumbnailCell.coverImageView setImageWithURL: [NSURL URLWithString: coverArt.thumbnailURL]
                                              placeholderImage: [UIImage imageNamed: @"PlaceholderChannelCreation.png"]
                                                       options: SDWebImageRetryFailed];
        }
        break;      
    }
    
    // If the user hasn't actually selected a cover, then try to match the cover id with the one for our cell,
    // and select if true
    if (self.indexPathSelected == nil)
    {
        // And we are not on the 'no cover' placeholder
        if (coverArt != nil)
        {
            if ([coverArt.thumbnailURL isEqualToString: self.selectedImageURL])
            {
                coverThumbnailCell.selected = TRUE;
            }
        }
    }
    
    return coverThumbnailCell;
}


- (void) collectionView: (UICollectionView *) collectionView
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    self.indexPathSelected = indexPath;
    
    [self.collectionView scrollToItemAtIndexPath: indexPath
                                atScrollPosition: UICollectionViewScrollPositionNone
                                        animated: YES];
    NSString *imageURLString;
    NSString *remoteId;
    
    // There are two sections for cover thumbnails, the first represents 'no cover' the second contains all images
    switch (indexPath.section)
    {
        case 0:
        {
            imageURLString = @"";
            remoteId = @"";
        }
        break;
            
        case 1:
        {
            // Rockpack channel covers
            CoverArt *coverArt = [self.channelCoverFetchedResultsController objectAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row
                                                                                                                  inSection: 1]];
            imageURLString = coverArt.thumbnailURL;
            remoteId = coverArt.coverRef;
        }
            break;
            
        case 2:
        {
            // User channel covers
            CoverArt *coverArt = [self.channelCoverFetchedResultsController objectAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row
                                                                                                                  inSection: 0]];
            imageURLString = coverArt.thumbnailURL;
            remoteId = coverArt.coverRef;
        }
        break;  
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kCoverArtChanged
                                                        object: self
                                                      userInfo: @{kCoverArt:imageURLString , kCoverImageReference:remoteId}];
}


#pragma mark - Fetched Results Controller

- (NSFetchedResultsController *) channelCoverFetchedResultsController
{
    if (_channelCoverFetchedResultsController)
        return _channelCoverFetchedResultsController;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    
    fetchRequest.entity = [NSEntityDescription entityForName: @"CoverArt"
                                      inManagedObjectContext: self.appDelegate.mainManagedObjectContext];
    
    
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"userUpload" ascending: YES],
                                     [[NSSortDescriptor alloc] initWithKey: @"position" ascending: YES]];
    
    self.channelCoverFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                                    managedObjectContext: self.appDelegate.mainManagedObjectContext
                                                                                      sectionNameKeyPath: @"userUpload"
                                                                                               cacheName: nil];

    self.channelCoverFetchedResultsController.delegate = self;
    
    
    NSError *error = nil;
    
    ZAssert([_channelCoverFetchedResultsController performFetch: &error], @"Channels Details Failed: %@\n%@", [error localizedDescription], [error userInfo]);
    
    return _channelCoverFetchedResultsController;
}


- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{
    [self.collectionView reloadData];

}


- (void) updateCoverArt
{
    // Update the list of cover art
    [self.appDelegate.networkEngine updateCoverArtOnCompletion: ^{
        DebugLog(@"Success");
    } onError: ^(NSError* error) {
        DebugLog(@"%@", [error debugDescription]);
    }];
    
    [self.appDelegate.oAuthNetworkEngine updateCoverArtForUserId: self.appDelegate.currentOAuth2Credentials.userId
                                               onCompletion: ^{
                                                   DebugLog(@"Success");
                                               }
                                                    onError: ^(NSError* error) {
                                                        DebugLog(@"%@", [error debugDescription]);
                                                    }];
}


#pragma mark - Autorotate Support

- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    [super willAnimateRotationToInterfaceOrientation: toInterfaceOrientation
                                            duration: duration];
    
    [self.collectionView scrollToItemAtIndexPath: self.indexPathSelected
                                atScrollPosition: UICollectionViewScrollPositionNone
                                        animated: YES];
}

#pragma mark - Paging control

- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    DebugLog (@"Scrolling");
    // when reaching far right hand side, load a new page
    if (scrollView.contentOffset.x == scrollView.contentSize.width - scrollView.bounds.size.width)
    {
            DebugLog (@"Scrolling more");
//        // ask next page only if we haven't reached last page
//        if(![self.flickrPaginator reachedLastPage])
//        {
//            // fetch next page of results
//            [self fetchNextPage];
//        }
    }
}



@end
