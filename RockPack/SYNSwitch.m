//
//  SYNSwitch.m
//  synswitch
//
//  Created by Nick Banks on 19/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNSwitch.h"
#import "AppConstants.h"
#import "UIFont+SYNFont.h"

#define kSwitchTextY 16.0

@interface SYNSwitch () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIImageView *thumbView;
@property (nonatomic, assign) BOOL ignoreTap;


@end


@implementation SYNSwitch

@synthesize textLeft, textRight;

@synthesize on = _on;


- (id) initWithLeftText:(NSString*)lText andRightText:(NSString*)rText
{
    if(self = [super init])
    {
        [self setup];
        
        self.textLeft = lText;
        self.textRight = rText;
        
    }
    return self;
}

- (void) setup
{
	self.backgroundColor = [UIColor clearColor];
    
    self.userInteractionEnabled = YES;
    
    self.on = FALSE;

    self.backgroundView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"SliderBackground.png"]];
    
    self.frame = self.backgroundView.frame;
    
    
    self.thumbView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"SliderThumb.png"]];
    
    [self addSubview: self.backgroundView];
    [self addSubview: self.thumbView];
    
    
    
//	UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
//                                                                                            action:@selector(thumbDragged:)];
//	panGestureRecognizer.delegate = self;
//	[self addGestureRecognizer: panGestureRecognizer];
    
    
    
    // == Labels
    
    rockpackFont = [UIFont rockpackFontOfSize:14.0];
    
    leftLabel = [[UILabel alloc] init];
    leftLabel.textAlignment = NSTextAlignmentRight;
    leftLabel.font = rockpackFont;
    leftLabel.userInteractionEnabled = NO;
    leftLabel.textColor = [UIColor lightGrayColor];
    leftLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:leftLabel];
    
    rightLabel = [[UILabel alloc] init];
    rightLabel.textAlignment = NSTextAlignmentLeft;
    rightLabel.font = rockpackFont;
    rightLabel.userInteractionEnabled = NO;
    rightLabel.textColor = [UIColor lightGrayColor];
    rightLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:rightLabel];
    
}

-(void)setTextLeft:(NSString *)newTextLeft
{
    CGSize fitSize = [newTextLeft sizeWithFont:rockpackFont];
    CGFloat pointX = self.backgroundView.frame.origin.x - 7.0 - fitSize.width;
    leftLabel.frame = CGRectMake(pointX, kSwitchTextY, fitSize.width, fitSize.height);
    leftLabel.text = newTextLeft;
}

-(void)setTextRight:(NSString *)newTextRight
{
    CGSize fitSize = [newTextRight sizeWithFont:rockpackFont];
    CGFloat pointX = self.backgroundView.frame.origin.x + 5.0 + self.backgroundView.frame.size.width;
    rightLabel.frame = CGRectMake(pointX, kSwitchTextY, fitSize.width, fitSize.height);
    rightLabel.text = newTextRight;
}

#pragma mark - Interaction

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
        
        // Send off an event *before* starting the switch animation
        [self sendActionsForControlEvents: UIControlEventValueChanged];
        
        CGRect currentFrame = self.thumbView.frame;
        currentFrame.origin.x = xOffset;
        
        [UIView animateWithDuration: kSwitchLabelAnimation
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
         }];
    }
}

@end
