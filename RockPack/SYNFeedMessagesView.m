//
//  SYNFeedMessagesView.m
//  rockpack
//
//  Created by Michael Michailidis on 30/05/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNFeedMessagesView.h"
#import "UIFont+SYNFont.h"
#import "SYNDeviceManager.h"

#define kSpinnerTextDistance 12.0

@interface SYNFeedMessagesView () {
    BOOL _isIPhone;
    BOOL _isLoader;
    UIActivityIndicatorView* _activityIndicatorView;
}

@property UILabel* messageLabel;

@end

@implementation SYNFeedMessagesView


- (id) initWithMessage:(NSString*)message
{
    
    
    if (self = [super init]) {
        
        _isIPhone = [[SYNDeviceManager sharedInstance] isIPhone];
        // Label
        
        UIFont* fontToUse = [UIFont rockpackFontOfSize: _isIPhone? 14.0f : 20.0f ];
        
        CGRect labelFrame = CGRectZero;
        
        UILabel* label = [[UILabel alloc] initWithFrame:labelFrame];
        label.font = fontToUse;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        
        if(_isIPhone)
        {
            label.numberOfLines = 0;
        }
        _messageLabel = label;
        
        // BG
        self.backgroundColor = [UIColor colorWithWhite:0.333f alpha:0.8f];

        
        // Add
        [self addSubview:label];
        
        [self setMessage:message];
        
    }
    return self;
}

-(void)setMessage:(NSString*)newMessage
{
    if (_isIPhone)
    {
        self.messageLabel.frame = CGRectMake(0.0f, 0.0f, 260.0f, 300.0f);
    }
    
    self.messageLabel.text = [newMessage uppercaseString];
    [self.messageLabel sizeToFit];

    
    self.frame = [self returnMainFrame];
    
    self.messageLabel.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5 + 4.0);
    self.messageLabel.frame = CGRectIntegral(self.messageLabel.frame);
    
    
    

}

+ (id) withMessage: (NSString*) message
{
    return [[self alloc] initWithMessage: message];
}

+ (id) withMessage:(NSString *)message andLoader:(BOOL)isLoader
{
    SYNFeedMessagesView* instance = [self withMessage:message];
    instance.isLoader = isLoader;
    return instance;
}

-(void)setIsLoader:(BOOL)isLoader
{
    if(_isLoader == isLoader)
        return;
    
    if(_isLoader) // remove existing no matter what
    {
        [_activityIndicatorView stopAnimating];
        [_activityIndicatorView removeFromSuperview];
        _activityIndicatorView = nil;
    }
    
    _isLoader = isLoader;
    
    if(_isLoader)
    {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityIndicatorView.hidesWhenStopped = YES;
        CGRect activityFrame = _activityIndicatorView.frame;
        activityFrame.origin.x = kSpinnerTextDistance + self.messageLabel.frame.origin.x + self.messageLabel.frame.size.width;
        _activityIndicatorView.frame = activityFrame;
        _activityIndicatorView.center = CGPointMake(_activityIndicatorView.center.x, self.frame.size.height * 0.5);
        _activityIndicatorView.frame = CGRectIntegral(_activityIndicatorView.frame);
        [self addSubview:_activityIndicatorView];
        [_activityIndicatorView startAnimating];
        
        // set frame
        
        self.frame = [self returnMainFrame];
    }
    
}



-(CGRect)returnMainFrame
{
    CGRect mainFrame = CGRectMake(0.0, 0.0, self.messageLabel.frame.size.width + 40.0, self.messageLabel.frame.size.height + 30.0);
    
    if(_isLoader)
    {
        mainFrame.size.width += _activityIndicatorView.frame.size.width + kSpinnerTextDistance;
    }
    
    return mainFrame;
}

@end
