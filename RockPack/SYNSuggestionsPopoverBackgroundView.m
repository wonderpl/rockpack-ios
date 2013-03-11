#import "SYNSuggestionsPopoverBackgroundView.h"

// Predefined arrow image width and height
#define ARROW_WIDTH 35.0 // will stretch the image
#define ARROW_HEIGHT 20.0

// Predefined content insets
#define TOP_CONTENT_INSET 8
#define LEFT_CONTENT_INSET 8
#define BOTTOM_CONTENT_INSET 8
#define RIGHT_CONTENT_INSET 8

#pragma mark - Private interface

@interface SYNSuggestionsPopoverBackgroundView ()
{    
    UIImage *_topArrowImage;
    UIImage *_rightArrowImage;
}

@end

#pragma mark - Implementation

@implementation SYNSuggestionsPopoverBackgroundView

@synthesize arrowOffset = _arrowOffset, arrowDirection = _arrowDirection, popoverBackgroundImageView = _popoverBackgroundImageView, arrowImageView = _arrowImageView;

#pragma mark - Overriden class methods

// The width of the arrow triangle at its base.
+ (CGFloat)arrowBase 
{
    return ARROW_WIDTH;
}

// The height of the arrow (measured in points) from its base to its tip.
+ (CGFloat)arrowHeight
{
    return ARROW_HEIGHT;
}

// The insets for the content portion of the popover.
+ (UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsMake(TOP_CONTENT_INSET, LEFT_CONTENT_INSET, BOTTOM_CONTENT_INSET, RIGHT_CONTENT_INSET);
}

#pragma mark - Custom setters for updating layout

// Whenever arrow changes direction or position layout subviews will be called in order to update arrow and backgorund frames

-(void) setArrowOffset:(CGFloat)arrowOffset
{
    _arrowOffset = arrowOffset;
    [self setNeedsLayout];
}

-(void) setArrowDirection:(UIPopoverArrowDirection)arrowDirection
{
    _arrowDirection = arrowDirection;
    [self setNeedsLayout];
}

#pragma mark - Initialization

-(id)initWithFrame:(CGRect)frame 
{    
    if (self = [super initWithFrame:frame])
    {
        _topArrowImage = [UIImage imageNamed:@"popover-black-top-arrow-image.png"];
        _rightArrowImage = [UIImage imageNamed:@"popover-black-right-arrow-image.png"];
        
        UIImage *popoverBackgroundImage = [[UIImage imageNamed:@"popover-black-bcg-image.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(49, 46, 49, 45)];
        self.popoverBackgroundImageView = [[UIImageView alloc] initWithImage:popoverBackgroundImage];
        [self addSubview:self.popoverBackgroundImageView];
        
        self.arrowImageView = [[UIImageView alloc] init];
        [self addSubview:self.arrowImageView];
    }
    
    return self;
}

#pragma mark - Layout subviews

-(void)layoutSubviews
{    
    [super layoutSubviews];
    
    CGFloat popoverImageOriginX = 0;
    CGFloat popoverImageOriginY = 0;
    
    CGFloat popoverImageWidth = self.bounds.size.width;
    CGFloat popoverImageHeight = self.bounds.size.height;
    
    CGFloat arrowImageOriginX = 0;
    CGFloat arrowImageOriginY = 0;
    
    CGFloat arrowImageWidth = ARROW_WIDTH;
    CGFloat arrowImageHeight = ARROW_HEIGHT;
    
    _arrowOffset = -80.0;
    
    
    CGFloat cornerRadius = 9;
    
    switch (self.arrowDirection) {
            
        case UIPopoverArrowDirectionUp:
            
            popoverImageOriginY = ARROW_HEIGHT - 2;
            popoverImageHeight = self.bounds.size.height - ARROW_HEIGHT;
            
           
            arrowImageOriginX = roundf((self.bounds.size.width - ARROW_WIDTH) / 2 + self.arrowOffset);
            
        
            if (arrowImageOriginX + ARROW_WIDTH > self.bounds.size.width - cornerRadius)
            {
                arrowImageOriginX -= cornerRadius;
            }
            
            if (arrowImageOriginX < cornerRadius)
            {
                arrowImageOriginX += cornerRadius;
            }
            
            self.arrowImageView.image = _topArrowImage;
            
            break; 
            
        
        case UIPopoverArrowDirectionRight:
            
            popoverImageWidth = self.bounds.size.width - ARROW_HEIGHT + 2;
            
            arrowImageOriginX = popoverImageWidth - 2;
            arrowImageOriginY = roundf((self.bounds.size.height - ARROW_WIDTH) / 2);
            
            if (arrowImageOriginY + ARROW_WIDTH > self.bounds.size.height - cornerRadius)
            {
                arrowImageOriginY -= cornerRadius;
            }
            
            if (arrowImageOriginY < cornerRadius)
            {
                arrowImageOriginY += cornerRadius;
            }
            
            arrowImageWidth = ARROW_HEIGHT;
            arrowImageHeight = ARROW_WIDTH;
            
            self.arrowImageView.image = _rightArrowImage;
            
            break;
            
        default:
            
            popoverImageHeight = self.bounds.size.height - ARROW_HEIGHT + 2;
            
            break;
    }
    
    self.popoverBackgroundImageView.frame = CGRectMake(popoverImageOriginX, popoverImageOriginY, popoverImageWidth, popoverImageHeight);
    self.arrowImageView.frame = CGRectMake(arrowImageOriginX, arrowImageOriginY + 1.0, arrowImageWidth, arrowImageHeight);
}

@end
