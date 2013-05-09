//
//  SYNSearchRootViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 27/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "Channel.h"
#import "ChannelOwner.h"
#import "NSDate-Utilities.h"
#import "SYNAppDelegate.h"
#import "SYNDeviceManager.h"
#import "SYNSearchRootViewController.h"
#import "SYNSearchTabView.h"
#import "SYNSearchVideosViewController.h"
#import "SYNVideoThumbnailWideCell.h"
#import "UIImageView+WebCache.h"
#import "Video.h"
#import "VideoInstance.h"

@interface SYNSearchVideosViewController ()

@end

@implementation SYNSearchVideosViewController

@synthesize itemToUpdate;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    self.trackedViewName = @"Search - Videos";
    
    // override the data loading
    
    CGRect collectionFrame = self.videoThumbnailCollectionView.frame;
    collectionFrame.origin.y += 60.0;
    collectionFrame.size.width = [[SYNDeviceManager sharedInstance] currentScreenWidth];
    collectionFrame.size.height = [[SYNDeviceManager sharedInstance] currentScreenHeight] - 190.0;
    self.videoThumbnailCollectionView.frame = collectionFrame;
    
    self.videoThumbnailCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight;
    self.videoThumbnailCollectionView.backgroundColor = [UIColor clearColor];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}


- (NSFetchedResultsController *)fetchedResultsController
{
    
    if (fetchedResultsController != nil)
        return fetchedResultsController;
        
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    
    fetchRequest.entity = [NSEntityDescription entityForName: @"VideoInstance"
                                      inManagedObjectContext: appDelegate.searchManagedObjectContext];
    
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"viewId == \"%@\"", viewId]];
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"position" ascending: YES]];
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                        managedObjectContext: appDelegate.searchManagedObjectContext
                                                                          sectionNameKeyPath: nil
                                                                                   cacheName: nil];
    fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    
    ZAssert([fetchedResultsController performFetch: &error],
            @"Search Videos Fetch Request Failed: %@\n%@", [error localizedDescription], [error userInfo]);
    
    return fetchedResultsController;
    
    
}


-(void)performSearchWithTerm:(NSString*)term
{
    
    appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];

    [appDelegate.networkEngine searchVideosForTerm:term];
    
    
}



- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{

    DebugLog(@"Total Search Items: %i", controller.fetchedObjects.count);
    
    if(self.itemToUpdate)
        [self.itemToUpdate setNumberOfItems:[controller.fetchedObjects count] animated:YES];
    
    
    [self reloadCollectionViews];
    
}


#pragma mark - Collection View Delegate

- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    UICollectionViewCell *cell = nil;
    
    if (cv == self.videoThumbnailCollectionView)
    {
        // No, but it was our collection view
        VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
        
        SYNVideoThumbnailWideCell *videoThumbnailCell = [cv dequeueReusableCellWithReuseIdentifier: @"SYNVideoThumbnailWideCell"
                                                                                      forIndexPath: indexPath];
        
        
        videoThumbnailCell.displayMode = kVideoThumbnailDisplayModeYoutube;
        
        [videoThumbnailCell.videoImageView setImageWithURL: [NSURL URLWithString: videoInstance.video.thumbnailURL]
                                          placeholderImage: [UIImage imageNamed: @"PlaceholderVideoThumbnailWide.png"]];

        videoThumbnailCell.videoTitle.text = videoInstance.title;
        videoThumbnailCell.videoInstance = videoInstance;
        
        Video* video = videoInstance.video;
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSString* viewsNumberString = [numberFormatter stringFromNumber:video.viewCount];
        
        videoThumbnailCell.numberOfViewLabel.text = [[NSString stringWithFormat:@"%@ views", viewsNumberString] uppercaseString];
        
        
        NSCalendar* currentCalendar = [NSCalendar currentCalendar];
        NSDateComponents* differenceDateComponents = [currentCalendar components:(NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:video.dateUploaded toDate:[NSDate date] options:0];
        
        NSMutableString* format = [[NSMutableString alloc] init];
        if(differenceDateComponents.year > 0)
            [format appendFormat:@"%i Year%@ Ago", differenceDateComponents.year, (differenceDateComponents.year > 1 ? @"s" : @"")];
        else if(differenceDateComponents.month > 0)
            [format appendFormat:@"%i Month%@ Ago", differenceDateComponents.month, (differenceDateComponents.month > 1 ? @"s" : @"")];
        else if(differenceDateComponents.day > 1)
            [format appendFormat:@"%i Days Ago", differenceDateComponents.day];
        else if(differenceDateComponents.day > 0)
            [format appendString:@"Yesterday"];
        else
            [format appendString:@"Today"];
        

        videoThumbnailCell.dateAddedLabel.text = [format uppercaseString];
        
        NSUInteger minutes = ([video.duration integerValue] / 60) % 60;
        NSUInteger seconds = [video.duration integerValue] % 60;
        videoThumbnailCell.usernameText = [NSString stringWithFormat:@"%i:%i", minutes, seconds];
        

        videoThumbnailCell.viewControllerDelegate = self;
        
        cell = videoThumbnailCell;
    }
    
    return cell;
}


#pragma mark - Override Header Related Methods

- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout*) collectionViewLayout referenceSizeForHeaderInSection: (NSInteger) section
{
    return CGSizeZero;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if([[SYNDeviceManager sharedInstance]isIPad])
    {
        if([[SYNDeviceManager sharedInstance] isLandscape])
        {
            return CGSizeMake(497, 140);
        }
        else
        {
            return CGSizeMake(370, 140);
        }
    }
    else
    {
        return CGSizeMake(310,221);
    }
}


// Used for the collection view header
- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath {
    return nil;
    
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self reloadCollectionViews];
}

@end
