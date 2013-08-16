//
//  SYNOnBoardingPopoverQueueController.m
//  rockpack
//
//  Created by Michael Michailidis on 12/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOnBoardingPopoverQueueController.h"
#import "SYNDeviceManager.h"
#import "UIColor+SYNColor.h"
#import "SYNAppDelegate.h"
#import "SYNMasterViewController.h"

#define STD_PADDING_DISTANCE 18.0

@interface SYNOnBoardingPopoverQueueController ()

@property (nonatomic, strong) UIView* backgroundView;
@property (nonatomic, strong) NSMutableArray* queue;
@property (nonatomic) NSInteger currentPopoverIndex;
@property (nonatomic, weak) SYNOnBoardingPopoverView* currentlyVisiblePopover;
@property (nonatomic, weak) UIView* specialSlice;

@end

@implementation SYNOnBoardingPopoverQueueController

@synthesize queue;

+ (id) queueController
{
    return [[self alloc] init];
}
-(void)loadView
{
    // background view
    
    CGSize screenSize = [[SYNDeviceManager sharedInstance] currentScreenSize];
    CGRect screenFrame = CGRectZero;
    screenFrame.size = screenSize;
    
    
    
    self.backgroundView = [[UIView alloc] initWithFrame:screenFrame];
    // self.backgroundView.backgroundColor = [UIColor redColor];
    self.backgroundView.alpha = 0.0;
    self.backgroundView.userInteractionEnabled = YES;
    
    
    // Tap outside of view to close popover
    UITapGestureRecognizer *tapOutside =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(okButtonPressed:)];
    [self.backgroundView addGestureRecognizer:tapOutside];
    
    
    UIView* mainView = [[UIView alloc] initWithFrame:screenFrame];
    mainView.backgroundColor = [UIColor clearColor];
    [mainView addSubview:self.backgroundView];
    
    mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = mainView;
}

-(void)addPopover:(SYNOnBoardingPopoverView*)popoverView
{
    if(!self.queue)
        self.queue = [[NSMutableArray alloc] init];
    
    NSLog(@"Adding in Q %@", popoverView);
    [self.queue addObject:popoverView];
    
    UITapGestureRecognizer *tapOutside =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(okButtonPressed:)];
    [popoverView addGestureRecognizer:tapOutside];
}



-(void)present
{
    if(queue.count == 0)
        return;
    
    if(!self.view.superview) // if it is not on screen yet
    {
        SYNAppDelegate* appDelegate = (SYNAppDelegate*)[UIApplication sharedApplication].delegate;
        
        [appDelegate.masterViewController addChildViewController:self];
        [appDelegate.masterViewController.view addSubview:self.view];
        
        [self presentNextPopover];
    }
    
    
    
}

-(void)presentNextPopover
{
    
   
    if(queue.count == 0) // renmove everything
    {
        [UIView animateWithDuration:0.3 animations:^{
            self.currentlyVisiblePopover.alpha = 0.0;
            self.currentlyVisiblePopover.arrow.alpha = 0.0;
            
            self.backgroundView.alpha = 0.0;
        } completion:^(BOOL finished) {
            
            [self.currentlyVisiblePopover removeFromSuperview];
            [self.currentlyVisiblePopover.arrow removeFromSuperview];
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }];
    }
    else // go to next popover
    {
        
        SYNOnBoardingPopoverView* nextPopover = (SYNOnBoardingPopoverView*)(self.queue)[0];
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
            self.currentlyVisiblePopover.arrow.alpha = 0.0;
            
        } completion:^(BOOL finished) {
            
            [_currentlyVisiblePopover.arrow removeFromSuperview];
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
        
        [self createBG];
        
        _currentlyVisiblePopover.alpha = 0.0;
        _currentlyVisiblePopover.arrow.alpha = 0.0;
        
        [_currentlyVisiblePopover.okButton addTarget:self
                                          action:@selector(okButtonPressed:)
                                forControlEvents:UIControlEventTouchUpInside];
        
        
        BOOL isFirstTime = self.backgroundView.alpha == 0.0;
        [UIView animateWithDuration:0.5 animations:^{
            self.currentlyVisiblePopover.alpha = 1.0;
            self.currentlyVisiblePopover.arrow.alpha = 1.0;
            
            if(isFirstTime) {
                self.backgroundView.alpha = 0.5;
            }
            
        }];
    }
    
}

-(void)createBG
{
    for (UIView* view in self.backgroundView.subviews) // clean from existing
        [view removeFromSuperview];
    
    if(_currentlyVisiblePopover.direction != PointingDirectionNone)
        [self createBGSlicesForPopover:_currentlyVisiblePopover];
    else
        [self createBGForPopover:_currentlyVisiblePopover];
}
-(void)placePopoverInView:(SYNOnBoardingPopoverView*)popover
{
    
    CGSize screenSize = [[SYNDeviceManager sharedInstance] currentScreenSize];
    CGRect panelFrame = popover.frame;
    CGRect arrowFrame = popover.arrow.frame;
    CGFloat midPointX = popover.pointRect.origin.x + (popover.pointRect.size.width * 0.5);
    CGFloat midPointY = popover.pointRect.origin.y + (popover.pointRect.size.height * 0.5);
    
    popover.autoresizingMask = UIViewAutoresizingNone;
    
    switch (popover.direction) {
            
        case PointingDirectionNone: // center in view
            panelFrame.origin.x = screenSize.width * 0.5 - panelFrame.size.width * 0.5;
            panelFrame.origin.y = screenSize.height * 0.5 - panelFrame.size.height * 0.5;
            
            popover.autoresizingMask |= UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
            break;
            
        case PointingDirectionUp:
            panelFrame.origin.x = midPointX - 40.0;
            panelFrame.origin.y = popover.pointRect.origin.y + popover.pointRect.size.height + STD_PADDING_DISTANCE;
            
            if(panelFrame.origin.x < STD_PADDING_DISTANCE)
                panelFrame.origin.x = STD_PADDING_DISTANCE;
            else if(panelFrame.origin.x + panelFrame.size.width > screenSize.width - 10.0)
                panelFrame.origin.x = screenSize.width -  panelFrame.size.width - 10.0;
            
            arrowFrame.origin.x = midPointX - arrowFrame.size.width * 0.5;
            arrowFrame.origin.y = panelFrame.origin.y - arrowFrame.size.height;
            
            popover.autoresizingMask |= UIViewAutoresizingFlexibleTopMargin;
            
            break;
            
        case PointingDirectionDown:
            panelFrame.origin.x = midPointX - panelFrame.size.width + 40.0;
            panelFrame.origin.y = popover.pointRect.origin.y - panelFrame.size.height - STD_PADDING_DISTANCE;
            
            if(panelFrame.origin.x < STD_PADDING_DISTANCE)
                panelFrame.origin.x = STD_PADDING_DISTANCE;
            else if(panelFrame.origin.x + panelFrame.size.width > screenSize.width - 10.0)
                panelFrame.origin.x = screenSize.width -  panelFrame.size.width - 10.0;
            
            arrowFrame.origin.x = midPointX - arrowFrame.size.width * 0.5;
            arrowFrame.origin.y = panelFrame.origin.y + panelFrame.size.height;
            
            popover.autoresizingMask |= UIViewAutoresizingFlexibleBottomMargin;
            
            break;
            
        case PointingDirectionLeft:
            panelFrame.origin.x = popover.pointRect.origin.x + popover.pointRect.size.width + STD_PADDING_DISTANCE;
            panelFrame.origin.y = midPointY - 40.0;
            
            
            if(panelFrame.origin.y < STD_PADDING_DISTANCE)
                panelFrame.origin.y = STD_PADDING_DISTANCE;
            else if(panelFrame.origin.y + panelFrame.size.height > screenSize.height - STD_PADDING_DISTANCE)
                panelFrame.origin.y = screenSize.width - panelFrame.size.height - STD_PADDING_DISTANCE;
            
            arrowFrame.origin.x = panelFrame.origin.x - arrowFrame.size.width;
            arrowFrame.origin.y = midPointY - arrowFrame.size.height * 0.5;
            
            popover.autoresizingMask |= UIViewAutoresizingFlexibleRightMargin;
          
            
            break;
            
        case PointingDirectionRight:
            panelFrame.origin.y = popover.pointRect.origin.y - STD_PADDING_DISTANCE;
            panelFrame.origin.x = popover.pointRect.origin.x - panelFrame.size.width - STD_PADDING_DISTANCE;
            
            if(panelFrame.origin.y < STD_PADDING_DISTANCE)
                panelFrame.origin.y = STD_PADDING_DISTANCE;
            else if(panelFrame.origin.y + panelFrame.size.height > screenSize.height - STD_PADDING_DISTANCE)
                panelFrame.origin.y = screenSize.width - panelFrame.size.height - STD_PADDING_DISTANCE;
            
            arrowFrame.origin.x = panelFrame.origin.x + panelFrame.size.width;
            arrowFrame.origin.y = midPointY - arrowFrame.size.height * 0.5;
            
            popover.autoresizingMask |= UIViewAutoresizingFlexibleLeftMargin;
            
            break;
            
    }
    
    // correct frame
    
    popover.frame = panelFrame;
    
    popover.arrow.frame = arrowFrame;
    popover.arrow.alpha = 0.0;
    [self.view addSubview:popover];
    [self.view addSubview:popover.arrow];

    
    
        
    
}

-(void)createBGForPopover:(SYNOnBoardingPopoverView*)popover // single BG for centered 
{
    UIView* centeredBGView = [[UIView alloc] initWithFrame:self.backgroundView.frame];
    centeredBGView.backgroundColor = [UIColor blackColor];
    [self.backgroundView addSubview:centeredBGView];
}


-(void)createBGSlicesForPopover:(SYNOnBoardingPopoverView*)popover
{
    UIView* slice;
    for (int c = 0; c < 9; c++)
    {
        slice = [[UIView alloc] initWithFrame:CGRectZero];
        [self.backgroundView addSubview:slice];
        
    }
    
    [self positionBGSlicesForPopover:popover];
}

-(void)positionBGSlicesForPopover:(SYNOnBoardingPopoverView*)popover
{
    CGSize screenSize = [[SYNDeviceManager sharedInstance] currentScreenSize];
    
    if(self.backgroundView.subviews.count == 1)
    {
        UIView* subBGView = self.backgroundView.subviews[0];
        subBGView.frame = CGRectMake(0.0, 0.0, screenSize.width, screenSize.height);
    }
    else if(self.backgroundView.subviews.count == 9)
    {
        
        
        float px[4] = {
            0.0f, popover.pointRect.origin.x,
            popover.pointRect.origin.x + popover.pointRect.size.width, screenSize.width
        };
        
        float py[4] = {
            0.0f, popover.pointRect.origin.y,
            popover.pointRect.origin.y + popover.pointRect.size.height, screenSize.height
        };
        
        
        float current_x = 0.0f;
        float current_y = 0.0f;
        float current_w = 0.0f;
        float current_h = 0.0f;
        
        UIView* currentSlice;
        
        for (int i = 0; i < 3; i++) {
            
            
            current_y = py[i];
            
            for (int j = 0; j < 3; j++) {
                
                current_x = px[j];
                
                current_w = px[j+1] - current_x;
                
                current_h = py[i+1] - current_y;
                
                currentSlice = self.backgroundView.subviews[(i * 3) + j];
                
                currentSlice.frame = CGRectMake(current_x, current_y, current_w, current_h);
                
                if(i == 1 && j == 1) // special interest slice
                {
                    
                    self.specialSlice = currentSlice;
                    currentSlice.backgroundColor = [UIColor clearColor];
                    
                    UITapGestureRecognizer* tpRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                   action:@selector(performAction:)];
                    
                    UILongPressGestureRecognizer* lpRecogniser = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                               action:@selector(performAction:)];
                    [currentSlice addGestureRecognizer:tpRecogniser];
                    [currentSlice addGestureRecognizer:lpRecogniser];
                }
                else
                {
                    currentSlice.backgroundColor = [UIColor blackColor];
                }
                
            }
        }
    }

    
    
    
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    
    
    
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
   
    CGRect newFrame = CGRectZero;
    
    
    
    newFrame.size = [[SYNDeviceManager sharedInstance] currentScreenSize];
    
    self.view.frame = newFrame;
    self.backgroundView.frame = self.view.frame;
    
    [self positionBGSlicesForPopover:self.currentlyVisiblePopover];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    
}
-(void)performAction:(UIGestureRecognizer*)recogniser
{
    if(self.currentlyVisiblePopover.action)
        self.currentlyVisiblePopover.action(recogniser);
    
    if([recogniser isKindOfClass:[UITapGestureRecognizer class]])
    {
        [self presentNextPopover];
    }
    else if ([recogniser isKindOfClass:[UILongPressGestureRecognizer class]] &&
             ((UILongPressGestureRecognizer*)recogniser).state == UIGestureRecognizerStateEnded)
    {
        [self presentNextPopover];
    }
    
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
