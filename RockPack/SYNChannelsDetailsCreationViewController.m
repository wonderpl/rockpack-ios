//
//  SYNChannelsDetailsCreationViewController.m
//  rockpack
//
//  Created by Nick Banks on 08/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "Channel.h"
#import "SYNChannelHeaderView.h"
#import "SYNChannelsDetailsCreationViewController.h"
#import "SYNTextField.h"
#import "UIImageView+ImageProcessing.h"

@implementation SYNChannelsDetailsCreationViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Hide buttons not used in channel creation
    self.editButton.hidden = YES;
    self.shareButton.hidden = YES;
    self.categoryButton.hidden = NO;
    self.categoryStaticLabel.hidden = YES;
    self.privateImageView.hidden = NO;
    self.saveOrDoneButtonLabel.hidden = NO;
    self.channelTitleTextField.enabled = YES;
    
    // Frig the label frame
    CGRect labelFrame = self.categoryLabel.frame;
    labelFrame.origin.x += 130;
    labelFrame.origin.y -= 10;
    self.categoryLabel.frame = labelFrame;
    self.categoryLabel.textAlignment = NSTextAlignmentCenter;
    
    [self showDoneButton];
    
    self.channelCoverCarouselCollectionView.hidden = TRUE;

    // Set all labels and images to correspond to the selected channel
    self.channelTitleTextField.text = @"NAME YOUR CHANNEL...";
    self.displayNameLabel.text = @"BY YOU";
    self.changeCoverLabel.text = @"ADD A COVER";
    
    // set User's avatar picture
    [self.userAvatarImageView setAsynchronousImageFromURL: [NSURL URLWithString: @"http://demo.dev.rockpack.com.s3.amazonaws.com/images/Sofia.png"]
                                         placeHolderImage: nil];
    
    // As we don't actually have a real channel at the moment, fake up the channel description
    self.channel.channelDescription = @"Describe your channel...";
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    self.collectionHeaderView.channelDescriptionHightlightView.hidden = FALSE;
    self.collectionHeaderView.channelDescriptionTextView.text = @"Describe your channel...";
    self.collectionHeaderView.cfollowButton.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteHideTabBar
                                                        object: self];
}

- (void) viewWillDisappear: (BOOL) animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteShowTabBar
                                                        object: self];
    
    [super viewWillDisappear: animated];
}

- (NSFetchedResultsController *) fetchedResultsController
{
    
    
    if (fetchedResultsController)
        return fetchedResultsController;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    
    fetchRequest.entity = [NSEntityDescription entityForName: @"VideoInstance"
                                      inManagedObjectContext: appDelegate.channelsManagedObjectContext];
    
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat: @"channel.uniqueId == \"%@\"", self.channel.uniqueId]];
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"position" ascending: YES]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                        managedObjectContext: appDelegate.channelsManagedObjectContext
                                                                          sectionNameKeyPath: nil
                                                                                   cacheName: nil];
    fetchedResultsController.delegate = self;
    
    
    NSError *error = nil;
    ZAssert([fetchedResultsController performFetch: &error], @"Channels Details Failed: %@\n%@", [error localizedDescription], [error userInfo]);
    
    NSLog (@"Objects = %@", fetchedResultsController.fetchedObjects);
    return fetchedResultsController;
}

- (BOOL) hideChannelDescriptionHighlight
{
    return FALSE;
}

@end
