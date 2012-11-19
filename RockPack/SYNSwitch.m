//
//  SYNSwitch.m
//  synswitch
//
//  Created by Nick Banks on 19/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNSwitch.h"

@interface SYNSwitch () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIImageView *thumbView;
@property (nonatomic, assign) BOOL ignoreTap;

@end


@implementation SYNSwitch

@synthesize on = _on;

- (id) initWithFrame: (CGRect) frame
{
	if ((self = [super initWithFrame: frame]))
	{
		[self setup];
	}
    
	return self;
}

- (void) setup
{
	self.backgroundColor = [UIColor clearColor];
    
    self.on = FALSE;

    self.backgroundView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"Background.png"]];
    self.thumbView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"Thumb.png"]];
    
    [self addSubview: self.backgroundView];
    [self addSubview: self.thumbView];
    
	// tap gesture for toggling the switch
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(tapped:)];
	tapGestureRecognizer.delegate = self;
	[self addGestureRecognizer: tapGestureRecognizer];
    
	// pan gesture for moving the switch knob manually
	UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(thumbDragged:)];
	panGestureRecognizer.delegate = self;
	[self addGestureRecognizer: panGestureRecognizer];
}

#pragma mark -
#pragma mark Interaction

- (void) tapped: (UITapGestureRecognizer *) gesture
{
    // Check to see if we should ignore this tap (i.e. if we are currently animating)
	if (self.ignoreTap) return;
	
    // If the tap is over then toggle the switch
	if (gesture.state == UIGestureRecognizerStateEnded)
    {
        // Toggle state
		[self setOn: !self.on
           animated: YES];
    }
}

- (void) thumbDragged: (UIPanGestureRecognizer *) gesture
{
	if (gesture.state == UIGestureRecognizerStateBegan)
	{
		// setup by turning off the manual clipping of the toggleLayer and setting up a layer mask.
	}
	else if (gesture.state == UIGestureRecognizerStateChanged)
	{
		CGPoint translation = [gesture translationInView: self];
        
		// move the toggleLayer using the translation of the gesture, keeping it inside the outline.
        CGRect currentFrame = self.thumbView.frame;
		CGFloat newX = currentFrame.origin.x + translation.x;
		if (newX < kOffXOffset) newX = 0;
		if (newX > kOnXOffset) newX = kOnXOffset;

        currentFrame.origin.x = newX;
        self.thumbView.frame = currentFrame;
        
		[gesture setTranslation: CGPointZero
                         inView: self];
	}
	else if (gesture.state == UIGestureRecognizerStateEnded)
	{
		// flip the switch to on or off depending on which half it ends at
        CGRect currentFrame = self.thumbView.frame;
        
		[self setOn: (currentFrame.origin.x > kOnXThreshold)
           animated: YES
        forceToggle: YES];
	}
    
    // Send appropriate actions
	CGPoint locationOfTouch = [gesture locationInView: self];
    
	if (CGRectContainsPoint(self.bounds, locationOfTouch))
    {
		[self sendActionsForControlEvents:UIControlEventTouchDragInside];
    }
	else
    {
		[self sendActionsForControlEvents:UIControlEventTouchDragOutside];
    }
}

- (void) touchesBegan: (NSSet *) touches
            withEvent: (UIEvent *) event
{
	if (self.ignoreTap) return;
    
	[super touchesBegan: touches
              withEvent: event];
    
	[self sendActionsForControlEvents: UIControlEventTouchDown];
}

- (void) touchesEnded: (NSSet *) touches
            withEvent: (UIEvent *) event
{
	[super touchesEnded: touches
              withEvent: event];
    
	[self sendActionsForControlEvents: UIControlEventTouchUpInside];
}

- (void) touchesCancelled: (NSSet *) touches
                withEvent: (UIEvent *) event
{
	[super touchesCancelled: touches
                  withEvent: event];
    
	[self sendActionsForControlEvents: UIControlEventTouchUpOutside];
}


#pragma mark UIGestureRecognizerDelegate

- (BOOL) gestureRecognizerShouldBegin: (UIGestureRecognizer *) gestureRecognizer;
{
    // Only begin gesture if we are not ignoring taps
	return !self.ignoreTap;
}

#pragma mark Setters/Getters

- (void) setOn: (BOOL) newOn
{
	[self setOn: newOn
       animated: NO];
}

- (void) setOn: (BOOL) newOn
      animated: (BOOL) animated
{
    [self setOn: newOn
       animated: animated
    forceToggle: NO];
}

- (void) setOn: (BOOL) newOn
      animated: (BOOL) animated
   forceToggle: (BOOL) forceToggle
{
    if (self.on != newOn || forceToggle)
    {
        	self.ignoreTap = YES;
        	_on = newOn;
        
        CGFloat xOffset = kOffXOffset;
        
        // If the switch is now ON, then move the switch to the right
        if (self.on == TRUE)
        {
            xOffset = kOnXOffset;
        }
        
        CGRect currentFrame = self.thumbView.frame;
        currentFrame.origin.x = xOffset;
        
        [UIView animateWithDuration: 0.25f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^
         {
             // Contract thumbnail view
             self.thumbView.frame = currentFrame;
             
         }
         completion: ^(BOOL finished)
         {
             self.ignoreTap = NO;
             
             [self sendActionsForControlEvents: UIControlEventValueChanged];
         }];
    }
}

@end
