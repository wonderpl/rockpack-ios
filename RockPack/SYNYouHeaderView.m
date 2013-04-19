//
//  SYNYouHeaderView.m
//  rockpack
//
//  Created by Michael Michailidis on 18/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNYouHeaderView.h"
#import "SYNDeviceManager.h"
#import "UIFont+SYNFont.h"

@implementation SYNYouHeaderView

-(id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        label = [[UILabel alloc] initWithFrame:frame];
        UIFont* fontToUse = [UIFont rockpackFontOfSize:21.0];
        label.font = fontToUse;
        label.textColor = [UIColor colorWithRed:(106.0/255.0) green:(114.0/255.0) blue:(112.0/255.0) alpha:(1.0)];
        label.backgroundColor = [UIColor clearColor];
        
        
        [self addSubview:label];
        
        backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
        backgroundImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:backgroundImageView];
        backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        
        
        textCompositeView = [[UIView alloc] initWithFrame:frame];
        textCompositeView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [self addSubview:textCompositeView];
    }
    return self;
}

+(id)headerViewForWidth:(CGFloat)width
{
    return [[self alloc] initWithFrame:CGRectMake(0.0, 170.0f, width, 50.0)];
}

-(void)setTitle:(NSString *)title andNumber:(NSInteger)number
{
    NSString* numberString = [NSString stringWithFormat:@"%i", number];
    NSInteger numberStringLength = [numberString length];
    NSString* completeString = [NSString stringWithFormat:@"%@ (%@)", title, numberString];
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:completeString];
    NSRange rangeOfParen = [completeString rangeOfString:@"("];
    [attrString addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:(32.0/255.0) green:(195.0/255.0) blue:(226.0/255.0) alpha:(1.0)] range: NSMakeRange(rangeOfParen.location + 1, numberStringLength)];
    
    
    CGSize titleSize = [completeString sizeWithFont:label.font];
    label.frame = CGRectMake(0.0, 0.0, titleSize.width, titleSize.height);
    label.attributedText = attrString;
    
    [textCompositeView addSubview:label];
    
    textCompositeView.frame = label.frame;
    
    textCompositeView.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
    textCompositeView.frame = CGRectIntegral(textCompositeView.frame);
    
    
}

-(void)setBackgroundImage:(UIImage*)backgroundImage
{
    backgroundImageView.image = backgroundImage;
}


-(CGFloat)currentHeight
{
    return self.frame.size.height;
}
-(CGFloat)currentWidth
{
    return self.frame.size.width;
}

@end
