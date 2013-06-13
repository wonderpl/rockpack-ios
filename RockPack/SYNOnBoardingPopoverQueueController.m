//
//  SYNOnBoardingPopoverQueueController.m
//  rockpack
//
//  Created by Michael Michailidis on 12/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOnBoardingPopoverQueueController.h"
#import "SYNDeviceManager.h"

#define STD_PADDING_DISTANCE 20.0

@interface SYNOnBoardingPopoverQueueController ()

@property (nonatomic, strong) UIView* backgroundView;
@property (nonatomic, strong) NSMutableArray* queue;
@property (nonatomic) NSInteger currentPopoverIndex;
@property (nonatomic, weak) SYNOnBoardingPopoverView* currentlyVisiblePopover;

@end

@implementation SYNOnBoardingPopoverQueueController

@synthesize queue;

-(void)loadView
{
    // background view
    
    CGSize screenSize = [[SYNDeviceManager sharedInstance] currentScreenSize];
    CGRect screenFrame = CGRectMake(0.0, 0.0, screenSize.width, screenSize.height);
    
    self.backgroundView = [[UIView alloc] initWithFrame:screenFrame];
    self.backgroundView.backgroundColor = [UIColor blackColor];
    self.backgroundView.alpha = 0.0;
    
    UIView* mainView = [[UIView alloc] initWithFrame:screenFrame];
    mainView.backgroundColor = [UIColor clearColor];
    [mainView addSubview:self.backgroundView];
    
    self.view = mainView;
}

-(void)addPopover:(SYNOnBoardingPopoverView*)popoverView
{
    if(!self.queue)
        self.queue = [[NSMutableArray alloc] init];
    
    [self.queue addObject:popoverView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    
}

-(void)present
{
    NSLog(@"Starting Q with %i", self.queue.count);
    
    [self presentNextPopover];
}

-(void)presentNextPopover
{
    
    NSLog(@"presentNextPopover: %i", self.queue.count);
    
    
    if(queue.count == 0) // renmove everything
    {
        [UIView animateWithDuration:0.3 animations:^{
            self.backgroundView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }];
    }
    else // go to next popover
    {
        SYNOnBoardingPopoverView* nextPopover = (SYNOnBoardingPopoverView*)[self.queue objectAtIndex:0];
        [self.queue removeObject:nextPopover];
        
        self.currentlyVisiblePopover = nextPopover;
        
    }
}



#pragma mark - Accessor

-(void)setCurrentlyVisiblePopover:(SYNOnBoardingPopoverView *)currentlyVisiblePopover
{
    if(_currentlyVisiblePopover)
    {
        [_currentlyVisiblePopover.okButton removeTarget:self
                                                 action:@selector(okButtonPressed:)
                                       forControlEvents:UIControlEventTouchUpInside];
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.currentlyVisiblePopover.alpha = 0.0;
            
        } completion:^(BOOL finished) {
            
            [_currentlyVisiblePopover removeFromSuperview];
            
            _currentlyVisiblePopover = nil;
            
            self.currentlyVisiblePopover = currentlyVisiblePopover;
            
        }];
        
        return;
        
    }
    
    _currentlyVisiblePopover = currentlyVisiblePopover;
    
    if(_currentlyVisiblePopover) // no nil was passed
    {
        [self placePopoverInView:_currentlyVisiblePopover];
        
        _currentlyVisiblePopover.alpha = 0.0;
        
        [_currentlyVisiblePopover.okButton addTarget:self
                                          action:@selector(okButtonPressed:)
                                forControlEvents:UIControlEventTouchUpInside];
        
        
        BOOL isFirstTime = self.backgroundView.alpha == 0.0;
        [UIView animateWithDuration:0.5 animations:^{
            self.currentlyVisiblePopover.alpha = 1.0;
            if(isFirstTime)
                self.backgroundView.alpha = 0.5;
        }];
    }
    
}


-(void)placePopoverInView:(SYNOnBoardingPopoverView*)popover
{
    
    
    CGRect panelFrame = popover.frame;
    
    switch (popover.direction) {
            
        case PointingDirectionNone: // center in view
            panelFrame.origin.x = self.view.frame.size.width * 0.5 - panelFrame.size.width * 0.5;
            panelFrame.origin.y = self.view.frame.size.height * 0.5 - panelFrame.size.height * 0.5;
            break;
            
        case PointingDirectionUp:
            panelFrame.origin.x = popover.pointRect.origin.x + (popover.pointRect.size.width * 0.5) - 40.0;
            panelFrame.origin.y = popover.pointRect.origin.y + popover.pointRect.size.height + STD_PADDING_DISTANCE;
            
            break;
            
        case PointingDirectionDown:
            panelFrame.origin.x = popover.pointRect.origin.x + (popover.pointRect.size.height * 0.5) - panelFrame.size.width + STD_PADDING_DISTANCE;
            panelFrame.origin.y = popover.pointRect.origin.y - panelFrame.size.height - STD_PADDING_DISTANCE;
            break;
            
        case PointingDirectionLeft:
            panelFrame.origin.y = popover.pointRect.origin.y - STD_PADDING_DISTANCE;
            panelFrame.origin.x = popover.pointRect.origin.x + popover.pointRect.size.width + STD_PADDING_DISTANCE;
            break;
            
        case PointingDirectionRight:
            panelFrame.origin.y = popover.pointRect.origin.y - STD_PADDING_DISTANCE;
            panelFrame.origin.x = popover.pointRect.origin.x - panelFrame.size.width - STD_PADDING_DISTANCE;
            break;
            
    }
    
    popover.frame = panelFrame;
    
    [self.view addSubview:popover];
}



-(void)okButtonPressed:(UIButton*)buttonPressed
{
    [self presentNextPopover];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
