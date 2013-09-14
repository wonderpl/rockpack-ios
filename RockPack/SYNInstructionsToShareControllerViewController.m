//
//  SYNInstructionsToShareControllerViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 12/09/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNInstructionsToShareControllerViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNAppDelegate.h"

typedef enum InstructionsShareState {

    InstructionsShareStateInit = 0,
    InstructionsShareStatePressAndHold,
    InstructionsShareStateChooseAction,
    InstructionsShareStateGoodJob,
    InstructionsShareStateShared

} InstructionsShareState;
@interface SYNInstructionsToShareControllerViewController ()

@property (strong, nonatomic) IBOutlet UILabel *instructionsLabel;
@property (strong, nonatomic) IBOutlet UILabel *subLabel;
@property (strong, nonatomic) IBOutlet UIButton *okButton;
@property (strong, nonatomic) IBOutlet UIImageView *videoImageView;
@property (strong, nonatomic) IBOutlet UIView* backgroundView;

@property (nonatomic) InstructionsShareState state;
@end

@implementation SYNInstructionsToShareControllerViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.subLabel.font = [UIFont rockpackFontOfSize:self.subLabel.font.pointSize];
    self.instructionsLabel.font = [UIFont rockpackFontOfSize:self.instructionsLabel.font.pointSize];
    
    UITapGestureRecognizer* tapToCloseGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToClose:)];
    [self.backgroundView addGestureRecognizer:tapToCloseGesture];
}

-(void)tapToClose:(UIGestureRecognizer*)recogniser
{
    [self.backgroundView removeGestureRecognizer:self.backgroundView.gestureRecognizers[0]]; // remove the tap gesture for house keeping
    
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.viewStackManager hideModalController]; // hide self
    
}

-(IBAction)okayButtonPressed:(id)sender
{
    
}

-(void)setState:(InstructionsShareState)state
{
    switch (state)
    {
        case InstructionsShareStateInit:
            self.instructionsLabel.text = NSLocalizedString(@"instruction_initial", nil);
            self.subLabel.text = NSLocalizedString(@"instruction_initial_subtext", nil);
            self.subLabel.hidden = NO;
            break;
            
        case InstructionsShareStatePressAndHold:
            self.instructionsLabel.text = NSLocalizedString(@"instruction_press_hold", nil);
            self.subLabel.text = @"";
            self.subLabel.hidden = YES;
            break;
            
        case InstructionsShareStateChooseAction:
            self.instructionsLabel.text = NSLocalizedString(@"instruction_choose_action", nil);
            break;
            
        case InstructionsShareStateGoodJob:
            self.instructionsLabel.text = NSLocalizedString(@"instruction_good_job", nil);
            break;
            
        case InstructionsShareStateShared:
            self.instructionsLabel.text = NSLocalizedString(@"channels_screen_loading_categories", nil);
            break;
            
            
    }
}


@end
