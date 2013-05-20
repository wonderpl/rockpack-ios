//
//  SYNAddButtonControl.m
//  rockpack
//
//  Created by Michael Michailidis on 16/05/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAddButtonControl.h"
#import "SYNAppDelegate.h"
#import "AppConstants.h"

@implementation SYNAddButtonControl

@synthesize active = _active;

+(id)button
{
    return [[self alloc] initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        buttonImageInactive = [UIImage imageNamed:@"ButtonAddToChannelInactive"];
        
        buttonImageInactiveHighlighted = [UIImage imageNamed:@"ButtonAddToChannelInactiveHighlighted"];
        
        buttonImageActive = [UIImage imageNamed:@"ButtonAddToChannelActive"];
        
        buttonImageActiveHighlighted = [UIImage imageNamed:@"ButtonAddToChannelActiveHighlighted"];
        
        
        
        button.frame = CGRectMake(0.0, 0.0, buttonImageInactive.size.width, buttonImageInactive.size.height);
        
        
        [button addTarget:self
                   action:@selector(buttonPressed:)
         forControlEvents:UIControlEventTouchUpInside];
        
        [appDelegate.videoQueue addObserver:self
                                 forKeyPath:@"isEmpty"
                                    options:NSKeyValueObservingOptionNew
                                    context:nil];
        
        self.frame = button.frame;
        
        [self addSubview:button];
        
        // set the first time active or incative //
        
        if(appDelegate.videoQueue.isEmpty)
        {
            self.active = NO;
        }
        else
        {
            self.active = YES;
        }
        
        
    }
    return self;
}

#pragma Active/Inactive


-(void)setActive:(BOOL)active
{
    
    _active = active;
    
    if(!_active)
    {
        [button setImage:buttonImageInactive forState:UIControlStateNormal];
        [button setImage:buttonImageInactive forState:UIControlStateDisabled];
        [button setImage:buttonImageInactiveHighlighted forState:UIControlStateHighlighted];
        button.enabled = NO;
    }
    else
    {
        [button setImage:buttonImageActive forState:UIControlStateNormal];
        [button setImage:buttonImageActive forState:UIControlStateDisabled];
        [button setImage:buttonImageActiveHighlighted forState:UIControlStateHighlighted];
        button.enabled = YES;
    }
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    button.selected = selected;
    
}

-(BOOL)selected
{
    return button.selected;
}

- (void) observeValueForKeyPath: (NSString *) keyPath
                       ofObject: (id) object
                         change: (NSDictionary *) change
                        context: (void *) context
{
    
    if(object == appDelegate.videoQueue)
    {
        self.active = !appDelegate.videoQueue.isEmpty;
        button.enabled = self.active;
    }
    
    
}

#pragma mark - Click Listener

-(void)buttonPressed:(UIButton*)buttonPressed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNoteAddToChannelRequest
                                                        object:self];
}


#pragma mark - UIControl Methods

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [button addTarget:target action:action forControlEvents:controlEvents];
    
}

- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [button removeTarget:target action:action forControlEvents:controlEvents];
    
}

- (NSArray *)actionsForTarget:(id)target forControlEvent:(UIControlEvents)controlEvent
{
    return [button actionsForTarget:target forControlEvent:controlEvent];
}

#pragma mark - Dealloc

-(void)dealloc
{
    [appDelegate.videoQueue removeObserver:self
                                forKeyPath:@"isEmpty"
                                   context:nil];
}

@end
