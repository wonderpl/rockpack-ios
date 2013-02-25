//
//  SYNVideoQueueViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 25/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNVideoQueueViewController.h"
#import "SYNVideoQueueView.h"

@interface SYNVideoQueueViewController ()

@end

@implementation SYNVideoQueueViewController

-(void)loadView
{
    self.view = [[SYNVideoQueueView alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*

#pragma mark - Add Videos

- (void) animateVideoAdditionToVideoQueue: (VideoInstance *) videoInstance
{
#ifdef SOUND_ENABLED
    //    // Play a suitable sound
    //    NSString *soundPath = [[NSBundle mainBundle] pathForResource: @"Select"
    //                                                          ofType: @"aif"];
    //
    //    NSURL *soundURL = [NSURL fileURLWithPath: soundPath];
    //    SystemSoundID sound;
    //    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
    //    AudioServicesPlaySystemSound(sound);
#endif
    
    // If this is the first thing we are adding then fade out the message
    if (SYNVideoSelection.sharedVideoSelectionArray.count == 0)
    {
        newButton.enabled = TRUE;
        newButton.selected = TRUE;
        newButton.enabled = TRUE;
        
        [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^
         {
             // Contract thumbnail view
             messageView.alpha = 0.0f;
             
         }
                         completion: ^(BOOL finished)
         {
             
         }];
    }
    
    
    // OK, here goes
    
    // First, increase the size of the view by the size of the new cell to be added (+margin)
    CGRect videoQueueViewFrame = self.videoQueueCollectionView.frame;
    videoQueueViewFrame.size.width += 142;
    
    self.videoQueueCollectionView.frame = videoQueueViewFrame;
    
    [SYNVideoSelection.sharedVideoSelectionArray addObject: videoInstance];
    
    [self.videoQueueCollectionView reloadData];
    
    [self performSelector: @selector(animateVideoAdditionToVideoQueue2:)
               withObject: videoInstance
               afterDelay: 0.0f];
}

- (void) animateVideoAdditionToVideoQueue2: (VideoInstance *) videoInstance
{
    
    
    if (self.videoQueueCollectionView.contentSize.width + 15 > kVideoQueueWidth + 142)
    {
        CGPoint contentOffset = self.videoQueueCollectionView.contentOffset;
        contentOffset.x = self.videoQueueCollectionView.contentSize.width - kVideoQueueWidth;
        self.videoQueueCollectionView.contentOffset = contentOffset;
    }
    
    
    // Animate the view out onto the screen
    [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                          delay: 0.5f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         // Slide origin back
         CGRect videoQueueCollectionViewFrame = self.videoQueueCollectionView.frame;
         videoQueueCollectionViewFrame.origin.x -= 142;
         
         CGPoint contentOffset = self.videoQueueCollectionView.contentOffset;
         
         if (self.videoQueueCollectionView.contentSize.width > kVideoQueueWidth)
         {
             videoQueueCollectionViewFrame.origin.x = kVideoQueueOffsetX;
             videoQueueCollectionViewFrame.size.width = kVideoQueueWidth;
             
             
             contentOffset.x = self.videoQueueCollectionView.contentSize.width - kVideoQueueWidth + 15;
         }
         
         self.videoQueueCollectionView.contentOffset = contentOffset;
         self.videoQueueCollectionView.frame = videoQueueCollectionViewFrame;
     }
                     completion: ^(BOOL finished)
     {
         
     }];
}
 
 */

@end
