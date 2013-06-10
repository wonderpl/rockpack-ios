//
//  SYNAccountSettingsUsername.m
//  rockpack
//
//  Created by Michael Michailidis on 02/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAccountSettingsUsername.h"
#import "SYNOAuthNetworkEngine.h"
#import "UIFont+SYNFont.h"

@interface SYNAccountSettingsUsername ()

@end

@implementation SYNAccountSettingsUsername

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
    
    self.view.backgroundColor = [UIColor whiteColor];

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
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame: CGRectMake( -(self.contentSizeForViewInPopover.width * 0.5), -15.0, self.contentSizeForViewInPopover.width, 40.0)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor colorWithRed: (28.0/255.0) green: (31.0/255.0) blue: (33.0/255.0) alpha: (1.0)];
    titleLabel.text = NSLocalizedString (@"settings_popover_username_title", nil);
    titleLabel.font = [UIFont boldRockpackFontOfSize:18.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.shadowColor = [UIColor whiteColor];
    titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    
    
    UIView * labelContentView = [[UIView alloc]init];
    [labelContentView addSubview:titleLabel];
    
    self.navigationItem.titleView = labelContentView;
    
    self.errorLabel.text = @"Your username can only be changed one time";
    
}
-(void)saveButtonPressed:(UIButton*)button
{
    [self.inputField resignFirstResponder];
    
    if([self.inputField.text isEqualToString:self.appDelegate.currentUser.username]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
        
    
    if(![self formIsValid]) {
        self.errorLabel.text = NSLocalizedString (@"You Have Entered Invalid Characters", nil);
        return;
    }
    
    [self updateField:@"username" forValue:self.inputField.text withCompletionHandler:^{
       
        self.appDelegate.currentUser.username = self.inputField.text;
        
        
        [self.appDelegate saveContext:YES];
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    
}



@end
