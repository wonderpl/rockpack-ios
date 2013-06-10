//
//  SYNSearchBoxView.m
//  rockpack
//
//  Created by Michael Michailidis on 30/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNDeviceManager.h"
#import "SYNSearchBoxView.h"
#import "SYNTextField.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNSearchBoxView ()
//iPhone specific
@property (nonatomic, strong)IBOutlet UIImageView* searchFieldFrameImageView;
@end

@implementation SYNSearchBoxView

#define kGrayPanelBorderWidth 2.0

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        CGFloat barWidth = [SYNDeviceManager.sharedInstance currentScreenWidth] - 90.0;
        
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
        loopImageView.frame = CGRectMake(15.0, 15.0, loopImage.size.width, loopImage.size.height);
        loopImageView.image = loopImage;
        grayPanel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        [grayPanel addSubview:loopImageView];
        
        
        // == Label == //
        
        CGRect fieldRect = grayPanel.frame;
        fieldRect.origin.x += 28.0 + loopImage.size.width;
        fieldRect.origin.y += 14.0;
        fieldRect.size.width -= 28.0 * 2;
        fieldRect.size.height -= 14.0 * 2;
        self.searchTextField = [[SYNTextField alloc] initWithFrame:fieldRect];
        self.searchTextField.font = [UIFont rockpackFontOfSize:26.0];
        self.searchTextField.backgroundColor = [UIColor clearColor];
        self.searchTextField.textAlignment = NSTextAlignmentLeft;
        self.searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.searchTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        self.searchTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        // Display Search instead of Return on iPad Keyboard
        self.searchTextField.returnKeyType = UIReturnKeySearch;
        
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

-(void)awakeFromNib
{
    self.searchFieldFrameImageView.image = [[UIImage imageNamed:@"FieldSearch"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f,20.0f, 0.0f, 20.0f)];
    self.searchTextField.font = [UIFont rockpackFontOfSize:self.searchTextField.font.pointSize];
    self.searchTextField.textColor = [UIColor colorWithRed:40.0/255.0 green:45.0/255.0 blue:51.0/255.0 alpha:1.0];
    self.searchTextField.layer.shadowOpacity = 1.0;
    self.searchTextField.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.searchTextField.layer.shadowOffset = CGSizeMake(0.0f,1.0f);
    self.searchTextField.layer.shadowRadius = 0.0f;
    self.searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    // Display Search instead of Return on iPhone Keyboard
    self.searchTextField.returnKeyType = UIReturnKeySearch;
    
    [self hideCloseButton];
}

-(void)resizeForHeight:(CGFloat)height
{
    if([SYNDeviceManager.sharedInstance isIPad])
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
    else
    {
        CGRect selfFrame = self.frame;
        selfFrame.size.height = MIN(65.0 + height, 548.0f);
        self.frame = selfFrame;
    }
}

+(id)searchBoxView
{
    return [[self alloc] initWithFrame:CGRectZero];
}

#pragma mark - reveal closebutton (iPhone)
-(void)revealCloseButton
{
    CGRect newFrame = self.integratedCloseButton.frame;
    newFrame.origin.x = self.frame.size.width - newFrame.size.width - 10.0f;
    self.integratedCloseButton.frame = newFrame;
    
    newFrame = self.searchTextField.frame;
    newFrame.size.width = self.integratedCloseButton.frame.origin.x - 10.0f - newFrame.origin.x;
    self.searchTextField.frame = newFrame;
    
    newFrame = self.searchFieldFrameImageView.frame;
    newFrame.size.width = self.integratedCloseButton.frame.origin.x - 10.0f - newFrame.origin.x;
    self.searchFieldFrameImageView.frame = newFrame;
}

-(void)hideCloseButton
{
    CGRect newFrame = self.integratedCloseButton.frame;
    newFrame.origin.x = self.frame.size.width;
    self.integratedCloseButton.frame = newFrame;
    
    newFrame = self.searchTextField.frame;
    newFrame.size.width = self.frame.size.width -10.0f - newFrame.origin.x;
    self.searchTextField.frame = newFrame;
    
    newFrame = self.searchFieldFrameImageView.frame;
    newFrame.size.width = self.frame.size.width -10.0f - newFrame.origin.x;
    self.searchFieldFrameImageView.frame = newFrame;
    
    
}




@end
