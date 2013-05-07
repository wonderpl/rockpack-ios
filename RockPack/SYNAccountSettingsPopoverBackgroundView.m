#import "SYNAccountSettingsPopoverBackgroundView.h"

// Predefined arrow image width and height
#define ARROW_WIDTH 35.0 // will stretch the image
#define ARROW_HEIGHT 20.0

// Predefined content insets
#define TOP_CONTENT_INSET 8
#define LEFT_CONTENT_INSET 8
#define BOTTOM_CONTENT_INSET 8
#define RIGHT_CONTENT_INSET 8

#pragma mark - Private interface

@interface SYNAccountSettingsPopoverBackgroundView ()

@end

#pragma mark - Implementation

@implementation SYNAccountSettingsPopoverBackgroundView

@synthesize arrowOffset = _arrowOffset;
@synthesize arrowDirection = _arrowDirection;


#pragma mark - Overriden class methods

// The width of the arrow triangle at its base.
+ (CGFloat) arrowBase 
{
    return ARROW_WIDTH;
}


// The height of the arrow (measured in points) from its base to its tip.
+ (CGFloat) arrowHeight
{
    return ARROW_HEIGHT;
}


// The insets for the content portion of the popover.
+ (UIEdgeInsets) contentViewInsets
{
    return UIEdgeInsetsMake(TOP_CONTENT_INSET, LEFT_CONTENT_INSET, BOTTOM_CONTENT_INSET, RIGHT_CONTENT_INSET);
}


#pragma mark - Initialization

- (id) initWithFrame: (CGRect) frame 
{    
    if (self = [super initWithFrame: frame])
    {
        UIImage *popoverBackgroundImage = [[UIImage imageNamed: @"AccountSettingsView.png"] resizableImageWithCapInsets: UIEdgeInsetsMake(49, 46, 49, 45)];
        self.popoverBackgroundImageView = [[UIImageView alloc] initWithImage: popoverBackgroundImage];
        [self addSubview: self.popoverBackgroundImageView];
    }
    
    return self;
}


#pragma mark - Layout subviews

- (void) layoutSubviews
{    
    [super layoutSubviews];
    
    CGFloat popoverImageOriginX = 0;
    CGFloat popoverImageOriginY = 0;
    
    CGFloat popoverImageWidth = self.bounds.size.width;
    CGFloat popoverImageHeight = self.bounds.size.height;
    
    self.popoverBackgroundImageView.frame = CGRectMake(popoverImageOriginX, popoverImageOriginY, popoverImageWidth, popoverImageHeight);
}

@end
