//
//  SYNLoginOnBoardingController.m
//  rockpack
//
//  Created by Michael Michailidis on 21/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//


#import "AppConstants.h"
#import "SYNDeviceManager.h"
#import "SYNLoginOnBoardingController.h"
#import "UIColor+SYNColor.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>


@interface SYNLoginOnBoardingController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIPageControl* pageControl;
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, weak) id <UIScrollViewDelegate> delegate;

@end


@implementation SYNLoginOnBoardingController

#pragma mark - Object lifecycle

- (id) initWithDelegate: (id <UIScrollViewDelegate>) delegate
{
    if ((self = [super init]))
    {
        self.delegate = delegate;
    }
    
    return self;
}


- (void) dealloc
{
    self.scrollView.delegate = nil;
    [self removeObserver:self forKeyPath:@"view.frame"];
}


#pragma mark - View lifecycle

- (void) loadView
{
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1024.0f, 500.0)];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.bounces = YES;
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.scrollView.delegate = self.delegate;
    
    self.view = [[UIView alloc] initWithFrame: self.scrollView.frame];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview: self.scrollView];
    
    [self addObserver:self forKeyPath:@"view.frame" options:NSKeyValueObservingOptionOld context:NULL];
}


- (void) viewDidLoad
{
    [super viewDidLoad];
	
    UIView* messageView;
    NSString* messageText;
    NSString* titleText;
    
    CGPoint messageViewCenter;
    
    NSString* localisedKey;
    NSString* localisedDefault;
    
    CGSize totalScrollSize;

    totalScrollSize.height = self.scrollView.frame.size.height;
    
    for (int i = 0; i < kLoginOnBoardingMessagesNum; i++)
    {
        // Get the Title
        
        localisedKey = [NSString stringWithFormat:@"startscreen_onboard_%i_title", i + 1];
        localisedDefault = [NSString stringWithFormat:@"Text for onboard title %i", i + 1];
        
        titleText = NSLocalizedString(localisedKey, localisedDefault);
        
        
        // Get the Message
        
        localisedKey = [NSString stringWithFormat:@"startscreen_onboard_%i", i + 1];
        localisedDefault = [NSString stringWithFormat:@"Text for onboard screen %i", i + 1];
        
        messageText = NSLocalizedString(localisedKey, localisedDefault);    
        
        messageView = [self createNewMessageViewWithMessage:messageText
                                                   andTitle:titleText];
        
        messageViewCenter = messageView.center;
        messageViewCenter.x = (i + 0.5) * self.scrollView.frame.size.width;
        //messageView.center = messageViewCenter;
        
        CGRect integralFrame = CGRectIntegral(messageView.frame);
        
        //Text Frame
        CGRect iPadMessageRect = CGRectMake((self.view.frame.size.width * 0.5) - (integralFrame.size.width * 0.5), self.view.frame.size.height - 350, integralFrame.size.width, integralFrame.size.height);
        CGRect iPhoneMessageRect = CGRectMake((self.view.frame.size.width * 0.5) - (integralFrame.size.width * 0.5), self.view.frame.size.height - 300, integralFrame.size.width, integralFrame.size.height);
        
        messageView.frame = IS_IPAD ? iPadMessageRect : iPhoneMessageRect;
        
        
//        //Get the Image
//        UIImage * messageImage;
//        messageImage = [UIImage imageNamed: [NSString stringWithFormat:@"login_onboard_%i", i+1]];
        
        //Image Frame
        CGRect iPadImageRect = CGRectMake((messageView.frame.size.width * 0.5) - 140, messageView.frame.origin.y - 200, 280, 200);
        CGRect iPhoneImageRect = CGRectMake((messageView.frame.size.width * 0.5) - 140, messageView.frame.origin.y - 220, 280, 200);
        
        UIImageView * messageImageView = [[UIImageView alloc]initWithFrame: IS_IPAD ? iPadImageRect : iPhoneImageRect];
        
        if (i == 0)
        {
            messageImageView.image = [UIImage imageNamed: [NSString stringWithFormat:@"login_onboard_%i.png", i+1]];
        }
        
        else
        {
        messageImageView.image = [UIImage imageNamed: [NSString stringWithFormat:@"login_onboard_%i.jpg", i+1]];
        }

        [self.scrollView addSubview:messageView];
        [messageView addSubview:messageImageView];
        
        totalScrollSize.width += self.scrollView.frame.size.width;
    }
    
    [self.scrollView setContentSize:totalScrollSize];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((self.view.frame.size.width * 0.5) - 50, self.view.frame.size.height - 50, 100.0, 40.0)];
    self.pageControl.numberOfPages = kLoginOnBoardingMessagesNum;
    //self.pageControl.center = CGPointMake(self.view.frame.size.width * 0.5, 270.0);
    self.pageControl.frame = CGRectIntegral(self.pageControl.frame);
    self.pageControl.userInteractionEnabled = NO; // dont block the screen
    self.pageControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [self.view addSubview:self.pageControl];
}


- (UIView*) createNewMessageViewWithMessage: (NSString*) message
                                   andTitle: (NSString*)title
{
    CGRect newFrame = CGRectZero;
    
    
    // Limit label width to fit on portrait iPad, or iPhone screen
    newFrame.size.width = IS_IPHONE ? 300.0f: 728.0f;
    newFrame.size.height = 0.0f;
    
    UIView* container = [[UIView alloc] initWithFrame:newFrame];
    
    // Title label, Offset from the top of the scroll view;
    newFrame.origin.y = IS_IPHONE ? 205.0f : 170.0f;
    
    UIColor* shadowColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
    
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:newFrame];
    if(title)
    {
        
        UIFont* fontTitleToUse = [UIFont boldRockpackFontOfSize: IS_IPHONE ? 19.0f : 28.0f];
        titleLabel.font = fontTitleToUse;
        titleLabel.numberOfLines = 0;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = title;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        
        titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        titleLabel.shadowColor = shadowColor;
        
        [titleLabel sizeToFit];
        // add the newly created height to the frame
        newFrame.size.height = titleLabel.frame.size.height;
        
        [container addSubview:titleLabel];
    }
    
    //Text label, laid out under title, if there is one
    
    newFrame.origin.y += newFrame.size.height;
    
    UILabel* textLabel = [[UILabel alloc] initWithFrame:newFrame];
    UIFont* fontToUse = [UIFont rockpackFontOfSize:  IS_IPHONE ? 16.0f : 22.0f];
    textLabel.font = fontToUse;
    textLabel.numberOfLines =0;
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.text = message;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor colorWithRed:40.0/255.0 green:45.0/255.0 blue:51.0/255.0 alpha:1.0];
    textLabel.shadowColor = [UIColor whiteColor];
    textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    [textLabel sizeToFit];
    [container addSubview:textLabel];

    
    // Resize the container to match the label heights
    newFrame = container.frame;
    newFrame.size.height = textLabel.frame.origin.y + textLabel.frame.size.height;
    container.frame = newFrame;

    //Center the labels in the container
    CGPoint center = textLabel.center;
    center.x = container.center.x;
    textLabel.center = center;
    
    center = titleLabel.center;
    center.x = container.center.x;
    titleLabel.center = center;

    return container;
    
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"view.frame"]) {
        [self refreshLayout];
    }
}


-(void)refreshLayout
{
    CGPoint messageViewCenter;
    CGSize totalScrollSize = CGSizeZero;
    totalScrollSize.height = self.scrollView.frame.size.height;
    int i=0;
    for (UIView* childView in self.scrollView.subviews)
    {
        messageViewCenter = childView.center;
        messageViewCenter.x = (i + 0.5) * self.scrollView.frame.size.width;
        childView.center = messageViewCenter;
        
        childView.frame = CGRectIntegral(childView.frame);
        
        totalScrollSize.width += self.scrollView.frame.size.width;
        i++;
    }
    
    [self.scrollView setContentSize: totalScrollSize];
    
    CGPoint newCOffset = CGPointMake(self.pageControl.currentPage * self.scrollView.frame.size.width, self.scrollView.contentOffset.y);
    
    [self.scrollView setContentOffset: newCOffset];
}



@end
