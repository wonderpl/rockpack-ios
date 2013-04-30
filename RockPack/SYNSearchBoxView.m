//
//  SYNSearchBoxView.m
//  rockpack
//
//  Created by Michael Michailidis on 30/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchBoxView.h"
#import "SYNDeviceManager.h"
#import "UIFont+SYNFont.h"

@implementation SYNSearchBoxView

#define kGrayPanelBorderWidth 2.0

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        CGFloat barWidth = [[SYNDeviceManager sharedInstance] currentScreenWidth] - 90.0;
        
        backgroundPanel = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, barWidth, 61.0)];
        backgroundPanel.backgroundColor = [UIColor whiteColor];
        
        backgroundPanel.autoresizesSubviews = YES;
        
        initialPanelHeight = backgroundPanel.frame.size.height;
        
        // == Gray Panel == //
        
        grayPanel = [[UIView alloc] initWithFrame:CGRectMake(kGrayPanelBorderWidth,
                                                             kGrayPanelBorderWidth,
                                                             backgroundPanel.frame.size.width - kGrayPanelBorderWidth * 2,
                                                             backgroundPanel.frame.size.height - kGrayPanelBorderWidth * 2)];
        
        grayPanel.backgroundColor = [UIColor colorWithRed:(249.0/255.0) green:(249.0/255.0) blue:(249.0/255.0) alpha:(1.0)];
        grayPanel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [backgroundPanel addSubview:grayPanel];
        
        backgroundPanel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        
        
        // == Loop == //
        
        UIImage* loopImage = [UIImage imageNamed:@"IconSearch"];
        UIImageView* loopImageView = [[UIImageView alloc] initWithImage:loopImage];
        loopImageView.frame = CGRectMake(10.0, 14.0, loopImage.size.width, loopImage.size.height);
        loopImageView.image = loopImage;
        grayPanel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        [grayPanel addSubview:loopImageView];
        
        
        // == Label == //
        
        CGRect fieldRect = grayPanel.frame;
        fieldRect.origin.x += 18.0 + loopImage.size.width;
        fieldRect.origin.y += 14.0;
        fieldRect.size.width -= 28.0 * 2;
        fieldRect.size.height -= 14.0 * 2;
        self.searchTextField = [[UITextField alloc] initWithFrame:fieldRect];
        self.searchTextField.font = [UIFont rockpackFontOfSize:26.0];
        self.searchTextField.backgroundColor = [UIColor clearColor];
        self.searchTextField.textAlignment = NSTextAlignmentLeft;
        self.searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.searchTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        self.searchTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        //self.searchTextField.backgroundColor = [UIColor greenColor];
        
        CGRect finalFrame = backgroundPanel.frame;
        
        
        self.frame = finalFrame;
        [self addSubview:backgroundPanel];
        [self addSubview:self.searchTextField];
        
        self.autoresizesSubviews = YES;
        
        
        
        self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        
        
    }
    return self;
}

-(void)resizeForHeight:(CGFloat)height
{
    CGRect panelFrame = backgroundPanel.frame;
    panelFrame.size.height = initialPanelHeight + height + (height > 0.0 ? 10.0 : 0.0);
    backgroundPanel.frame = panelFrame;
    
    panelFrame.origin.x += kGrayPanelBorderWidth;
    panelFrame.origin.y += kGrayPanelBorderWidth;
    panelFrame.size.width -= kGrayPanelBorderWidth * 2;
    panelFrame.size.height -= kGrayPanelBorderWidth * 2;
    grayPanel.frame = panelFrame;
    
    
    CGRect selfFrame = self.frame;
    selfFrame.size.height = panelFrame.size.height;
    self.frame = selfFrame;
}

+(id)searchBoxView
{
    return [[self alloc] initWithFrame:CGRectZero];
}


@end
