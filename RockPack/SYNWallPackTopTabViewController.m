//
//  SYNWallPackTopTabViewController.m
//  RockPack
//
//  Created by Nick Banks on 14/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppContants.h"
#import "AudioToolbox/AudioToolbox.h"
#import "NSObject+Blocks.h"
#import "SYNWallPackCategoryAViewController.h"
#import "SYNWallPackCategoryBViewController.h"
#import "SYNWallPackTopTabViewController.h"
#import "SYNWallpackCarouselCell.h"
#import "SYNWallpackCarouselVerticalLayout.h"
#import "UIFont+SYNFont.h"

@interface SYNWallPackTopTabViewController ()

@property (nonatomic, strong) IBOutlet UICollectionView *wallpackCarousel;
@property (nonatomic, strong) IBOutlet UIImageView *wallpackPreview;
@property (nonatomic, assign) BOOL shouldPlaySound;
@property (nonatomic, assign) int currentIndex;
@property (nonatomic, assign) int currentOffset;
@property (nonatomic, strong) NSArray *wallpackTitles;
@property (nonatomic, strong) NSArray *wallpackPrices;
@property (nonatomic, strong) IBOutlet UILabel *wallpackTitle;
@property (nonatomic, strong) IBOutlet UILabel *wallpackPrice;

@end

@implementation SYNWallPackTopTabViewController

// For the demo version, just set up two view controllers so that we can switch between them when the tabs are selected
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.wallpackTitle.font = [UIFont boldRockpackFontOfSize: 21.0f];
    self.wallpackPrice.font = [UIFont boldRockpackFontOfSize: 25.0f];
    
    self.wallpackTitles = @[@"AMAZING ALEX WALLPACK",
                            @"SPACE WALLPACK",
                            @"JUSTIN BIEBER WALLPACK",
                            @"USAIN BOLT WALLPACK",
                            @"PIXARS 'BRAVE' WALLPACK",
                            @"STAR WARS WALLPACK",
                            @"ONE DIRECTION WALLPACK",
                            @"HARRY POTTER WALLPACK",
                            @"MONSTERS UNIVERSITY WALLPACK",
                            @"THE INCREDIBLE HULK WALLPACK",
                            @"JAMES BOND WALLPACK"];
    
    self.wallpackPrices = @[@"100",
                            @"300",
                            @"500",
                            @"200",
                            @"900",
                            @"400",
                            @"700",
                            @"200",
                            @"800",
                            @"100",
                            @"600"];

    // Set up wallpack carousel
    SYNWallpackCarouselVerticalLayout *wallpackCarouselVerticalLayout = [[SYNWallpackCarouselVerticalLayout alloc] init];
    self.wallpackCarousel.collectionViewLayout = wallpackCarouselVerticalLayout;
    
//    // Setup our four sub-viewcontrollers, one for each tab
//    SYNWallPackCategoryAViewController *categoryAViewController = [[SYNWallPackCategoryAViewController alloc] init];
//    SYNWallPackCategoryBViewController *categoryBViewController = [[SYNWallPackCategoryBViewController alloc] init];
//    
//    // Using new array syntax
//    self.viewControllers = @[categoryAViewController, categoryBViewController, categoryAViewController, categoryBViewController, categoryAViewController,
//                             categoryBViewController, categoryAViewController, categoryBViewController, categoryAViewController, categoryAViewController];
//    
//    self.selectedViewController = categoryAViewController;
    
    // Set up our carousel
    [self.wallpackCarousel registerClass: [SYNWallpackCarouselCell class] forCellWithReuseIdentifier: @"SYNWallpackCarouselCell"];
    self.wallpackCarousel.decelerationRate = UIScrollViewDecelerationRateNormal;
}


- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    NSIndexPath *startIndexPath = [NSIndexPath indexPathForRow: 1500 inSection: 0];
    
    [self.wallpackCarousel scrollToItemAtIndexPath: startIndexPath
                                  atScrollPosition: UICollectionViewScrollPositionCenteredVertically
                                          animated: NO];
    
    // Only play the scrolling click (after we have scrolled to the right position in the list,
    // which might not have finished in this run loop
    [NSObject performBlock: ^
                            {
                                self.shouldPlaySound = TRUE;
                            }
                afterDelay: 0.1f];
}


- (void) viewDidDisappear: (BOOL) animated
{
    self.shouldPlaySound = FALSE;
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
#ifdef SOUND_ENABLED
    // Play a suitable sound
    NSString *soundPath = [[NSBundle mainBundle] pathForResource: @"Scroll"
                                                          ofType: @"aif"];
    
    if (self.shouldPlaySound == TRUE)
    {
        NSURL *soundURL = [NSURL fileURLWithPath: soundPath];
        SystemSoundID sound;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
        AudioServicesPlaySystemSound(sound);
    }
#endif

    SYNWallpackCarouselCell *cell = [cv dequeueReusableCellWithReuseIdentifier: @"SYNWallpackCarouselCell"
                                                                  forIndexPath: indexPath];
    
    NSString *imageName = [NSString stringWithFormat: @"Wallpack_%d.png", indexPath.row % 11];
    cell.image = [UIImage imageNamed: imageName];
    
    return cell;
}

- (void) setSelectedIndex: (NSUInteger) newSelectedIndex
                 animated: (BOOL) animated
{
    if (newSelectedIndex != NSNotFound)
    {
        [self highlightTab: newSelectedIndex];
        self.currentOffset = newSelectedIndex;
    }
}

- (void) scrollViewDidEndDecelerating: (UICollectionView *) cv
{
    NSArray *items = [cv indexPathsForVisibleItems];
    NSIndexPath *indexPath = [cv indexPathForItemAtPoint: CGPointMake(100.0f, cv.contentOffset.y + 250.0f)];
//    NSIndexPath *middleItem = [items objectAtIndex: 2];
    
    NSString *imageName = [NSString stringWithFormat: @"LargeWallpack_%d.jpg", indexPath.row % 11];
    self.wallpackPreview.image = [UIImage imageNamed: imageName];
    
    self.wallpackTitle.text = [self.wallpackTitles objectAtIndex: indexPath.row % 11];
    self.wallpackPrice.text = [self.wallpackPrices objectAtIndex: indexPath.row % 11];
}


@end
