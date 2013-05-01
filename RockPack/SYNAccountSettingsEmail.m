//
//  SYNAccountSettingsEmail.m
//  rockpack
//
//  Created by Michael Michailidis on 02/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAccountSettingsEmail.h"
#import "SYNOAuthNetworkEngine.h"

@interface SYNAccountSettingsEmail ()

@end

@implementation SYNAccountSettingsEmail

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
	// Do any additional setup after loading the view.
}

-(void)saveButtonPressed:(UIButton*)button
{
    
    [super saveButtonPressed:button];
    
    if([self.inputField.text isEqualToString:self.appDelegate.currentUser.emailAddress])
        return;
    
    if(![self formIsValid]) {
        self.errorTextField.text = @"You Have Entered Invalid Characters";
        return;
    }
    
    [self updateField:@"email" forValue:self.inputField.text withCompletionHandler:^{
        self.appDelegate.currentUser.emailAddress = self.inputField.text;
        
        
        [self.appDelegate saveContext:YES];
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
}





@end
