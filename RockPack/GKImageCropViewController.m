//
//  GKImageCropViewController.m
//  GKImagePicker
//
//  Created by Georg Kitz on 6/1/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//

#import "GKImageCropView.h"
#import "GKImageCropViewController.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>
#import "SYNDeviceManager.h"

@interface GKImageCropViewController ()

@property (nonatomic, strong) GKImageCropView *imageCropView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *useButton;
@property (nonatomic, strong) UIToolbar *toolbar;

- (void)_actionCancel;
- (void)_actionUse;
- (void)_setupNavigationBar;
- (void)_setupCropView;

@end

@implementation GKImageCropViewController

#pragma mark -
#pragma mark Getter/Setter

@synthesize sourceImage, cropSize, delegate;
@synthesize imageCropView;
@synthesize toolbar;
@synthesize cancelButton, useButton, resizeableCropArea;

#pragma mark -
#pragma Private Methods


- (void)_actionCancel{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)_actionUse{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    _croppedImage = [self.imageCropView croppedImage];
    [self.delegate imageCropController:self didFinishWithCroppedImage:_croppedImage];
}


- (void)_setupNavigationBar
{
    // Add title (offset due to custom font)
    UIView *containerView = [[UIView alloc] initWithFrame: CGRectMake (0, 0, 200, 28)];
    containerView.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake (0, 4, 180, 28)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont rockpackFontOfSize: 20.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    label.text = self.navigationItem.title;
    [containerView addSubview: label];
    self.navigationItem.titleView = containerView;
    
    UIButton *customCancelButton = [UIButton buttonWithType: UIButtonTypeCustom];
    UIImage* customCancelButtonImage = [UIImage imageNamed: @"ButtonMoveAndScaleCancel.png"];
    UIImage* customCancelButtonHighlightedImage = [UIImage imageNamed: @"ButtonMoveAndScaleCancelHighlighted.png"];
    
    [customCancelButton setImage: customCancelButtonImage
                        forState: UIControlStateNormal];
    
    [customCancelButton setImage: customCancelButtonHighlightedImage
                        forState: UIControlStateHighlighted];
    
    [customCancelButton addTarget: self
                           action: @selector(_actionCancel)
                 forControlEvents: UIControlEventTouchUpInside];
    
    customCancelButton.frame = CGRectMake(0.0, 0.0, customCancelButtonImage.size.width, customCancelButtonImage.size.height);
    UIBarButtonItem *customCancelButtonItem = [[UIBarButtonItem alloc] initWithCustomView: customCancelButton];
    
    self.navigationItem.leftBarButtonItem = customCancelButtonItem;
    
    UIButton *customUseButton = [UIButton buttonWithType: UIButtonTypeCustom];
    UIImage* customUseButtonImage = [UIImage imageNamed: @"ButtonMoveAndScaleUse.png"];
    UIImage* customUseButtonHighlightedImage = [UIImage imageNamed: @"ButtonMoveAndScaleUseHighlighted.png"];
    
    [customUseButton setImage: customUseButtonImage
                     forState: UIControlStateNormal];
    
    [customUseButton setImage: customUseButtonHighlightedImage
                     forState: UIControlStateHighlighted];
    
    [customUseButton addTarget: self
                        action: @selector(_actionUse)
              forControlEvents: UIControlEventTouchUpInside];
    
    customUseButton.frame = CGRectMake(0.0, 0.0, customUseButtonImage.size.width, customUseButtonImage.size.height);
    UIBarButtonItem *customUseButtonItem = [[UIBarButtonItem alloc] initWithCustomView: customUseButton];
        
    self.navigationItem.rightBarButtonItem = customUseButtonItem;
}


- (void)_setupCropView{
    
    self.imageCropView = [[GKImageCropView alloc] initWithFrame:self.view.bounds];
    [self.imageCropView setImageToCrop:sourceImage];
    [self.imageCropView setResizableCropArea:self.resizeableCropArea];
    [self.imageCropView setCropSize:cropSize];
    [self.view addSubview:self.imageCropView];
}

- (void)_setupCancelButton{
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"ButtonCancel~iphone.png"] forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"ButtonCancelHighlighted~iphone.png"] forState:UIControlStateHighlighted];
    
    [[self.cancelButton titleLabel] setFont: [UIFont boldRockpackFontOfSize: 11.0]];
    [[self.cancelButton titleLabel] setShadowOffset:CGSizeMake(0, 1)];
    [self.cancelButton setFrame:CGRectMake(0, 0, 48, 49)];
    [self.cancelButton setTitle:nil forState:UIControlStateNormal];
    [self.cancelButton setTitleShadowColor:[UIColor colorWithRed:0.827 green:0.831 blue:0.839 alpha:1] forState:UIControlStateNormal];
    [self.cancelButton  addTarget:self action:@selector(_actionCancel) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)_setupUseButton{
    
    self.useButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.useButton setBackgroundImage:[UIImage imageNamed:@"ButtonConfirmYellow~iphone.png"] forState:UIControlStateNormal];
    [self.useButton setBackgroundImage:[UIImage imageNamed:@"ButtonConfirmYellowHighlighted~iphone.png"] forState:UIControlStateHighlighted];
    
    [[self.useButton titleLabel] setFont:[UIFont boldRockpackFontOfSize:11]];
    [[self.useButton titleLabel] setShadowOffset:CGSizeMake(0, -1)];
    [self.useButton setFrame:CGRectMake(0, 0, 48, 49)];
    [self.useButton setTitle:nil forState:UIControlStateNormal];
    [self.useButton setTitleShadowColor:[UIColor colorWithRed:0.118 green:0.247 blue:0.455 alpha:1] forState:UIControlStateNormal];
    [self.useButton  addTarget:self action:@selector(_actionUse) forControlEvents:UIControlEventTouchUpInside];
    
}

- (UIImage *)_toolbarBackgroundImage{
    
    const float colorMask[6] = {222, 255, 222, 255, 222, 255};
    UIImage *img = [[UIImage alloc] init];
    CGImageRef imgRef = CGImageCreateWithMaskingColors(img.CGImage, colorMask);
    UIImage *maskedImage = [UIImage imageWithCGImage: imgRef];
    CGImageRelease(imgRef);
    
    [self.toolbar setBackgroundImage:maskedImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    return maskedImage;
}

- (void)_setupToolbar{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
        self.toolbar.clipsToBounds = YES;

        [self.toolbar setBackgroundImage:[self _toolbarBackgroundImage] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        [self.view addSubview:self.toolbar];
        
        [self _setupCancelButton];
        [self _setupUseButton];
        
        UILabel *info = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width-250)/2, 0, 320, 40)];
        info.text = NSLocalizedString(@"MOVE AND SCALE", nil);
        info.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1];
        info.font = [UIFont rockpackFontOfSize:18];
        info.layer.shadowColor = [[UIColor colorWithRed:(1.0/255.0) green:(1.0/255.0) blue:(1.0/255.0) alpha:(1.0)] CGColor];
        info.layer.shadowOffset = CGSizeMake(0.0, 1.0);
        info.layer.shadowRadius = 1.0;
        info.layer.shadowOpacity = 1.0;
        info.backgroundColor = [UIColor clearColor];
        info.textAlignment = NSTextAlignmentCenter;
        //[info sizeToFit];        
        
        UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithCustomView:self.cancelButton];
        UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *lbl = [[UIBarButtonItem alloc] initWithCustomView:info];
        UIBarButtonItem *use = [[UIBarButtonItem alloc] initWithCustomView:self.useButton];

        
        [self.toolbar setItems:@[cancel, flex, lbl, flex, use]];
    }
}

#pragma mark -
#pragma Super Class Methods

- (id)init{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"MOVE AND SCALE", @"");
    
    [self _setupNavigationBar];
    [self _setupCropView];
    [self _setupToolbar];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setNavigationBarHidden:YES];
    } else {
		[self.navigationController setNavigationBarHidden:NO];
	}
}

- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
        
    self.imageCropView.frame = CGRectMake(self.view.center.x - (self.view.frame.size.width * 0.5), (self.view.center.y) - (self.view.frame.size.height *0.5), self.view.frame.size.width,self.view.frame.size.height);
    
    self.toolbar.frame = CGRectMake((self.view.center.x + 6) - (self.view.frame.size.width * 0.5), self.view.center.y - 174, 308, 54);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
