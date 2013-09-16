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
#import "SYNAbstractViewController.h"
#import "SYNDeviceManager.h"


@interface SYNInstructionsToShareControllerViewController () {
    InstructionsShareState initialState;
}

#define STD_FADE_TEXT 0.2f

@property (strong, nonatomic) IBOutlet UILabel *instructionsLabel;
@property (strong, nonatomic) IBOutlet UILabel *subLabel;
@property (strong, nonatomic) IBOutlet UIButton *okButton;
@property (strong, nonatomic) IBOutlet UIImageView *videoImageView;
@property (strong, nonatomic) IBOutlet UIImageView* backgroundImageView;
@property (weak, nonatomic) SYNAbstractViewController* delegate;
@property (nonatomic) InstructionsShareState state;


@end

@implementation SYNInstructionsToShareControllerViewController

-(id)initWithDelegate:(SYNAbstractViewController*)delegate andState:(InstructionsShareState)iState
{
    if (self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil])
    {
        self.delegate = delegate;
        initialState = iState;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.state = initialState; // init state, should already be set so will ignored
    
    // set the background
    
    self.view.frame = [[SYNDeviceManager sharedInstance] currentScreenRect];
    
    [self packForInterfaceOrientation:[SYNDeviceManager sharedInstance].orientation];
    
    // initial setup
    if(self.state == InstructionsShareStatePacks)
    {
        self.backgroundImageView.image = [UIImage imageNamed:@"InstructionBackgroundPacks"];
    }
    else
    {
        self.backgroundImageView.image = [UIImage imageNamed:@"InstructionBackgroundPressAndHold"];
        
        self.videoImageView.userInteractionEnabled = YES;
        self.videoImageView.hidden = NO;
        
        self.subLabel.hidden = YES;
        
        UILongPressGestureRecognizer* videoLongPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOverVideoImagePerformed:)];
        [self.videoImageView addGestureRecognizer:videoLongPress];
    }
    
    self.subLabel.font = [UIFont rockpackFontOfSize:self.subLabel.font.pointSize];
    self.instructionsLabel.font = [UIFont rockpackFontOfSize:self.instructionsLabel.font.pointSize];
    
    UITapGestureRecognizer* tapToCloseGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToClose:)];
    [self.backgroundImageView addGestureRecognizer:tapToCloseGesture];
    
    
    
    
}

-(void)longPressOverVideoImagePerformed:(UILongPressGestureRecognizer*)recogniser
{
    
    switch (recogniser.state)
    {
        case UIGestureRecognizerStateBegan:
            self.state = InstructionsShareStateChooseAction;
            break;
            
        case UIGestureRecognizerStateEnded:
            self.state = InstructionsShareStatePressAndHold;
            break;
            
        default:
            break;
    }
    
    
    [self setupArcMenuWithRecogniser:recogniser];
}

-(void)tapToClose:(UIGestureRecognizer*)recogniser
{
    
    
    
    
    [self.backgroundImageView removeGestureRecognizer:self.backgroundImageView.gestureRecognizers[0]]; // remove the tap gesture for house keeping
    
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.viewStackManager removeCoverPopoverViewController]; // hide self
    
}

-(IBAction)okayButtonPressed:(id)sender
{
    self.okButton.enabled = NO;
    
    if(self.state == InstructionsShareStateGoodJob ||
       self.state == InstructionsShareStatePressAndHold ||
       self.state == InstructionsShareStatePacks)
    {
        // close the panel
        [self tapToClose:nil];
        return;
    }
    self.state += 1;
}

-(void)setState:(InstructionsShareState)state
{
    if(_state == state)
        return;
    
    _state = state;
    
    switch (_state)
    {
        
        
        case InstructionsShareStatePressAndHold:
        {
            
            
            [self changeMainTextForString:NSLocalizedString(@"instruction_press_hold", nil) onCompletion:^{
                
                self.okButton.enabled = YES;
            }];
            
            
            
            
        }
            break;
            
        case InstructionsShareStateChooseAction:
        {
            [self changeMainTextForString:NSLocalizedString(@"instruction_choose_action", nil) onCompletion:^{
                self.okButton.enabled = YES;
            }];
            
            
        }
            
            break;
            
        case InstructionsShareStateGoodJob:
        {
            
            [self changeMainTextForString:NSLocalizedString(@"instruction_good_job", nil) onCompletion:^{
                self.okButton.enabled = YES;
            }];
        }
            
            break;
            
        
            
            
        case InstructionsShareStatePacks:
        {
            // no fading in this case, just present
            self.instructionsLabel.text = NSLocalizedString(@"instruction_packs_for_you", nil);
            self.subLabel.text = NSLocalizedString(@"instruction_packs_choose_one", nil);
            self.subLabel.hidden = NO;
            self.videoImageView.hidden = YES;
        }
            break;
            
        default:
            // could be the none state
            break;
    }
    
}

-(void)changeMainTextForString:(NSString*)newText onCompletion:(void(^)(void))completion
{
    
    [UIView animateWithDuration:STD_FADE_TEXT animations:^{
        
        self.instructionsLabel.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
        self.instructionsLabel.text = newText;
        
        [self resizeMainLabel];
        
        [UIView animateWithDuration:STD_FADE_TEXT animations:^{
            
            self.instructionsLabel.alpha = 1.0f;
            
        } completion:^(BOOL finished) {
            
            
            if(completion)
                completion();
            
        }];
        
    }];
}


#pragma mark - Arc Menu

-(void)setupArcMenuWithRecogniser:(UILongPressGestureRecognizer*)recogniser
{
    
    
    
    SYNArcMenuItem *arcMenuItem1 = [[SYNArcMenuItem alloc] initWithImage: [UIImage imageNamed: @"ActionLike"]
                                                        highlightedImage: [UIImage imageNamed: @"ActionLikeHighlighted"]
                                                                    name: kActionLike
                                                               labelText: @"Like it"];
    
    SYNArcMenuItem *arcMenuItem2 = [[SYNArcMenuItem alloc] initWithImage: [UIImage imageNamed: @"ActionAdd"]
                                                        highlightedImage: [UIImage imageNamed: @"ActionAddHighlighted"]
                                                                    name: kActionAdd
                                                               labelText: @"Pack it"];
    
    SYNArcMenuItem *arcMenuItem3 = [[SYNArcMenuItem alloc] initWithImage: [UIImage imageNamed: @"ActionShare"]
                                                        highlightedImage: [UIImage imageNamed: @"ActionShareHighlighted"]
                                                                    name: kActionShareVideo
                                                               labelText: @"Share it"];
    
    NSArray* menuItems = @[arcMenuItem1, arcMenuItem2, arcMenuItem3];
    
    
    [self.delegate arcMenuUpdateState: recogniser
                   forCellAtIndexPath: nil
                   withComponentIndex: nil
                            menuItems: menuItems
                              menuArc: (M_PI / 2)
                       menuStartAngle: (-M_PI / 4)];
}


-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    //[self packForInterfaceOrientation:toInterfaceOrientation];
}
-(void)resizeMainLabel
{
    [self.instructionsLabel sizeToFit];
    
    // instructions label
    CGRect ilFrame = self.instructionsLabel.frame;
    ilFrame.origin.y = self.state == InstructionsShareStatePacks ? 280.0f : 120.0f;
    ilFrame.origin.x = 0.0f;
    ilFrame.size.width = self.view.frame.size.width;
    self.instructionsLabel.frame = CGRectIntegral(ilFrame);
}
-(void)packForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    
    [self resizeMainLabel];
    
    // secondary component (either label or video)
    CGRect secondFrame;
    secondFrame.origin.y = self.instructionsLabel.frame.origin.y + self.instructionsLabel.frame.size.height; // start it with offset
    
    CGRect btnFrame = self.okButton.frame;
    if(self.state == InstructionsShareStatePacks)
    {
        // label
        [self.subLabel sizeToFit];
        
        
        
        self.subLabel.center = CGPointMake(self.view.center.x, self.subLabel.center.y);
        
        secondFrame.size = self.subLabel.frame.size;
        secondFrame.origin.x = self.subLabel.frame.origin.x;
        secondFrame.origin.y += 30.0f;
        
        self.subLabel.frame = CGRectIntegral(secondFrame);
        
        btnFrame.origin.y = secondFrame.origin.y + secondFrame.size.height + (IS_IPAD ? 180.0f : 130.0f);
    }
    else
    {
        // video
        
        self.videoImageView.center = CGPointMake(self.view.center.x, self.videoImageView.center.y);
        
        secondFrame.size = self.videoImageView.frame.size;
        secondFrame.origin.y += (IS_IPAD ? 160.0f : 60.0f);
        secondFrame.origin.x = self.videoImageView.frame.origin.x;
        
        self.videoImageView.frame = CGRectIntegral(secondFrame);
        
        btnFrame.origin.y = secondFrame.origin.y + secondFrame.size.height + (IS_IPAD ? 80.0f : 50.0f);
    }
    
    
    
    self.okButton.frame = btnFrame;
}



@end
