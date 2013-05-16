//
//  SYNCoverChooserController.m
//  rockpack
//
//  Created by Michael Michailidis on 14/05/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCoverChooserController.h"
#import "SYNChannelCoverImageCell.h"
#import "SYNCoverThumbnailCell.h"
#import "CoverArt.h"
#import "AppConstants.h"
#import "Channel.h"
#import "ChannelCover.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "SYNAppDelegate.h"
#import "SYNPopoverBackgroundView.h"
#import "SYNCameraPopoverViewController.h"
#import "GKImagePicker.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNNetworkEngine.h"
#import "SYNChannelCoverImageSelectorViewController.h"

@interface SYNCoverChooserController () 


@property (nonatomic, strong) NSFetchedResultsController *channelCoverFetchedResultsController;

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;



@property (nonatomic, weak) SYNAppDelegate* appDelegate;


@end

@implementation SYNCoverChooserController

@synthesize appDelegate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)viewDidLoad
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
            if(self.channelCoverFetchedResultsController.sections.count > 0)
            {
                sectionInfo = self.channelCoverFetchedResultsController.sections [0];
                return sectionInfo.numberOfObjects;
            }
            return 0;
            
        }
        break;
            
        case 2:
        {
            if(self.channelCoverFetchedResultsController.sections.count > 1)
            {
                sectionInfo = self.channelCoverFetchedResultsController.sections [1];
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
    SYNCoverThumbnailCell *coverThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNCoverThumbnailCell"
                                                                                          forIndexPath: indexPath];
        switch (indexPath.section)
    {
        case 0:
        {
            coverThumbnailCell.coverImageView.image = [UIImage imageNamed: @"ChannelCreationCoverNone.png"];
            return coverThumbnailCell;
        }
        break;
            
        case 1:
        {
            // User channel covers
            CoverArt *coverArt = [self.channelCoverFetchedResultsController objectAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row
                                                                                                                      inSection: 0]];
            
            [coverThumbnailCell.coverImageView setImageWithURL: [NSURL URLWithString: coverArt.thumbnailURL]
                                              placeholderImage: [UIImage imageNamed: @"PlaceholderChannelCoverThumbnail.png"]
                                                       options: SDWebImageRetryFailed];
            return coverThumbnailCell;
        }
        break;
            
        case 2:
        {
            // Rockpack channel covers
            CoverArt *coverArt = [self.channelCoverFetchedResultsController objectAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row
                                                                                                                  inSection: 1]];
            
            [coverThumbnailCell.coverImageView setImageWithURL: [NSURL URLWithString: coverArt.thumbnailURL]
                                              placeholderImage: [UIImage imageNamed: @"PlaceholderChannelCoverThumbnail.png"]
                                                       options: SDWebImageRetryFailed];
            return coverThumbnailCell;
        }
        break;
            
    }
    
    return nil;
   
}


- (void) collectionView: (UICollectionView *) collectionView
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    [self.collectionView scrollToItemAtIndexPath: indexPath
                                atScrollPosition: UICollectionViewScrollPositionNone
                                        animated: YES];
    
    NSString *imageURLString;
    
    // There are two sections for cover thumbnails, the first represents 'no cover' the second contains all images
    switch (indexPath.section)
    {
        case 0:
        {
            imageURLString = @"";
        }
        break;
            
        case 1:
        {
            // User channel covers
            CoverArt *coverArt = [self.channelCoverFetchedResultsController objectAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row
                                                                                                                  inSection: 0]];
            imageURLString = coverArt.thumbnailURL;
        }
        break;
            
        case 2:
        {
            // Rockpack channel covers
            CoverArt *coverArt = [self.channelCoverFetchedResultsController objectAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row
                                                                                                                  inSection: 1]];
            imageURLString = coverArt.thumbnailURL;
        }
        break;
            
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kCoverArtChanged
                                                        object:self
                                                      userInfo:@{kCoverArt:imageURLString}];
    
 
}


#pragma mark - Fetched Results Controller

- (NSFetchedResultsController *) channelCoverFetchedResultsController
{
    if (_channelCoverFetchedResultsController)
        return _channelCoverFetchedResultsController;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    
    fetchRequest.entity = [NSEntityDescription entityForName: @"CoverArt"
                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"position" ascending: YES],
                                     [[NSSortDescriptor alloc] initWithKey: @"ordering" ascending: YES]];
    
    self.channelCoverFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                                    managedObjectContext: appDelegate.mainManagedObjectContext
                                                                                      sectionNameKeyPath: @"ordering"
                                                                                               cacheName: nil];

    self.channelCoverFetchedResultsController.delegate = self;
    
    
    NSError *error = nil;
    
    ZAssert([_channelCoverFetchedResultsController performFetch: &error], @"Channels Details Failed: %@\n%@", [error localizedDescription], [error userInfo]);
    
    return _channelCoverFetchedResultsController;
}


- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{
    [self.collectionView reloadData];

    //[self.coverImageSelector refreshChannelCoverData];

}


- (void) updateCoverArt
{
    // Update the list of cover art
    [appDelegate.networkEngine updateCoverArtOnCompletion: ^{
        DebugLog(@"Success");
    } onError: ^(NSError* error) {
        DebugLog(@"%@", [error debugDescription]);
    }];
    
    [appDelegate.oAuthNetworkEngine updateCoverArtForUserId: appDelegate.currentOAuth2Credentials.userId
                                               onCompletion: ^{
                                                   DebugLog(@"Success");
                                               }
                                                    onError: ^(NSError* error) {
                                                        DebugLog(@"%@", [error debugDescription]);
                                                    }];
}






@end
