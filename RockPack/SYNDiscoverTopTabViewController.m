//
//  SYNDiscoverTopTabViewController.m
//  RockPack
//
//  Created by Nick Banks on 16/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppContants.h"
#import "AudioToolbox/AudioToolbox.h"
#import "SYNDiscoverTopTabViewController.h"
#import "SYNVideoDB.h"
#import "SYNWallpackCarouselCell.h"
#import "UIFont+SYNFont.h"
#import <MediaPlayer/MediaPlayer.h>

@interface SYNDiscoverTopTabViewController ()

@property (nonatomic, assign) int currentIndex;
@property (nonatomic, assign) int currentOffset;
@property (nonatomic, strong) IBOutlet UIView *videoPlaceholderView;
@property (nonatomic, strong) IBOutlet UIView *largeVideoPanelView;
@property (nonatomic, strong) MPMoviePlayerController *mainVideoPlayer;
@property (nonatomic, strong) IBOutlet UILabel *maintitle;
@property (nonatomic, strong) IBOutlet UILabel *subtitle;
@property (nonatomic, strong) IBOutlet UILabel *packIt;
@property (nonatomic, strong) IBOutlet UILabel *rockIt;
@property (nonatomic, strong) IBOutlet UILabel *packItNumber;
@property (nonatomic, strong) IBOutlet UILabel *rockItNumber;
@property (nonatomic, strong) IBOutlet UIButton *packItButton;
@property (nonatomic, strong) IBOutlet UIButton *rockItButton;
@property (nonatomic, strong) IBOutlet UICollectionView *thumbnailView;
@property (nonatomic, assign, getter = isLargeVideoViewExpanded) BOOL largeVideoViewExpanded;
@property (nonatomic, strong) SYNVideoDB *videoDB;

@end

@implementation SYNDiscoverTopTabViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.videoDB = [SYNVideoDB sharedVideoDBManager];
    
#ifdef FULL_SCREEN_THUMBNAILS

    }
#endif
    
    self.maintitle.font = [UIFont boldRockpackFontOfSize: 24.0f];
    self.subtitle.font = [UIFont rockpackFontOfSize: 17.0f];
    self.packIt.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.rockIt.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.packItNumber.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.rockItNumber.font = [UIFont boldRockpackFontOfSize: 20.0f];
    
    // Init collection view
    UINib *cellNib = [UINib nibWithNibName: @"SYNThumbnailCell"
                                    bundle: nil];
    
    [self.self.thumbnailView registerNib: cellNib
              forCellWithReuseIdentifier: @"ThumbnailCell"];
    
//    [self.thumbnailView registerClass: [UICollectionViewCell class]
//            forCellWithReuseIdentifier: @"ThumnailCell"];

}


- (void) viewWillAppear: (BOOL) animated
{
    // Set the first video
    [self setLargeVideoIndex: self.currentIndex
                  withOffset: self.currentOffset];
}


- (void) setLargeVideoIndex: (int) index
                 withOffset: (int) offset
{
    self.currentIndex = index;
    self.currentOffset = offset;
    
    [self updateLargeVideoDetailsForIndex: index
                               withOffset: offset];
    
    NSURL *videoURL = [self.videoDB videoURLForIndex: index
                                          withOffset: offset];
    
    self.mainVideoPlayer = [[MPMoviePlayerController alloc] initWithContentURL: videoURL];
    
    self.mainVideoPlayer.shouldAutoplay = NO;
    [self.mainVideoPlayer prepareToPlay];
    
    [[self.mainVideoPlayer view] setFrame: [self.videoPlaceholderView bounds]]; // Frame must match parent view
    
    [self.videoPlaceholderView addSubview: [self.mainVideoPlayer view]];
    [self.mainVideoPlayer pause];
}


- (void) updateLargeVideoDetailsForIndex: (int) index
                              withOffset: (int) offset
{
    self.maintitle.text = [self.videoDB titleForIndex: index
                                           withOffset: offset];
    
    self.subtitle.text = [self.videoDB subtitleForIndex: index
                                             withOffset: offset];
    
    self.packItNumber.text = [NSString stringWithFormat: @"%d", [self.videoDB packItNumberForIndex: index
                                                                                        withOffset: offset]];
    
    self.rockItNumber.text = [NSString stringWithFormat: @"%d", [self.videoDB rockItNumberForIndex: index
                                                                                        withOffset: offset]];
    self.packItButton.selected = ([self.videoDB packItForIndex: index
                                                          withOffset: offset]) ? TRUE : FALSE;
    
    self.rockItButton.selected = ([self.videoDB rockItForIndex: index
                                                          withOffset: offset]) ? TRUE : FALSE;
}

- (void) viewDidAppear: (BOOL) animated
{
    [self.thumbnailView reloadData];
}


- (void) setSelectedIndex: (NSUInteger) newSelectedIndex
                 animated: (BOOL) animated
{
    if (newSelectedIndex != NSNotFound)
    {
        [self highlightTab: newSelectedIndex];
        self.currentOffset = newSelectedIndex;
        
        [self setLargeVideoIndex: 0
                      withOffset: self.currentOffset];
    }
}

- (IBAction) toggleLargeRockItButton: (id)sender
{
    int number = [self.videoDB rockItNumberForIndex: self.currentIndex
                                         withOffset: self.currentOffset];
    
    BOOL isTrue = [self.videoDB rockItForIndex: self.currentIndex
                                    withOffset: self.currentOffset];
    
    if (isTrue)
    {
        number--;
        
        [self.videoDB setRockIt: FALSE
                       forIndex: self.currentIndex
                     withOffset: self.currentOffset];
    }
    else
    {
        number++;
        
        [self.videoDB setRockIt: TRUE
                       forIndex: self.currentIndex
                     withOffset: self.currentOffset];
    }
    
    [self.videoDB setRockItNumber: number
                         forIndex: self.currentIndex
                       withOffset: self.currentOffset];
    
    [self updateLargeVideoDetailsForIndex: self.currentIndex
                               withOffset: self.currentOffset];
    
    [self.thumbnailView reloadData];
}

- (IBAction) toggleLargePackItButton: (id)sender
{
    int number = [self.videoDB packItNumberForIndex: self.currentIndex
                                         withOffset: self.currentOffset];
    
    BOOL isTrue = [self.videoDB packItForIndex: self.currentIndex
                                    withOffset: self.currentOffset];
    
    if (isTrue)
    {
        number--;
        
        [self.videoDB setPackIt: FALSE
                       forIndex: self.currentIndex
                     withOffset: self.currentOffset];
    }
    else
    {
        number++;
        
        [self.videoDB setPackIt: TRUE
                       forIndex: self.currentIndex
                     withOffset: self.currentOffset];
    }
    
    [self.videoDB setPackItNumber: number
                         forIndex: self.currentIndex
                       withOffset: self.currentOffset];
    
    [self updateLargeVideoDetailsForIndex: self.currentIndex
                               withOffset: self.currentOffset];
    
    [self.thumbnailView reloadData];
}

#pragma mark - Large video view gesture handler

- (IBAction) swipeLargeVideoViewLeft: (UISwipeGestureRecognizer *) swipeGesture
{
#ifdef FULL_SCREEN_THUMBNAILS
#ifdef SOUND_ENABLED
    // Play a suitable sound
    NSString *soundPath = [[NSBundle mainBundle] pathForResource: @"RockieTalkie_Slide_In"
                                                          ofType: @"aif"];
    
    NSURL *soundURL = [NSURL fileURLWithPath: soundPath];
    SystemSoundID sound;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
    AudioServicesPlaySystemSound(sound);
#endif
    
    // Animate the view out onto the screen
    [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         // Slide off large video view
         CGRect largeVideoPanelFrame = self.largeVideoPanelView.frame;
         largeVideoPanelFrame.origin.x = -1024;
         self.largeVideoPanelView.frame =  largeVideoPanelFrame;
         
         // Expand thumbnail view
         CGRect thumbailViewFrame = self.thumbnailView.frame;
         thumbailViewFrame.origin.x = 0;
         thumbailViewFrame.size.width = 1024;
         self.thumbnailView.frame =  thumbailViewFrame;
     }
                     completion: ^(BOOL finished)
     {
         // Fix hidden video view
         CGRect largeVideoPanelFrame = self.largeVideoPanelView.frame;
         largeVideoPanelFrame.origin.x = -1024;
         self.largeVideoPanelView.frame =  largeVideoPanelFrame;
         
         // Fix expanded thumbnail view
         CGRect thumbailViewFrame = self.thumbnailView.frame;
         thumbailViewFrame.origin.x = 0;
         thumbailViewFrame.size.width = 1024;
         self.thumbnailView.frame =  thumbailViewFrame;
         
         // Allow it to be expanded again
         self.largeVideoViewExpanded = FALSE;
     }];
#endif
}


#pragma mark - Large video view open animation

- (void) collectionView:(UICollectionView *) collectionView
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
#ifdef FULL_SCREEN_THUMBNAILS
    if (self.isLargeVideoViewExpanded == FALSE)
    {
        [self animateLargeVideoViewRight: nil];
        self.largeVideoViewExpanded = TRUE;
    }
#endif
}

- (IBAction) animateLargeVideoViewRight: (id) sender
{
#ifdef FULL_SCREEN_THUMBNAILS
#ifdef SOUND_ENABLED
    // Play a suitable sound
    NSString *soundPath = [[NSBundle mainBundle] pathForResource: @"RockieTalkie_Slide_Out"
                                                          ofType: @"aif"];
    
    NSURL *soundURL = [NSURL fileURLWithPath: soundPath];
    SystemSoundID sound;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
    AudioServicesPlaySystemSound(sound);
#endif
    
    // Animate the view out onto the screen
    [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
        // Slide on large video view
         CGRect largeVideoPanelFrame = self.largeVideoPanelView.frame;
         largeVideoPanelFrame.origin.x = 0;
         self.largeVideoPanelView.frame =  largeVideoPanelFrame;
         
        // Contract thumbnail view
         CGRect thumbailViewFrame = self.thumbnailView.frame;
         thumbailViewFrame.origin.x = 512;
         thumbailViewFrame.size.width = 512;
         self.thumbnailView.frame =  thumbailViewFrame;
         
     }
                     completion: ^(BOOL finished)
     {
         // Fix on-screen video view
         CGRect largeVideoPanelFrame = self.largeVideoPanelView.frame;
         largeVideoPanelFrame.origin.x = 0;
         self.largeVideoPanelView.frame =  largeVideoPanelFrame;
         
         // Fix contracted thumbnail view
         CGRect thumbailViewFrame = self.thumbnailView.frame;
         thumbailViewFrame.origin.x = 512;
         thumbailViewFrame.size.width = 512;
         self.thumbnailView.frame =  thumbailViewFrame;
     }];
#endif
}

// Temp collection view stuff

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *searchTerm = self.searches[indexPath.section]; FlickrPhoto *photo =
//    self.searchResults[searchTerm][indexPath.row];
//    // 2
//    CGSize retval = photo.thumbnail.size.width > 0 ? photo.thumbnail.size : CGSizeMake(100, 100);
//    retval.height += 35; retval.width += 35; return retval;
//}

- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    return 100;
}

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier: @"ThumbnailCell"
                                                               forIndexPath: indexPath];
    
    return cell;
}

- (UIEdgeInsets) collectionView: (UICollectionView *) collectionView
                         layout: (UICollectionViewLayout*) collectionViewLayout
         insetForSectionAtIndex: (NSInteger) section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

@end
