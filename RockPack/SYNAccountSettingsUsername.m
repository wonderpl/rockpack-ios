//
//  SYNAccountSettingsUsername.m
//  rockpack
//
//  Created by Michael Michailidis on 02/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAccountSettingsUsername.h"
#import "SYNOAuthNetworkEngine.h"

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
-(void)saveButtonPressed:(UIButton*)button
{
    
    
    if([self.inputField.text isEqualToString:self.appDelegate.currentUser.username])
        return;
    
    if(![self formIsValid]) {
        self.errorLabel.text = @"You Have Entered Invalid Characters";
        return;
    }
    
    [self updateField:@"username" forValue:self.inputField.text withCompletionHandler:^{
       
        self.appDelegate.currentUser.username = self.inputField.text;
        
        
        [self.appDelegate saveContext:YES];
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    
}



@end
