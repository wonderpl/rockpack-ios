//
//  SYNVideoQueueViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 25/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNVideoQueueViewController.h"
#import "VideoInstance.h"
#import "SYNVideoSelection.h"
#import "AppConstants.h"

@interface SYNVideoQueueViewController ()

@property (nonatomic, readonly) SYNVideoQueueView* videoQueueView;

@end

@implementation SYNVideoQueueViewController

@synthesize delegate;
@synthesize videoQueueView;

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


#pragma mark - Accessors

-(void)setDelegate:(id<SYNVideoQueueDelegate, UICollectionViewDataSource, UICollectionViewDelegate>)del
{
    delegate = del;
    
    videoQueueView.videoQueueCollectionView.delegate = self.delegate;
    videoQueueView.videoQueueCollectionView.dataSource = self.delegate;
    
    
    [videoQueueView.deleteButton addTarget:delegate action: @selector(clearVideoQueue) forControlEvents: UIControlEventTouchUpInside];
    
    [videoQueueView.channelButton addTarget:self.delegate action: @selector(createChannelFromVideoQueue) forControlEvents: UIControlEventTouchUpInside];
}

-(void)setHighlighted:(BOOL)value
{
    [videoQueueView setHighlighted:value];
}


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
        videoQueueView.channelButton.enabled = TRUE;
        videoQueueView.channelButton.selected = TRUE;
        videoQueueView.channelButton.enabled = TRUE;
        
        [videoQueueView showMessageView:YES];
    }
    
    
    
    // First, increase the size of the view by the size of the new cell to be added (+margin)
    CGRect videoQueueViewFrame = videoQueueView.videoQueueCollectionView.frame;
    videoQueueViewFrame.size.width += 142;
    
    videoQueueView.videoQueueCollectionView.frame = videoQueueViewFrame;
    
    [SYNVideoSelection.sharedVideoSelectionArray addObject: videoInstance];
    
    [videoQueueView.videoQueueCollectionView reloadData];
    
    [self performSelector: @selector(animateVideoAdditionToVideoQueue2:)
               withObject: videoInstance
               afterDelay: 0.0f];
}

- (void) animateVideoAdditionToVideoQueue2: (VideoInstance *) videoInstance
{
    
    
    if (videoQueueView.videoQueueCollectionView.contentSize.width + 15 > kVideoQueueWidth + 142)
    {
        CGPoint contentOffset = videoQueueView.videoQueueCollectionView.contentOffset;
        contentOffset.x = videoQueueView.videoQueueCollectionView.contentSize.width - kVideoQueueWidth;
        videoQueueView.videoQueueCollectionView.contentOffset = contentOffset;
    }
    
    
    // Animate the view out onto the screen
    [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                          delay: 0.5f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
         // Slide origin back
         CGRect videoQueueCollectionViewFrame = videoQueueView.videoQueueCollectionView.frame;
         videoQueueCollectionViewFrame.origin.x -= 142;
         
         CGPoint contentOffset = videoQueueView.videoQueueCollectionView.contentOffset;
         
         if (videoQueueView.videoQueueCollectionView.contentSize.width > kVideoQueueWidth)
         {
             videoQueueCollectionViewFrame.origin.x = kVideoQueueOffsetX;
             videoQueueCollectionViewFrame.size.width = kVideoQueueWidth;
             
             
             contentOffset.x = videoQueueView.videoQueueCollectionView.contentSize.width - kVideoQueueWidth + 15;
         }
         
         videoQueueView.videoQueueCollectionView.contentOffset = contentOffset;
         videoQueueView.videoQueueCollectionView.frame = videoQueueCollectionViewFrame;
     }
                     completion: ^(BOOL finished) {
         
     }];
}
 
-(SYNVideoQueueView*)videoQueueView
{
    return (SYNVideoQueueView*)self.view;
}

@end
