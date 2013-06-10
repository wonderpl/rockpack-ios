//
//  SYNAccountSettingsDOB.m
//  rockpack
//
//  Created by Michael Michailidis on 21/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "GAI.h"
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
    
    [GAI.sharedInstance.defaultTracker sendView: @"Account Settings - Date of birth"];
    
    [self.view addSubview:datePicker];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [datePicker setDatePickerMode:UIDatePickerModeDate];
}

- (void) didTapBackButton: (id) sender
{
    if (self.navigationController.viewControllers.count > 1)
    {
        [self.navigationController popViewControllerAnimated: YES];
    }
}

@end
