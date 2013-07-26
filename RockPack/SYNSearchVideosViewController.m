//
//  SYNSearchRootViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 27/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "Channel.h"
#import "ChannelOwner.h"
#import "GAI.h"
#import "MKNetworkOperation.h"
#import "NSDate-Utilities.h"
#import "SYNAppDelegate.h"
#import "SYNDeviceManager.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNSearchRootViewController.h"
#import "SYNSearchTabView.h"
#import "SYNSearchVideosViewController.h"
#import "SYNVideoThumbnailWideCell.h"
#import "UIImageView+WebCache.h"
#import "Video.h"
#import "VideoInstance.h"

@interface SYNSearchVideosViewController ()

@property (nonatomic, assign) BOOL isIPhone;
@property (nonatomic, strong) NSCalendar* currentCalendar;
@property (nonatomic, weak) MKNetworkOperation* runningSearchOperation;
@property (nonatomic, weak) NSString* searchTerm;

@end


@implementation SYNSearchVideosViewController

// FIXME: NOT QUITE SURE WHY THESE ARE REQUIRED
@synthesize dataRequestRange;

- (void) viewDidLoad
{
    [super viewDidLoad];

    self.isIPhone = IS_IPHONE;
    
    if (self.isIPhone)
    {
        CGRect collectionFrame = self.videoThumbnailCollectionView.frame;
        collectionFrame.origin.y += 40.0;
        collectionFrame.size.width = [SYNDeviceManager.sharedInstance currentScreenWidth];
        collectionFrame.size.height = [SYNDeviceManager.sharedInstance currentScreenHeight] - 190.0;
        self.videoThumbnailCollectionView.frame = collectionFrame;
    }
    else
    {
        CGRect collectionFrame = self.videoThumbnailCollectionView.frame;
        collectionFrame.origin.y += 54.0;
        collectionFrame.size.width = self.view.frame.size.width;
        collectionFrame.size.height = self.view.frame.size.height - 150.0;
        self.videoThumbnailCollectionView.frame = collectionFrame;
        UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)self.videoThumbnailCollectionView.collectionViewLayout;
        UIEdgeInsets insets= layout.sectionInset;
        insets.top = 0.0f;
        insets.bottom = 15.0f;
        layout.sectionInset = insets;
    }
    
    CGRect videoThumbFrame = self.videoThumbnailCollectionView.frame;
    videoThumbFrame.size.height -= 4.0;
    self.videoThumbnailCollectionView.frame = videoThumbFrame;
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.currentCalendar = [NSCalendar currentCalendar];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.fetchBatchSize = 20;
    fetchRequest.entity = [NSEntityDescription entityForName: @"VideoInstance"
                                     inManagedObjectContext: self.appDelegate.searchManagedObjectContext];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"viewId == %@", self.viewId]];
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"position" ascending: YES]];
    self.fetchRequest = fetchRequest;
    
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];

    [super removeEmptyGenreMessage];
}


//- (NSFetchedResultsController *) fetchedResultsController
//{
//    if (fetchedResultsController != nil)
//        return fetchedResultsController;
//        
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    
//    fetchRequest.fetchBatchSize = 20;
//    fetchRequest.entity = [NSEntityDescription entityForName: @"VideoInstance"
//                                      inManagedObjectContext: self.appDelegate.searchManagedObjectContext];
//    
//    
//    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"viewId == %@", self.viewId]];
//    
//    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"position" ascending: YES]];
//    
//    
//    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
//                                                                        managedObjectContext: appDelegate.searchManagedObjectContext
//                                                                          sectionNameKeyPath: nil
//                                                                                   cacheName: nil];
//    fetchedResultsController.delegate = self;
//    
//    
//    
//    NSError *error = nil;    
//    if (![fetchedResultsController performFetch: &error])
//    {
//        AssertOrLog(@"Search Videos Fetch Request Failed: %@\n%@", [error localizedDescription], [error userInfo]);
//    }
//    
//    return fetchedResultsController; 
//}


- (void) performNewSearchWithTerm: (NSString*) term
{
    
    if (!appDelegate)
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    self.dataRequestRange = NSMakeRange(0, kAPIInitialBatchSize);
    
    [super displayEmptyGenreMessage:NSLocalizedString(@"search_screen_searching_videos", nil)
                          andLoader:NO];

    self.runningSearchOperation =  [self.appDelegate.networkEngine searchVideosForTerm: term
                                                                               inRange: self.dataRequestRange
                                                                            onComplete: ^(int itemsCount) {
                                                                                self.dataItemsAvailable = itemsCount;
                                                                                if(self.itemToUpdate)
                                                                                    [self.itemToUpdate setNumberOfItems: self.dataItemsAvailable
                                                                                                               animated: YES];
                                                                                
                                                                                [super removeEmptyGenreMessage];
                                                                                if(itemsCount == 0)
                                                                                    [super displayEmptyGenreMessage:NSLocalizedString(@"search_screen_no_videos", nil)
                                                                                                          andLoader:NO];
                                                                                self.resultArray = [appDelegate.searchManagedObjectContext executeFetchRequest:self.fetchRequest error:nil];
                                                                                [self reloadCollectionViews];
                                                                            }];
    self.searchTerm = term;
}


- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{
//    DebugLog(@"Total Search Items: %i", controller.fetchedObjects.count);
    
    [self.videoThumbnailCollectionView reloadData];
}


#pragma mark - Collection View Delegate

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (NSInteger) collectionView: (UICollectionView *) collectionView numberOfItemsInSection: (NSInteger) section
{
    return [self.resultArray count];
    
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    VideoInstance *videoInstance = self.resultArray[indexPath.row];
    
    SYNVideoThumbnailWideCell *videoThumbnailCell = [cv dequeueReusableCellWithReuseIdentifier: @"SYNVideoThumbnailWideCell"
                                                                                  forIndexPath: indexPath];
    
    videoThumbnailCell.displayMode = kVideoThumbnailDisplayModeYoutube;
    
    [videoThumbnailCell.videoImageView setImageWithURL: [NSURL URLWithString: videoInstance.video.thumbnailURL]
                                      placeholderImage: [UIImage imageNamed: @"PlaceholderVideoWide.png"]];
    
    videoThumbnailCell.videoTitle.text = videoInstance.title;
    videoThumbnailCell.videoInstance = videoInstance;
    
    Video* video = videoInstance.video;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString* viewsNumberString = [numberFormatter stringFromNumber:video.viewCount];
    
    videoThumbnailCell.numberOfViewLabel.text = [[NSString stringWithFormat:@"%@ views", viewsNumberString] uppercaseString];
    
    
    NSDateComponents* differenceDateComponents = [self.currentCalendar components:(NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:video.dateUploaded toDate:[NSDate date] options:0];
    
    NSMutableString* format = [[NSMutableString alloc] init];
    
    
    if (differenceDateComponents.year > 0)
        [format appendFormat:@"%i Year%@ Ago", differenceDateComponents.year, (differenceDateComponents.year > 1 ? @"s" : @"")];
    else if (differenceDateComponents.month > 0)
        [format appendFormat:@"%i Month%@ Ago", differenceDateComponents.month, (differenceDateComponents.month > 1 ? @"s" : @"")];
    else if (differenceDateComponents.day > 1)
        [format appendFormat:@"%i %@", differenceDateComponents.day, NSLocalizedString(@"Days Ago", nil)];
    else if (differenceDateComponents.day > 0)
        [format appendString: NSLocalizedString(@"Yesterday", nil)];
    else
        [format appendString: NSLocalizedString(@"Today", nil)];
    
    if (self.isIPhone)
    {
        //On iPhone, append You Tube User name to the date label
        videoThumbnailCell.dateAddedLabel.text = [NSString stringWithFormat:@"%@ BY %@",[format uppercaseString], [video.sourceUsername uppercaseString]];
    }
    else
    {
        //On iPad a separate label is used for the youtube user name
        videoThumbnailCell.dateAddedLabel.text = [format uppercaseString];
        videoThumbnailCell.youTubeUserLabel.text = [NSString stringWithFormat:@"BY %@",[video.sourceUsername uppercaseString]];
    }
    
    NSUInteger hours = video.duration.integerValue / (60*60);
    NSUInteger minutes = ([video.duration integerValue] / 60) % 60;
    NSUInteger seconds = [video.duration integerValue] % 60;
    
    
    NSString* hoursString = [NSString stringWithFormat:@"%i", hours];
    NSString* minutesString = minutes > 9 ? [NSString stringWithFormat:@"%i", minutes] : [NSString stringWithFormat:@"0%i", minutes];
    NSString* secondsString = seconds > 9 ? [NSString stringWithFormat:@"%i", seconds] : [NSString stringWithFormat:@"0%i", seconds];
    if(hours > 0)
    {
        videoThumbnailCell.durationLabel.text = [NSString stringWithFormat: @"%@:%@:%@", hoursString, minutesString, secondsString];
    }
    else
    {
        videoThumbnailCell.durationLabel.text = [NSString stringWithFormat: @"%@:%@", minutesString, secondsString];
    }
    
    
    
    videoThumbnailCell.viewControllerDelegate = self;
    
    videoThumbnailCell.addItButton.highlighted = NO;
    videoThumbnailCell.addItButton.selected = [appDelegate.videoQueue videoInstanceIsAddedToChannel:videoInstance];
    
    
    if ((!self.isIPhone && indexPath.item == 2) ||
       (self.isIPhone && indexPath.item == 0)) {
        //perform after 0.0f delay to make sure the call is queued after the cell has been added to the view
        [self performSelector:@selector(showVideoOnboardingForCell:) withObject:videoThumbnailCell afterDelay:0.0f];
    }
    
    return videoThumbnailCell;
}


#pragma mark - Override Header Related Methods

- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout*) collectionViewLayout referenceSizeForHeaderInSection: (NSInteger) section
{
    return CGSizeZero;
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPAD)
    {
        if([SYNDeviceManager.sharedInstance isLandscape])
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


- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    [super willAnimateRotationToInterfaceOrientation: toInterfaceOrientation
                                            duration: duration];
    
}


- (void) didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation: fromInterfaceOrientation];
    
}


- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                 duration: (NSTimeInterval) duration
{
    [super willRotateToInterfaceOrientation: toInterfaceOrientation
                                   duration: duration];
    [self reloadCollectionViews];
}


- (void) loadMoreVideos
{
    if (self.moreItemsToLoad == TRUE)
    {
        [self incrementRangeForNextRequest];
        
        __weak typeof(self) weakSelf = self;
        
        [appDelegate.networkEngine searchVideosForTerm: self.searchTerm
                                               inRange: self.dataRequestRange
                                            onComplete: ^(int itemsCount) {
                                                weakSelf.dataItemsAvailable = itemsCount;
                                                weakSelf.loadingMoreContent = NO;
                                                [weakSelf.videoThumbnailCollectionView reloadData];
                                            }];
    }
}


- (CGSize) footerSize
{
    return [SYNDeviceManager.sharedInstance isIPhone] ? CGSizeMake(320.0f, 64.0f) : CGSizeMake(1024.0, 64.0);
}


- (SYNAppDelegate*) appDelegate
{
    if (!appDelegate)
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    return appDelegate;
}


- (NSRange) dataRequestRange
{
    if (dataRequestRange.length == 0)
    {
        dataRequestRange = NSMakeRange(0, kAPIInitialBatchSize);
    }
        
    return dataRequestRange;
}


- (void) setRunningSearchOperation: (MKNetworkOperation *) runningSearchOperation
{
    if(_runningSearchOperation)
        [_runningSearchOperation cancel];
    
    _runningSearchOperation = runningSearchOperation;
}


#pragma mark - onboarding

- (void) showVideoOnboardingForCell: (SYNVideoThumbnailWideCell*) cell
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasShownVideoOnBoarding = [defaults boolForKey:kUserDefaultsAddVideo];
    if(!hasShownVideoOnBoarding)
    {
        
        NSString* message = NSLocalizedString(@"onboarding_video", nil);
        
        CGFloat fontSize = IS_IPAD ? 19.0 : 15.0 ;
        CGSize size = IS_IPAD ? CGSizeMake(340.0, 164.0) : CGSizeMake(260.0, 144.0);
        CGRect rectToPointTo = CGRectZero;
        PointingDirection directionToPointTo = PointingDirectionDown;
        if(cell)
        {
            rectToPointTo = [self.view convertRect:cell.addItButton.frame fromView:cell];
            if(rectToPointTo.origin.y < [[SYNDeviceManager sharedInstance] currentScreenHeight] * 0.5)
                directionToPointTo = PointingDirectionUp;
            
            //NSLog(@"%f %f", rectToPointTo.origin.x, rectToPointTo.origin.y);
        }
        SYNOnBoardingPopoverView* addToChannelPopover = [SYNOnBoardingPopoverView withMessage:message
                                                                                     withSize:size
                                                                                  andFontSize:fontSize
                                                                                   pointingTo:rectToPointTo
                                                                                withDirection:directionToPointTo];

        __weak SYNFeedRootViewController* wself = self;
        addToChannelPopover.action = ^{
            [wself videoAddButtonTapped:cell.addItButton];
        };
        [appDelegate.onBoardingQueue addPopover:addToChannelPopover];
        
        [defaults setBool:YES forKey:kUserDefaultsAddVideo];
        
        [appDelegate.onBoardingQueue present];
    }
}

@end
