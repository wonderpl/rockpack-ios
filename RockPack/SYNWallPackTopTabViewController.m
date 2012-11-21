//
//  SYNWallPackTopTabViewController.m
//  rockpack
//
//  Created by Nick Banks on 12/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "SYNSwitch.h"
#import "SYNWallPackTopTabViewController.h"
#import "SYNWallpackThumbnailCell.h"
#import "SYNWallpacksDB.h"
#import "UIFont+SYNFont.h"

@interface SYNWallPackTopTabViewController ()

@property (nonatomic, assign) int currentIndex;
@property (nonatomic, assign) int currentOffset;
@property (nonatomic, strong) IBOutlet SYNSwitch *slider;
@property (nonatomic, strong) IBOutlet UICollectionView *thumbnailView;
@property (nonatomic, strong) IBOutlet UIImageView *audioMessage;
@property (nonatomic, strong) IBOutlet UIImageView *infoBox;
@property (nonatomic, strong) IBOutlet UIImageView *userAvatar;
@property (nonatomic, strong) IBOutlet UIImageView *videoBox;
@property (nonatomic, strong) IBOutlet UIImageView *wallpackDescription;
@property (nonatomic, strong) IBOutlet UILabel *availableCredit;
@property (nonatomic, strong) IBOutlet UILabel *biogBody;
@property (nonatomic, strong) IBOutlet UILabel *biogTitle;
@property (nonatomic, strong) IBOutlet UILabel *myWallpacks;
@property (nonatomic, strong) IBOutlet UILabel *userName;
@property (nonatomic, strong) IBOutlet UILabel *wallpackStore;
@property (nonatomic, strong) IBOutlet UIView *avatarView;
@property (nonatomic, strong) IBOutlet UIView *cardsView;
@property (nonatomic, strong) SYNWallpacksDB *wallpacksDB;
@property (nonatomic, strong) UIColor *darkSwitchColor;
@property (nonatomic, strong) UIColor *lightSwitchColor;
@property (nonatomic, assign) CGPoint originalOrigin;
@property (nonatomic, strong) IBOutlet UIButton *backButton;

@end

@implementation SYNWallPackTopTabViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Add custom slider
    self.slider = [[SYNSwitch alloc] initWithFrame: CGRectMake(767, 112, 95, 42)];
    self.slider.on = NO;
    [self.slider addTarget: self
                    action: @selector(switchChanged:forEvent:)
          forControlEvents: (UIControlEventValueChanged)];
    
    [self.view addSubview: self.slider];
    
    self.userName.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.availableCredit.font = [UIFont rockpackFontOfSize: 17.0f];
    self.myWallpacks.font = [UIFont boldRockpackFontOfSize: 15.0f];
    self.wallpackStore.font = [UIFont boldRockpackFontOfSize: 15.0f];
    self.biogTitle.font = [UIFont boldRockpackFontOfSize: 24.0f];
    self.biogBody.font = [UIFont rockpackFontOfSize: 17.0f];
    self.userAvatar.image = [UIImage imageNamed: @"EddieTaylor.png"];
    
    self.lightSwitchColor = [UIColor colorWithRed: 213.0f/255.0f green: 233.0f/255.0f blue: 238.0f/255.0f alpha: 1.0f];
    self.darkSwitchColor = [UIColor colorWithRed: 129.0f/255.0f green: 154.0f/255.0f blue: 162.0f/255.0f alpha: 1.0f];

    
    // Init collection view
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNWallpackThumbnailCell"
                                             bundle: nil];
    
    [self.thumbnailView registerNib: thumbnailCellNib
         forCellWithReuseIdentifier: @"ChannelWallpackCell"];
    
    // Cache the channels DB to make the code clearer
    self.wallpacksDB = [SYNWallpacksDB sharedWallpacksDBManager];
}

- (void) switchChanged: (id)sender
              forEvent: (UIEvent *) event
{
    if (self.slider.on == YES)
    {
         // Set wallpack store label to light and my wallpacks to dark
         self.myWallpacks.textColor = self.darkSwitchColor;
         self.wallpackStore.textColor = self.lightSwitchColor;
         [self.thumbnailView moveItemAtIndexPath: [NSIndexPath indexPathForRow: 0 inSection: 0] toIndexPath: [NSIndexPath indexPathForRow: 4 inSection: 0]];
         [self.thumbnailView moveItemAtIndexPath: [NSIndexPath indexPathForRow: 7 inSection: 0] toIndexPath: [NSIndexPath indexPathForRow: 2 inSection: 0]];
    }
    else
    {
         // Set wallpack store label to light and my wallpacks to dark
         self.myWallpacks.textColor = self.lightSwitchColor;
         self.wallpackStore.textColor = self.darkSwitchColor;
         [self.thumbnailView moveItemAtIndexPath: [NSIndexPath indexPathForRow: 2 inSection: 0] toIndexPath: [NSIndexPath indexPathForRow: 7 inSection: 0]];
         [self.thumbnailView moveItemAtIndexPath: [NSIndexPath indexPathForRow: 4 inSection: 0] toIndexPath: [NSIndexPath indexPathForRow: 0 inSection: 0]];
    }
}

- (void) setCenters: (CGPoint) center
{
     self.avatarView.center = center;
     self.cardsView.center = center;
     self.audioMessage.center = center;
     self.infoBox.center = center;
     self.videoBox.center = center;
    
    self.originalOrigin = center;
}


- (void) animateOut
{
    [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         // Being to front
         self.avatarView.alpha = 1.0f;
         self.cardsView.alpha = 1.0f;
         self.audioMessage.alpha = 1.0f;
         self.infoBox.alpha = 1.0f;
         self.videoBox.alpha = 1.0f;
         self.wallpackDescription.alpha = 1.0f;
         self.biogBody.alpha = 1.0f;
         self.biogTitle.alpha = 1.0f;
         self.backButton.alpha = 1.0f;
         
         // Send to back
         self.thumbnailView.alpha = 0.0f;
         
         // Animate out to correct positions
         self.avatarView.center = CGPointMake (382.5f, 356.5f);
         self.cardsView.center = CGPointMake (168.0f, 325.0f);
         self.audioMessage.center = CGPointMake (839.5f, 408.0f);
         self.infoBox.center = CGPointMake (572.5f, 361.0f);
         self.videoBox.center = CGPointMake (837.5f, 296.0f);
     }
                     completion: ^(BOOL finished)
     {
     }];
}

- (void) animateIn
{
    [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         // Being to front
         self.thumbnailView.alpha = 1.0f;

         // Send to back
         self.avatarView.alpha = 0.0f;
         self.cardsView.alpha = 0.0f;
         self.audioMessage.alpha = 0.0f;
         self.infoBox.alpha = 0.0f;
         self.videoBox.alpha = 0.0f;
         self.wallpackDescription.alpha = 0.0f;
         self.biogBody.alpha = 0.0f;
         self.biogTitle.alpha = 0.0f;
         self.backButton.alpha = 0.0f;
         
         // Animate back to touch point
         self.avatarView.center = self.originalOrigin;
         self.cardsView.center = self.originalOrigin;
         self.audioMessage.center = self.originalOrigin;
         self.infoBox.center = self.originalOrigin;
         self.videoBox.center = self.originalOrigin;
     }
                     completion: ^(BOOL finished)
     {
     }];
}

- (IBAction) userTouchedBackButton: (id) sender
{
    [self animateIn];
}

#pragma mark - Collection view support

- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    return self.wallpacksDB.numberOfThumbnails;
}

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) cv
{
    return 1;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNWallpackThumbnailCell *cell = [cv dequeueReusableCellWithReuseIdentifier: @"ChannelWallpackCell"
                                                                  forIndexPath: indexPath];
    
    cell.imageView.image = [self.wallpacksDB thumbnailForIndex: indexPath.row
                                                   withOffset: self.currentOffset];
    
    cell.title.text = [self.wallpacksDB titleForIndex: indexPath.row
                                              withOffset: self.currentOffset];
    
    cell.price.text = [self.wallpacksDB priceForIndex: indexPath.row
                                          withOffset: self.currentOffset];
    
    return cell;
}


- (void) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    self.currentIndex = indexPath.row;
    
    SYNWallpackThumbnailCell *channelCell = (SYNWallpackThumbnailCell *)[self.thumbnailView cellForItemAtIndexPath: indexPath];
    
    // Get the various frames we need to calculate the actual position   
    
    CGPoint center = channelCell.center;
    
    center.x += self.thumbnailView.frame.origin.x;
    center.y += self.thumbnailView.frame.origin.y;
    
    CGPoint offset = self.thumbnailView.contentOffset;

    center.x -= offset.x;
    center.y -= offset.y;
    
    // Now add them together to get the real pos in the top view
//    imageViewFrame.origin.x += cellFrame.origin.x + viewFrame.origin.x - offset.x;
//    imageViewFrame.origin.y += cellFrame.origin.y + viewFrame.origin.y - offset.y;
    
    // Now create a new UIImageView to overlay
//    [self setCenters: channelCell.center];
    
    [self setCenters: center];
    
    [self animateOut];
}



@end
