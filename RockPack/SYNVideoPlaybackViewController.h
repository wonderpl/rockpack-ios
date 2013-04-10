//
//  SYNYoutTubeVideoViewController.h
//  rockpack
//
//  Created by Nick Banks on 15/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Video.h"
#import "VideoInstance.h"

// Forward declaration for
@class SYNVideoPlaybackViewController;
@class NSFetchedResultsController;

// Define our event callback delegate
@protocol SYNVideoPlaybackViewControllerDelegate

- (void) videoPlaybackViewController: (SYNVideoPlaybackViewController *) viewController
                didReceiveEventNamed: (NSString *) eventName
                           eventData: (NSString *) eventData;

@end


@interface SYNVideoPlaybackViewController : UIViewController

@property (nonatomic, weak) id<SYNVideoPlaybackViewControllerDelegate> delegate;

@property (nonatomic, assign, readonly) NSTimeInterval currentTime;
@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, strong) UIView *shuttleBarView;
@property (nonatomic, strong) VideoInstance* currentVideoInstance;

// Initialisation
- (id) initWithFrame: (CGRect) frame;

//- (void) setVideoWithSource: (NSString *) source
//                   sourceId: (NSString *) sourceId
//                   autoPlay: (BOOL) autoPlay;

- (void) setPlaylistWithFetchedResultsController: (NSFetchedResultsController *) fetchedResultsController
                               selectedIndexPath: (NSIndexPath *) selectedIndexPath
                                        autoPlay: (BOOL) autoPlay;

// Player control
- (void) playVideoAtIndex: (NSIndexPath *) newIndexPath;
- (void) loadNextVideo;
- (void) loadPreviousVideo;



@end
