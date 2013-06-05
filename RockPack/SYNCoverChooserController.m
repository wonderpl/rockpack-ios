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
#import "SYNCoverRightMoreView.h"
#import "SYNCoverThumbnailCell.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNPopoverBackgroundView.h"
#import "UIImageView+WebCache.h"


@interface SYNCoverChooserController () 

@property (nonatomic, assign) BOOL shouldReloadCollectionView;
@property (nonatomic, assign) BOOL shouldShowUploadingPlaceholder;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSBlockOperation *blockOperation;
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, strong) NSFetchedResultsController *channelCoverFetchedResultsController;
@property (nonatomic, strong) NSIndexPath* indexPathSelected;
@property (nonatomic, strong) NSString* selectedImageURL;
@property (nonatomic, strong) SYNCoverRightMoreView* coverRightMoreView;
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
    
    // Register Footer
    UINib *moreViewNib = [UINib nibWithNibName: @"SYNCoverRightMoreView"
                                        bundle: nil];
    
    [self.collectionView registerNib: moreViewNib
          forSupplementaryViewOfKind: UICollectionElementKindSectionFooter
                 withReuseIdentifier: @"SYNCoverRightMoreView"];
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
            if (self.shouldShowUploadingPlaceholder)
            {
                return 1;
            }
            else
            {
                // User channel covers
                if (self.channelCoverFetchedResultsController.sections.count > 1)
                {
                    sectionInfo = self.channelCoverFetchedResultsController.sections [0];
                    return sectionInfo.numberOfObjects;
                }
            }
            return 0;
            
        }
        break;
            
        case 2:
        {
            // Rockpack channel covers
            if (self.channelCoverFetchedResultsController.sections.count > 1)
            {
                sectionInfo = self.channelCoverFetchedResultsController.sections [1];
                return sectionInfo.numberOfObjects;
            }
            else
            {
                if (self.channelCoverFetchedResultsController.sections.count > 0)
                {
                    sectionInfo = self.channelCoverFetchedResultsController.sections [0];
                    return sectionInfo.numberOfObjects;
                }
                else
                {
                    return 0;
                }
            }
        }
        break;
   
    }
    
    return 0;
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 3;
}

- (int) adjustedIndex
{
    int index = 0;
    
    if (self.channelCoverFetchedResultsController.sections.count > 1)
    {
        index = 1;
    }
    
    return index;
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
            if (self.shouldShowUploadingPlaceholder)
            {
                coverThumbnailCell.coverImageView.image = self.placeholderImage;
            }
            else
            {
                
                // Rockpack channel covers
                coverArt = [self.channelCoverFetchedResultsController objectAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row
                                                                                                            inSection: 0]];
                
                [coverThumbnailCell.coverImageView setImageWithURL: [NSURL URLWithString: coverArt.thumbnailURL]
                                                  placeholderImage: [UIImage imageNamed: @"PlaceholderChannelCreation.png"]
                                                           options: SDWebImageRetryFailed];
            }
        }
        break;
            
        case 2:
        {
            // User channel covers
            coverArt = [self.channelCoverFetchedResultsController objectAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row
                                                                                                        inSection: self.adjustedIndex]];
            
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
                self.indexPathSelected = indexPath;
            }
        }
    }
    
    return coverThumbnailCell;
}


- (void) collectionView: (UICollectionView *) collectionView
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    // check to see that this is not our currently selected indexPath
    if (![self.indexPathSelected isEqual: indexPath])
    {
        NSIndexPath *previouslySelectedIndexPath = self.indexPathSelected;
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
                if (self.shouldShowUploadingPlaceholder)
                {
                    imageURLString = @"uploading";
                    remoteId = @"";
                }
                else
                {
                    // Rockpack channel covers
                    CoverArt *coverArt = [self.channelCoverFetchedResultsController objectAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row
                                                                                                                          inSection: 0]];
                    imageURLString = coverArt.thumbnailURL;
                    remoteId = coverArt.coverRef;
                }
            }
                break;
                
            case 2:
            {
                // User channel covers
                CoverArt *coverArt = [self.channelCoverFetchedResultsController objectAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row
                                                                                                                      inSection: self.adjustedIndex]];
                imageURLString = coverArt.thumbnailURL;
                remoteId = coverArt.coverRef;
            }
            break;  
        }
        
        NSDictionary *userInfo = (self.placeholderImage) ?  @{kCoverArt: imageURLString ,
                                                              kCoverImageReference: remoteId,
                                                              kCoverArtImage: self.placeholderImage}
                                                         :  @{kCoverArt: imageURLString ,
                                                              kCoverImageReference: remoteId};
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kCoverArtChanged
                                                            object: self
                                                          userInfo: userInfo];
        
        if (previouslySelectedIndexPath)
        {
            [collectionView reloadItemsAtIndexPaths: @[previouslySelectedIndexPath]];
        }
    }
}


#pragma mark - Fetched Results Controller

- (NSFetchedResultsController *) channelCoverFetchedResultsController
{
    if (_channelCoverFetchedResultsController)
        return _channelCoverFetchedResultsController;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    
    fetchRequest.entity = [NSEntityDescription entityForName: @"CoverArt"
                                      inManagedObjectContext: self.appDelegate.mainManagedObjectContext];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat: @"(userUpload == FALSE) OR (thumbnailURL == %@)", self.selectedImageURL];
    
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"userUpload" ascending: NO],
                                     [[NSSortDescriptor alloc] initWithKey: @"position" ascending: YES]];
    
    self.channelCoverFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                                    managedObjectContext: self.appDelegate.mainManagedObjectContext
                                                                                      sectionNameKeyPath: @"userUpload"
                                                                                               cacheName: nil];

    self.channelCoverFetchedResultsController.delegate = self;
    
    
    NSError *error = nil;
    
    if (![_channelCoverFetchedResultsController performFetch: &error])
    {
        AssertOrLog(@"Channels Details Failed: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    return _channelCoverFetchedResultsController;
}


#pragma mark - Supplementary views

- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
    UICollectionReusableView* supplementaryView;
    
    if (collectionView != self.collectionView)
        return nil;

    if (kind == UICollectionElementKindSectionFooter && indexPath.section == 2)
    {        
        self.coverRightMoreView = [self.collectionView dequeueReusableSupplementaryViewOfKind: kind
                                                                          withReuseIdentifier: @"SYNCoverRightMoreView"
                                                                                 forIndexPath: indexPath];
        
        supplementaryView = self.coverRightMoreView;
    }
    
    return supplementaryView;
}


- (CGSize) collectionView: (UICollectionView *) collectionView
           layout: (UICollectionViewLayout*) collectionViewLayout
           referenceSizeForFooterInSection: (NSInteger) section
{
    if (section == 2)
    {
        return CGSizeMake(141.0f, 121.0f);
    }
    else
    {
        return CGSizeZero;
    }
}


- (void) updateCoverArt
{
    // Update the list of cover art
    [self.appDelegate.networkEngine updateCoverArtWithWithStart: 0
                                                           size: 50
                                              completionHandler: ^(NSDictionary *dictionary){
                                                  DebugLog(@"Success");
                                              }
                                                   errorHandler: ^(NSError* error) {
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

- (void) createCoverPlaceholder: (UIImage *) image
{
    self.placeholderImage = image;
    self.shouldShowUploadingPlaceholder = TRUE;
    [self.collectionView reloadData];
    
    SYNCoverThumbnailCell *coverThumbnailCell = (SYNCoverThumbnailCell *)[self.collectionView cellForItemAtIndexPath: [NSIndexPath indexPathForItem: 0 inSection: 1]];
    
    coverThumbnailCell.selected = TRUE;                                             
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
        
        self.coverRightMoreView.loadingLabel.text = NSLocalizedString(@"Loading", nil);
        [self.coverRightMoreView.loadingIndicatorView startAnimating];
        
    }
}


- (void) loadMoreChannels: (UIButton*) sender
{
    // (UIButton*) sender can be nil when called directly //
    if (self.coverRightMoreView.loadingIndicatorView.isAnimating == YES)
    {
        
    }
//    
//    NSInteger nextStart = dataRequestRange.location + dataRequestRange.length; // one is subtracted when the call happens for 0 indexing
//    
//    if(nextStart >= dataItemsAvailable)
//        return;
//    
//    NSInteger nextSize = (nextStart + STANDARD_REQUEST_LENGTH) >= dataItemsAvailable ? (dataItemsAvailable - nextStart) : STANDARD_REQUEST_LENGTH;
//    
//    dataRequestRange = NSMakeRange(nextStart, nextSize);
//    
//    [self loadChannelsForGenre: currentGenre
//                   byAppending: YES];
}


// Old blunderbuss way of doing things
- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{
    [self.collectionView reloadData];
}


@end
