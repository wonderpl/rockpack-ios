//
//  SYNCategoryChooserViewController.m
//  rockpack
//
//  Created by Nick Banks on 28/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCategoriesTabViewController.h"
#import "SYNCategoryChooserViewController.h"
#import "SYNMasterViewController.h"
#import "SYNTabViewDelegate.h"
#import "UIFont+SYNFont.h"

@interface SYNCategoryChooserViewController () <SYNTabViewDelegate>

@property (nonatomic, strong) IBOutlet UILabel *header;
@property (nonatomic, strong) IBOutlet UILabel *body;
@property (nonatomic, strong) SYNCategoriesTabViewController *categoriesTabViewController;

@end


@implementation SYNCategoryChooserViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Google Analytics support
    self.trackedViewName = @"Channel Creation - Choose Category";
    
    // Set custom fonts
    self.header.font = [UIFont boldRockpackFontOfSize: 28.0f];
    self.body.font = [UIFont rockpackFontOfSize: 17.0f];
    
    self.categoriesTabViewController = [[SYNCategoriesTabViewController alloc] init];
    self.categoriesTabViewController.delegate = self;
    CGRect tabFrame = self.categoriesTabViewController.view.frame;
    tabFrame.origin.y += 256;
    self.categoriesTabViewController.view.frame = tabFrame;
    [self.view addSubview: self.categoriesTabViewController.view];
}



- (IBAction) userTouchedPublishButton
{
    [self.overlayParent removeCategoryChooserOverlayController];
}

- (IBAction) userTouchedSkipButton
{
    [self.overlayParent removeCategoryChooserOverlayController];
}

- (BOOL) showSubcategories
{
    return YES;
}

- (void) handleMainTap: (UITapGestureRecognizer*) recogniser
{
    
}

- (void) handleSecondaryTap: (UITapGestureRecognizer*) recogniser
{
    
}

// general
- (void) handleNewTabSelectionWithId: (NSString*) temId
{
    
}

@end
