//
//  SYNWallPackTopTabViewController.m
//  RockPack
//
//  Created by Nick Banks on 14/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "AudioToolbox/AudioToolbox.h"
#import "NSObject+Blocks.h"
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
@property (nonatomic, strong) IBOutlet SYNWallpackCarouselVerticalLayout *verticalLayout;

@end

@implementation SYNWallPackTopTabViewController

// For the demo version, just set up two view controllers so that we can switch between them when the tabs are selected
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.wallpackTitle.font = [UIFont boldRockpackFontOfSize: 21.0f];
    self.wallpackPrice.font = [UIFont boldRockpackFontOfSize: 25.0f];
    
    self.wallpackTitles = @[@"MADAGASCAR 3 - AWESOME ALEX WALLPACK",
                            @"ADY GAGA KNOWS HOW TO PARTY - JOIN THE REVOLUTION ON ROCKPACK!",
                            @"IF YOU ARE A BELIEBER, YOU BETTER PACK THIS JUSTIN WALLPACK!",
                            @"THE NAME'S ROCK. ROCKPACK. - JAMES BOND WALLPACK",
                            @"LOVE MILEY? LOVE THIS AMAZING WALLPACK",
                            @"MAY THE ROCKPACK BE WITH YOU - STAR WARS WALLPACK",
                            @"99 PROBLEMS BUT THIS WALLPACK AINT ONE",
                            @"HE WORLDS GREATEST PLAYER ON THE WORLDS GREATEST WALLPACK",
                            @"JOIN SULLEY ON THIS MONSTERS UNIVERSITY WALLPACK",
                            @"SMASH! ITS THE INCREDIBLE HULK WALLPACK",
                            @"THE NAME'S ROCK. ROCKPACK. - JAMES BOND WALLPACK"];
    
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
    
    // Set up our carousel
    [self.wallpackCarousel registerClass: [SYNWallpackCarouselCell class] forCellWithReuseIdentifier: @"SYNWallpackCarouselCell"];
    self.wallpackCarousel.decelerationRate = UIScrollViewDecelerationRateNormal;
}


- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    NSIndexPath *startIndexPath = [NSIndexPath indexPathForRow: 1504 inSection: 0];
    
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
    
    NSString *imageName = [NSString stringWithFormat: @"Wallpack_%d.png", indexPath.row % 10];
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
    NSIndexPath *indexPath = [cv indexPathForItemAtPoint: CGPointMake(100.0f, cv.contentOffset.y + 250.0f)];
    
    NSString *imageName = [NSString stringWithFormat: @"LargeWallpack_%d.jpg", indexPath.row % 10];
    self.wallpackPreview.image = [UIImage imageNamed: imageName];
    
    self.wallpackTitle.text = [self.wallpackTitles objectAtIndex: indexPath.row % 10];
    self.wallpackPrice.text = [self.wallpackPrices objectAtIndex: indexPath.row % 10];
}


@end
