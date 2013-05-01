//
//  SYNAccountSettingsDOB.m
//  rockpack
//
//  Created by Michael Michailidis on 21/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAccountSettingsDOB.h"
#import "SYNAppDelegate.h"
#import "User.h"

@interface SYNAccountSettingsDOB ()


@end

@implementation SYNAccountSettingsDOB

@synthesize datePicker;



-(id)init
{
    self = [super init];
    if(self) {
        datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, 0.0, 230.0, 280.0)];
        
        self.title = @"Choose a Date";
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:datePicker];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    
    UIButton *backButton = [UIButton buttonWithType: UIButtonTypeCustom];
    UIImage* backButtonImage = [UIImage imageNamed: @"ButtonAccountBackDefault.png"];
    
    [backButton setImage: backButtonImage
                forState: UIControlStateNormal];
    
    [backButton addTarget: self
                   action: @selector(didTapBackButton:)
         forControlEvents: UIControlEventTouchUpInside];
    
    backButton.frame = CGRectMake(0.0, 0.0, backButtonImage.size.width, backButtonImage.size.height);
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView: backButton];
    
    self.navigationItem.leftBarButtonItem = backButtonItem;
    

    
}

- (void) didTapBackButton: (id) sender
{
    if (self.navigationController.viewControllers.count > 1)
    {
        [self.navigationController popViewControllerAnimated: YES];
    }
}

@end
