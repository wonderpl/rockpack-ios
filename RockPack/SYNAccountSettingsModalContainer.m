//
//  SYNAccountSettingsModalContainer.m
//  rockpack
//
//  Created by Michael Michailidis on 30/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAccountSettingsModalContainer.h"
#import "UIFont+SYNFont.h"



@interface SYNAccountSettingsModalContainer ()
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (copy) DoneButtonBlock doneBlock;

@end

@implementation SYNAccountSettingsModalContainer


-(id)initWithNavigationController:(UINavigationController*)navigationController andCompletionBlock:(DoneButtonBlock)block
{
    if(self = [super initWithNibName:@"SYNAccountSettingsModalContainer" bundle:[NSBundle mainBundle]])
    {
        childNavigationController = navigationController;
        childNavigationController.delegate = self;
        [self addChildViewController:childNavigationController];
        _doneBlock = block;
        
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = CGRectMake(0.0, 0.0, 320.0, 600.0);
    
    [self.contentView addSubview:childNavigationController.view];
    
    self.backgroundImage.image = [[UIImage imageNamed:@"PanelMenuSecondLevel"] resizableImageWithCapInsets:UIEdgeInsetsMake(65, 0, 1, 0)];
    
    self.titleLabel.font = [UIFont rockpackFontOfSize:self.titleLabel.font.pointSize];
    self.titleLabel.text = NSLocalizedString(@"SETTINGS",nil);
	
}

- (IBAction)backButtonTapped:(id)sender {
    [childNavigationController popViewControllerAnimated:YES];
}
- (IBAction)doneButtonTapped:(id)sender {
    self.doneBlock();
}

-(void)setModalViewFrame:(CGRect)newFrame
{
    self.view.frame = newFrame;
    childNavigationController.view.frame = self.contentView.bounds;
}

#pragma mark - navigation controller delegate
-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
   if(viewController == [navigationController.viewControllers objectAtIndex:0] )
   {
       self.doneButton.hidden = NO;
       self.backButton.hidden = NO;
       [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
           self.doneButton.alpha = 1.0f;
           self.backButton.alpha = 0.0f;
       } completion:^(BOOL finished) {
           self.doneButton.hidden = NO;
           self.backButton.hidden = YES;
           
       }];
   }
    else
    {
        self.doneButton.hidden = NO;
        self.backButton.hidden = NO;
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.doneButton.alpha = 0.0f;
            self.backButton.alpha = 1.0f;
        } completion:^(BOOL finished) {
            self.doneButton.hidden = YES;
            self.backButton.hidden = NO;
            
        }];
    }
    
   
}



@end
