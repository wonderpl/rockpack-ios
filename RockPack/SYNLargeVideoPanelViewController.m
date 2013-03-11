//
//  SYNLargeVideoPanelViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 08/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNLargeVideoPanelViewController.h"
#import "UIFont+SYNFont.h"
#import "VideoInstance.h"
#import "Video.h"
#import "AppConstants.h"
#import "SYNVideoPlaybackViewController.h"

@interface SYNLargeVideoPanelViewController ()



// Share (arrow) Button and Label
@property (nonatomic, strong) IBOutlet UIButton *shareItButton;
@property (nonatomic, strong) IBOutlet UILabel *shareItLabel;

@property (nonatomic, strong) VideoInstance* videoInstance;

@property (nonatomic, strong) SYNVideoPlaybackViewController* videoPlaybackViewController;

@end

@implementation SYNLargeVideoPanelViewController

@synthesize videoInstance;



-(id)init
{
    if(self = [super initWithNibName:@"SYNLargeVideoPanelViewController" bundle:nil])
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    
    // Set the labels to use the custom font
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: 17.0f];
    self.channelLabel.font = [UIFont rockpackFontOfSize: 14.0f];
    self.userNameLabel.font = [UIFont rockpackFontOfSize: 12.0f];
    self.rockItLabel.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.shareItLabel.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.rockItNumberLabel.font = [UIFont boldRockpackFontOfSize: 20.0f];
    
    self.videoPlaybackViewController = [[SYNVideoPlaybackViewController alloc] initWithFrame: CGRectMake(13, 11, 494, 278)];
    
    [self.view insertSubview:self.videoPlaybackViewController.view aboveSubview:self.backgroundImageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 

- (void) toggleVideoRockItAtIndex: (NSIndexPath *) indexPath
{
    
    if (videoInstance.video.starredByUserValue == TRUE)
    {
        // Currently highlighted, so decrement
        videoInstance.video.starredByUserValue = FALSE;
        videoInstance.video.starCountValue -= 1;
    }
    else
    {
        // Currently highlighted, so increment
        videoInstance.video.starredByUserValue = TRUE;
        videoInstance.video.starCountValue += 1;
    }
    
    // TODO: Save DB ?
    
}

#pragma mark - Button Delegates


- (IBAction) addToVideoQueueFromLargeVideo: (UIButton*) button
{
    
    VideoInstance* currentVideoInstance = self.videoPlaybackViewController.currentVideoInstance;
    [[NSNotificationCenter defaultCenter] postNotificationName:kVideoQueueAdd
                                                        object:self
                                                      userInfo:@{@"VideoInstance" : currentVideoInstance}];
}

- (IBAction) userTouchedVideoShareItButton: (UIButton *) addItButton
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteSharePanelRequested
                                                        object: self];
    
    
}

- (IBAction) toggleLargeVideoPanelStarItButton: (UIButton *) button
{
    button.selected = !button.selected;
    
    
    if (videoInstance.video.starredByUserValue == TRUE)
    {
        // Currently highlighted, so decrement
        videoInstance.video.starredByUserValue = FALSE;
        videoInstance.video.starCountValue -= 1;
    }
    else
    {
        // Currently highlighted, so increment
        videoInstance.video.starredByUserValue = TRUE;
        videoInstance.video.starCountValue += 1;
    }
    
    
    //[self updateLargeVideoDetailsForIndexPath: self.currentIndexPath];
    
    //[self.videoThumbnailCollectionView reloadData];
    
    // TODO: Save DB
}


- (IBAction) userTouchedLargeVideoChannelButton: (UIButton *) channelButton
{
    // Bail if we don't have an index path
//    if (self.currentIndexPath)
//    {
//        VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: self.currentIndexPath];
//        
//        [self viewChannelDetails:videoInstance.channel];
//    }
}


#pragma mark - Video

- (void) setPlaylistWithFetchedResultsController: (NSFetchedResultsController *) fetchedResultsController
                               selectedIndexPath: (NSIndexPath *) selectedIndexPath
                                        autoPlay: (BOOL) autoPlay {
    
    [self.videoPlaybackViewController setPlaylistWithFetchedResultsController: fetchedResultsController
                                                            selectedIndexPath: selectedIndexPath
                                                                     autoPlay: TRUE];
}

- (void) playVideoAtIndex: (NSIndexPath *) newIndexPath
{
    [self.videoPlaybackViewController playVideoAtIndex:newIndexPath];
}

@end
