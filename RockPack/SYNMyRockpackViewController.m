//
//  SYNMyRockpackViewController.m
//  rockpack
//
//  Created by Nick Banks on 26/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNMyRockpackViewController.h"
#import "SYNMyRockpackDetailViewController.h"
#import "SYNSwitch.h"
#import "UIFont+SYNFont.h"

@interface SYNMyRockpackViewController ()

@property (nonatomic, assign) int currentIndex;
@property (nonatomic, assign) int currentOffset;
@property (nonatomic, strong) IBOutlet SYNSwitch *toggleSwitch;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet UILabel *packedVideosLabel;
@property (nonatomic, strong) IBOutlet UILabel *userName;
@property (nonatomic, strong) IBOutlet UILabel *channelLabel;
@property (nonatomic, strong) IBOutlet UIView *avatarView;
@property (nonatomic, strong) IBOutlet UIView *cardsView;
//@property (nonatomic, strong) SYNWallpacksDB *wallpacksDB;
@property (nonatomic, strong) UIColor *darkSwitchColor;
@property (nonatomic, strong) UIColor *lightSwitchColor;
@property (nonatomic, assign) CGPoint originalOrigin;
@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UIImageView *userAvatar;

@end

@implementation SYNMyRockpackViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add custom slider
    self.toggleSwitch = [[SYNSwitch alloc] initWithFrame: CGRectMake(780, 24, 95, 42)];
    self.toggleSwitch.on = NO;
    [self.toggleSwitch addTarget: self
                          action: @selector(switchChanged:forEvent:)
                forControlEvents: (UIControlEventValueChanged)];
    
    // Set switch label colours
    self.lightSwitchColor = [UIColor colorWithRed: 213.0f/255.0f green: 233.0f/255.0f blue: 238.0f/255.0f alpha: 1.0f];
    self.darkSwitchColor = [UIColor colorWithRed: 129.0f/255.0f green: 154.0f/255.0f blue: 162.0f/255.0f alpha: 1.0f];
    self.packedVideosLabel.textColor = self.lightSwitchColor;
    self.channelLabel.textColor = self.darkSwitchColor;
    
    [self.view addSubview: self.toggleSwitch];
    
    self.userName.font = [UIFont boldRockpackFontOfSize: 25.0f];
    self.packedVideosLabel.font = [UIFont boldRockpackFontOfSize: 15.0f];
    self.channelLabel.font = [UIFont boldRockpackFontOfSize: 15.0f];
    self.userAvatar.image = [UIImage imageNamed: @"EddieTaylor.png"];
    
    // Init collection view
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNWallpackThumbnailCell"
                                             bundle: nil];
    
    [self.collectionView registerNib: thumbnailCellNib
         forCellWithReuseIdentifier: @"ChannelWallpackCell"];
    
    // Cache the channels DB to make the code clearer
//    self.wallpacksDB = [SYNWallpacksDB sharedWallpacksDBManager];

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];

}

- (void) switchChanged: (id)sender
              forEvent: (UIEvent *) event
{
    if (self.toggleSwitch.on == YES)
    {
        // Set wallpack store label to light and my wallpacks to dark
        self.packedVideosLabel.textColor = self.darkSwitchColor;
        self.channelLabel.textColor = self.lightSwitchColor;
        [self.collectionView moveItemAtIndexPath: [NSIndexPath indexPathForRow: 0 inSection: 0] toIndexPath: [NSIndexPath indexPathForRow: 4 inSection: 0]];
        [self.collectionView moveItemAtIndexPath: [NSIndexPath indexPathForRow: 7 inSection: 0] toIndexPath: [NSIndexPath indexPathForRow: 2 inSection: 0]];
    }
    else
    {
        // Set wallpack store label to light and my wallpacks to dark
        self.packedVideosLabel.textColor = self.lightSwitchColor;
        self.channelLabel.textColor = self.darkSwitchColor;
        [self.collectionView moveItemAtIndexPath: [NSIndexPath indexPathForRow: 2 inSection: 0] toIndexPath: [NSIndexPath indexPathForRow: 7 inSection: 0]];
        [self.collectionView moveItemAtIndexPath: [NSIndexPath indexPathForRow: 4 inSection: 0] toIndexPath: [NSIndexPath indexPathForRow: 0 inSection: 0]];
    }
}


- (IBAction)transition:(id)sender
{
    SYNMyRockpackDetailViewController *vc = [[SYNMyRockpackDetailViewController alloc] init];
    
    vc.view.alpha = 0.0f;
    
    [self.navigationController pushViewController: vc
                                         animated: NO];
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         // Contract thumbnail view
         self.view.alpha = 0.0f;
         vc.view.alpha = 1.0f;
         
     }
                     completion: ^(BOOL finished)
     {
     }];
}
@end
