//
//  SYNAccountSettingsPushNotifications.m
//  rockpack
//
//  Created by Michael Michailidis on 21/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "GAI.h"
#import "SYNAccountSettingsPushNotifications.h"
#import "SYNAccountSettingsOnOffField.h"

@interface SYNAccountSettingsPushNotifications ()

@property (nonatomic, strong) NSMutableArray* controls;

@end

@implementation SYNAccountSettingsPushNotifications

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [GAI.sharedInstance.defaultTracker sendView: @"Account Settings - Push"];
    
    self.controls = [[NSMutableArray alloc] init];
    
    self.contentSizeForViewInPopover = CGSizeMake(380, 476);
    
    self.view.backgroundColor = [UIColor clearColor];
    
    // populate fields
    
    NSArray* fields = @[NSLocalizedString (@"Someone adds me as a friend", nil),
                        NSLocalizedString (@"Someone follows me channel", nil),
                        NSLocalizedString (@"Someone Starts a video object", nil),
                        NSLocalizedString (@"Someone shares a video/channel with me", nil)];
    
    CGFloat offsetY = 20.0;
    
    for (NSString* field in fields)
    {
        
        CGRect onOffFieldFrame = CGRectMake(10.0, offsetY, self.contentSizeForViewInPopover.width - 10.0, 50.0);
        SYNAccountSettingsOnOffField* onOffField = [[SYNAccountSettingsOnOffField alloc] initWithFrame:onOffFieldFrame andString:field];
        
        [self.controls addObject:onOffField];
        
        [self.view addSubview:onOffField];
        
        offsetY += onOffField.frame.size.height + 20.0;
        
    }
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* backButtonImage = [UIImage imageNamed: @"ButtonAccountBackDefault.png"];
    UIImage* backButtonHighlightedImage = [UIImage imageNamed: @"ButtonAccountBackHighlighted.png"];
    
    
    [backButton setImage: backButtonImage
                forState: UIControlStateNormal];
    
    [backButton setImage: backButtonHighlightedImage
                forState: UIControlStateHighlighted];
    
    [backButton addTarget:self action:@selector(didTapBackButton:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0.0, 0.0, backButtonImage.size.width, backButtonImage.size.height);
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    
}

- (void) didTapBackButton:(id)sender {
    if(self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
