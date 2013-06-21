//
//  SYNLoginOnBoardingController.m
//  rockpack
//
//  Created by Michael Michailidis on 21/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNLoginOnBoardingController.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>
#import "SYNDeviceManager.h"

#define MESSAGE_NUM 4

@interface SYNLoginOnBoardingController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIPageControl* pageControl;
@property (nonatomic, strong) UIScrollView* scrollView;

@end

@implementation SYNLoginOnBoardingController
@synthesize scrollView = scrollView;

-(void)loadView
{
    CGFloat totalWidth = [[SYNDeviceManager sharedInstance] currentScreenWidth];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, totalWidth, 300.0)];

    
    scrollView.pagingEnabled = YES;
    scrollView.scrollEnabled = YES;
    scrollView.bounces = YES;
    scrollView.userInteractionEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.delegate = self;
    
    
    self.view = [[UIView alloc] initWithFrame:self.scrollView.frame];
    
    [self.view addSubview:scrollView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UIView* messageView;
    NSString* messageText;
    NSString* titleText;
    
    CGRect messageViewFrame;
    
    NSString* localisedKey;
    NSString* localisedDefault;
    
    CGSize totalScrollSize;
    totalScrollSize.height = self.scrollView.frame.size.height;
    for (int i = 0; i < MESSAGE_NUM; i++)
    {
        localisedKey = [NSString stringWithFormat:@"startscreen_onboard_%i", i + 1];
        localisedDefault = [NSString stringWithFormat:@"Text for onboard screen %i", i + 1];
        
        messageText = NSLocalizedString(localisedKey, localisedDefault);
        
        messageView = [self createNewMessageViewWithMessage:messageText andTitle:nil];
        
        messageViewFrame = messageView.frame;
        messageViewFrame.origin.x = i * messageViewFrame.size.width;
        
        messageView.frame = messageViewFrame;
        
        [self.scrollView addSubview:messageView];
        
        totalScrollSize.width += messageView.frame.size.width;
    }
    
    [self.scrollView setContentSize:totalScrollSize];
    
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 40.0)];
    self.pageControl.numberOfPages = MESSAGE_NUM;
    
    [self.view addSubview:self.pageControl];
    
}

-(UIView*)createNewMessageViewWithMessage:(NSString*)message andTitle:(NSString*)title
{
    
    // Set up onboard text
    CGRect viewFrame = CGRectZero;
    viewFrame.size = self.scrollView.frame.size;
    UIView* messageView = [[UIView alloc] initWithFrame:viewFrame];
    
    UIFont* fontToUse;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        fontToUse = [UIFont rockpackFontOfSize: 20.0];
    }
    else
    {
        fontToUse = [UIFont rockpackFontOfSize: 14.0];
    }
    
    CGRect onboardMessageLabelFrame;
    onboardMessageLabelFrame.size = [message sizeWithFont:fontToUse];
    onboardMessageLabelFrame.origin.x = viewFrame.size.width * 0.5 - onboardMessageLabelFrame.size.width * 0.5;
    UILabel* onboardMessageLabel = [[UILabel alloc] initWithFrame:onboardMessageLabelFrame];
    
    onboardMessageLabel.text = message;
    
    // Set font
    
    
    // Colour of onboard text
    onboardMessageLabel.textColor = [UIColor whiteColor];
    
    // Colour of small DropShadow on text
    onboardMessageLabel.shadowColor = [UIColor colorWithRed: 0.0f
                                                      green: 0.0f
                                                       blue: 0.0f
                                                      alpha:0.2f];
    
    // Offset of small DropShadow's
    
    onboardMessageLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    
    // Colour of onboard text shadow (R, G, B)
    onboardMessageLabel.layer.shadowColor = [UIColor colorWithRed: 0.0f
                                                            green: 0.0f
                                                             blue: 0.0f
                                                            alpha: 1.0f].CGColor;
    
    // Offset of onboard text shadow (X, Y)
    onboardMessageLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    
    // Radius of onboard text shadow (0 -> n)
    onboardMessageLabel.layer.shadowRadius = 10.0f;
    
    // Opacity of onboard text shadow (0 - 1)
    onboardMessageLabel.layer.shadowOpacity = 0.3f;
    
    onboardMessageLabel.backgroundColor = [UIColor clearColor];
    
    [messageView addSubview:onboardMessageLabel];
    
    // TITLES
    
    if(title != nil)
    {
        UILabel* onboardTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 30.0)];
        // Set up onboard text
        onboardTitleLabel.text = NSLocalizedString(@"startscreen_onboard_1", @"Text for onboard screen 1");
        
        // Set font
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            onboardTitleLabel.font = [UIFont boldRockpackFontOfSize: 22.0];
        }
        else
        {
            onboardTitleLabel.font = [UIFont boldRockpackFontOfSize: 16.0];
        }
        
        // Colour of onboard text
        onboardTitleLabel.textColor = [UIColor whiteColor];
        
        // Colour of small DropShadow on text
        onboardTitleLabel.shadowColor = [UIColor colorWithRed: 0.0f
                                                        green: 0.0f
                                                         blue: 0.0f
                                                        alpha: 0.2f];
        
        // Offset of small DropShadow's
        
        onboardTitleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        
        // Colour of onboard text shadow (R, G, B)
        onboardTitleLabel.layer.shadowColor = [UIColor colorWithRed: 0.0f
                                                              green: 0.0f
                                                               blue: 0.0f
                                                              alpha: 1.0f].CGColor;
        
        // Offset of onboard text shadow (X, Y)
        onboardTitleLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        
        // Radius of onboard text shadow (0 -> n)
        onboardTitleLabel.layer.shadowRadius = 10.0f;
        
        // Opacity of onboard text shadow (0 - 1)
        onboardTitleLabel.layer.shadowOpacity = 0.3f;
    }
    
    return messageView;
}

#pragma mark - Delegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat contentOffsetY = self.scrollView.contentOffset.y;
}

@end
