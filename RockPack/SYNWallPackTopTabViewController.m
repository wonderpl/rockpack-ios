//
//  SYNWallPackTopTabViewController.m
//  RockPack
//
//  Created by Nick Banks on 14/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppContants.h"
#import "SYNWallPackTopTabViewController.h"
#import "SYNWallPackCategoryAViewController.h"
#import "SYNWallPackCategoryBViewController.h"
#import "SYNWallpackCarouselVerticalLayout.h"
#import "SYNWallpackCarouselCell.h"
#import "AudioToolbox/AudioToolbox.h"

@interface SYNWallPackTopTabViewController ()

@property (nonatomic, strong) IBOutlet UICollectionView *wallpackCarousel;

@end

@implementation SYNWallPackTopTabViewController

// For the demo version, just set up two view controllers so that we can switch between them when the tabs are selected
- (void) viewDidLoad
{
    [super viewDidLoad];

    // Set up wallpack carousel
    SYNWallpackCarouselVerticalLayout *wallpackCarouselVerticalLayout = [[SYNWallpackCarouselVerticalLayout alloc] init];
    self.wallpackCarousel.collectionViewLayout = wallpackCarouselVerticalLayout;
    
    // Setup our four sub-viewcontrollers, one for each tab
    SYNWallPackCategoryAViewController *categoryAViewController = [[SYNWallPackCategoryAViewController alloc] init];
    SYNWallPackCategoryBViewController *categoryBViewController = [[SYNWallPackCategoryBViewController alloc] init];
    
    // Using new array syntax
    self.viewControllers = @[categoryAViewController, categoryBViewController, categoryAViewController, categoryBViewController, categoryAViewController,
                             categoryBViewController, categoryAViewController, categoryBViewController, categoryAViewController, categoryAViewController];
    
    self.selectedViewController = categoryAViewController;
    
    // Set up our carousel
    [self.wallpackCarousel registerClass: [SYNWallpackCarouselCell class] forCellWithReuseIdentifier: @"SYNWallpackCarouselCell"];
    self.wallpackCarousel.decelerationRate = UIScrollViewDecelerationRateNormal;
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    NSIndexPath *startIndexPath = [NSIndexPath indexPathForRow: 1500 inSection: 0];
    
    [self.wallpackCarousel scrollToItemAtIndexPath: startIndexPath
                                  atScrollPosition: UICollectionViewScrollPositionCenteredVertically
                                          animated: NO];
}


// To simulate an endlessly scrolling list, make the number of items very large

- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section;
{
    return 5000;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath;
{
    // Play a suitable sound
    NSString *soundPath = [[NSBundle mainBundle] pathForResource: @"Scroll"
                                                          ofType: @"aif"];
    
    NSURL *soundURL = [NSURL fileURLWithPath: soundPath];
    SystemSoundID sound;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
    AudioServicesPlaySystemSound(sound);


    SYNWallpackCarouselCell *cell = [cv dequeueReusableCellWithReuseIdentifier: @"SYNWallpackCarouselCell"
                                                                  forIndexPath: indexPath];
    
    NSString *imageName = [NSString stringWithFormat: @"Wallpack_%d.png", indexPath.row % 10];
    cell.image = [UIImage imageNamed: imageName];
    
    return cell;
}


@end
