//
//  SYNLargeVideoPanelViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 08/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface SYNLargeVideoPanelViewController : UIViewController

// Background Image
@property (nonatomic, strong) IBOutlet UIImageView *backgroundImageView;

// Star Button and Label
@property (nonatomic, strong) IBOutlet UIButton *rockItButton;
@property (nonatomic, strong) IBOutlet UILabel *rockItLabel;
@property (nonatomic, strong) IBOutlet UILabel *rockItNumberLabel;


// Add (plus) Button and Label
@property (nonatomic, strong) IBOutlet UIButton *addItButton;
@property (nonatomic, strong) IBOutlet UILabel *addItLabel;



// Channel Image and Button
@property (nonatomic, strong) IBOutlet UILabel *channelLabel;
@property (nonatomic, strong) IBOutlet UIButton *channelImageButton;

// Video Info Labels
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *displayNameLabel;
@property (nonatomic, strong) IBOutlet UIImageView *channelImageView;

- (void) setPlaylistWithFetchedResultsController: (NSFetchedResultsController *) fetchedResultsController selectedIndexPath: (NSIndexPath *) selectedIndexPath autoPlay: (BOOL) autoPlay;

- (void) playVideoAtIndex: (NSIndexPath *) newIndexPath;

@end
