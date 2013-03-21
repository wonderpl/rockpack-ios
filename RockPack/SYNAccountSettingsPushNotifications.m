//
//  SYNAccountSettingsPushNotifications.m
//  rockpack
//
//  Created by Michael Michailidis on 21/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

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
    
    self.controls = [[NSMutableArray alloc] init];
    
    self.contentSizeForViewInPopover = CGSizeMake(380, 476);
    
    self.view.backgroundColor = [UIColor clearColor];
    
    // populate fields
    
    NSArray* fields = @[@"Someone adds me as a friend",
                        @"Someone follows me channel",
                        @"Someone Starts a video object",
                        @"Someone shares a video/channel with me"];
    
    CGFloat offsetY = 20.0;
    
    for (NSString* field in fields)
    {
        CGRect onOffFieldFrame = CGRectMake(10.0, offsetY, self.contentSizeForViewInPopover.width - 10.0, 50.0);
        SYNAccountSettingsOnOffField* onOffField = [[SYNAccountSettingsOnOffField alloc] initWithFrame:onOffFieldFrame andString:field];
        
        [self.controls addObject:onOffField];
        
        [self.view addSubview:onOffField];
        
        offsetY += onOffField.frame.size.height + 20.0;
        
    }
    
    
}



@end
