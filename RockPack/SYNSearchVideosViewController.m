//
//  SYNSearchRootViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 27/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchVideosViewController.h"
#import "SYNAppDelegate.h"
#import "SYNSearchItemView.h"
#import "SYNSearchRootViewController.h"
#import "SYNVideoThumbnailWideCell.h"
#import "VideoInstance.h"
#import "Video.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "NSDate-Utilities.h"

@interface SYNSearchVideosViewController ()


@end



@implementation SYNSearchVideosViewController

@synthesize itemToUpdate;


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
    
//    if(self.itemToUpdate)
//        [self.itemToUpdate hideItem];
    
    [appDelegate.networkEngine searchVideosForTerm:term];
    
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow: 0 inSection: 0];
    
    self.currentIndexPath = firstIndexPath;
    
    
}



- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{

    
    if(self.itemToUpdate)
        [self.itemToUpdate setNumberOfItems:[controller.fetchedObjects count] animated:YES];
    
    [self reloadCollectionViews];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // override the data loading
    
    self.videoThumbnailCollectionView.center = CGPointMake(self.videoThumbnailCollectionView.center.x,
                                                           self.videoThumbnailCollectionView.center.y + 30.0);
    
    self.largeVideoPanelView.center = CGPointMake(self.largeVideoPanelView.center.x,
                                                  self.largeVideoPanelView.center.y + 30.0);
}

-(void)viewDidAppear:(BOOL)animated
{
    //override with empty function
}

-(void)viewWillAppear:(BOOL)animated
{
    // override with empty function
}


#pragma mark - Navigation Controller

- (void) animatedPushViewController: (UIViewController *) vc
{
    [self.parent animatedPushViewController:vc];
}


- (void) animatedPopViewController
{
    [self.parent animatedPopViewController];
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
        
        
        videoThumbnailCell.displayMode = kDisplayModeYoutube;
        videoThumbnailCell.videoImageViewImage = videoInstance.video.thumbnailURL;
        videoThumbnailCell.videoTitle.text = videoInstance.title;
        
        Video* video = videoInstance.video;
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSString* viewsNumberString = [numberFormatter stringFromNumber:video.viewCount];
        
        videoThumbnailCell.numberOfViewLabel.text = [NSString stringWithFormat:@"%@ views", viewsNumberString];
        
        
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
        
        
        
        videoThumbnailCell.dateAddedLabel.text = format;
        
        NSUInteger minutes = ([video.duration integerValue] / 60) % 60;
        NSUInteger seconds = [video.duration integerValue] % 60;
        videoThumbnailCell.durationLabel.text = [NSString stringWithFormat:@"%i:%i", minutes, seconds];
        
        videoThumbnailCell.starNumber.text = [NSString stringWithFormat: @"%@", videoInstance.video.starCount];

        videoThumbnailCell.viewControllerDelegate = self;
        
        cell = videoThumbnailCell;
    }
    
    return cell;
}

@end
