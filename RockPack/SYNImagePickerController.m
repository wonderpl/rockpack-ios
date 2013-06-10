//
//  SYNImagePickerController.m
//  rockpack
//
//  Created by Mats Trovik on 15/05/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNImagePickerController.h"
#import "SYNCameraPopoverViewController.h"
#import "SYNPopoverBackgroundView.h"
#import "GKImagePicker.h"
#import "SYNDeviceManager.h"

@interface SYNImagePickerController () <SYNCameraPopoverViewControllerDelegate, UIPopoverControllerDelegate, GKImagePickerDelegate, UIActionSheetDelegate>
{
    BOOL didShowModally;
}

@property (nonatomic,strong)UIPopoverController* cameraMenuPopoverController;
@property (nonatomic,strong)UIPopoverController* cameraPopoverController;
@property (nonatomic,strong)GKImagePicker* imagePicker;
@property (nonatomic,weak) UIView* popoverPresentingView;
@property (nonatomic, assign) UIPopoverArrowDirection direction;
@end

@implementation SYNImagePickerController 

-(id)initWithHostViewController:(UIViewController*)host
{
    self = [super init];
    if(self)
    {
        _hostViewController = host;
    }
    return self;
}

-(void)presentImagePickerAsPopupFromView:(UIView*)view arrowDirection:(UIPopoverArrowDirection)direction
{
    if([SYNDeviceManager.sharedInstance isIPhone])
    {
        [self presentImagePickerModally];
    }
    else
    {
        self.popoverPresentingView = view;
        self.direction = direction;
        SYNCameraPopoverViewController *actionPopoverController = [[SYNCameraPopoverViewController alloc] init];
        actionPopoverController.delegate = self;
        
        // Need show the popover controller
        self.cameraMenuPopoverController = [[UIPopoverController alloc] initWithContentViewController: actionPopoverController];
        self.cameraMenuPopoverController.popoverContentSize = CGSizeMake(206, 96);
        self.cameraMenuPopoverController.delegate = self;
        self.cameraMenuPopoverController.popoverBackgroundViewClass = [SYNPopoverBackgroundView class];
        
        [self.cameraMenuPopoverController presentPopoverFromRect: self.popoverPresentingView.frame
                                                          inView: self.hostViewController.view
                                        permittedArrowDirections: self.direction
                                                        animated: YES];
    }
}


-(void)presentImagePickerModally
{
    if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIActionSheet* sourceSelector = [[UIActionSheet alloc] initWithTitle: NSLocalizedString(@"channel_creation_screen_select_upload_photo_label", nil)
                                                                    delegate: self
                                                           cancelButtonTitle: NSLocalizedString(@"Cancel", nil)
                                                      destructiveButtonTitle: nil
                                                           otherButtonTitles: NSLocalizedString(@"camera_popover_button_takephoto_label", nil),
                                         NSLocalizedString(@"camera_popover_button_choose_label", nil), nil];
        [sourceSelector showInView:self.hostViewController.view];
    }
    else
    {
        [self showImagePickerModally:UIImagePickerControllerSourceTypePhotoLibrary];
    }

}

- (void) popoverControllerDidDismissPopover: (UIPopoverController *) popoverController
{
    if (popoverController == self.cameraMenuPopoverController)
    {
        self.cameraMenuPopoverController = nil;
    }
    else if (popoverController == self.cameraPopoverController)
    {
        self.cameraPopoverController = nil;
        self.imagePicker = nil;
    }
    else
    {
        AssertOrLog(@"Unknown popup dismissed");
    }
}


- (void) userTouchedTakePhotoButton
{
    [self.cameraMenuPopoverController dismissPopoverAnimated: NO];
    [self showImagePicker: UIImagePickerControllerSourceTypeCamera];
}


- (void) userTouchedChooseExistingPhotoButton
{
    [self.cameraMenuPopoverController dismissPopoverAnimated: NO];
    [self showImagePicker: UIImagePickerControllerSourceTypePhotoLibrary];
}


- (void) showImagePicker: (UIImagePickerControllerSourceType) sourceType
{
    if([SYNDeviceManager.sharedInstance isIPhone])
    {
        [self showImagePickerModally:sourceType];
        return;
    }
    self.imagePicker = [[GKImagePicker alloc] init];
    self.imagePicker.cropSize = CGSizeMake(280, 280);
    self.imagePicker.delegate = self;
    self.imagePicker.imagePickerController.sourceType = sourceType;
    
    if ((sourceType == UIImagePickerControllerSourceTypeCamera) && [UIImagePickerController respondsToSelector: @selector(isCameraDeviceAvailable:)])
    {
        if ([UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront])
        {
            self.imagePicker.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
    }
    self.cameraPopoverController = [[UIPopoverController alloc] initWithContentViewController: self.imagePicker.imagePickerController];
    
    self.cameraPopoverController.popoverBackgroundViewClass = [SYNPopoverBackgroundView class];
    
    [self.cameraPopoverController presentPopoverFromRect: self.popoverPresentingView.frame
                                                  inView: self.hostViewController.view
                                permittedArrowDirections: self.direction
                                                animated: YES];
    
    self.cameraPopoverController.delegate = self;
    
}

- (void) showImagePickerModally: (UIImagePickerControllerSourceType) sourceType
{
    didShowModally = YES;
    self.imagePicker = [[GKImagePicker alloc] init];
    self.imagePicker.cropSize = CGSizeMake(280, 280);
    self.imagePicker.delegate = self;
    self.imagePicker.imagePickerController.sourceType = sourceType;
    
    if ((sourceType == UIImagePickerControllerSourceTypeCamera) && [UIImagePickerController respondsToSelector: @selector(isCameraDeviceAvailable:)])
    {
        if ([UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront])
        {
            self.imagePicker.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
    }
    
    [self.hostViewController presentViewController: self.imagePicker.imagePickerController
                       animated: YES
                     completion: nil];
}


# pragma mark - GKImagePicker Delegate Methods

- (void) imagePicker: (GKImagePicker *) imagePicker
         pickedImage: (UIImage *) image
{
    [self hideImagePicker];
    if([self.delegate respondsToSelector:@selector(picker:finishedWithImage:)])
    {
        [self.delegate picker:self finishedWithImage:image];
    }
}

- (void) hideImagePicker
{
    if(didShowModally)
    {
        [self.hostViewController dismissViewControllerAnimated:YES completion:nil];
        self.imagePicker = nil;
    }
    else
    {
        [self.cameraPopoverController dismissPopoverAnimated: YES];
    }
}

#pragma mark - actionsheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //Camera
        [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
    }
    else if (buttonIndex ==1)
    {
        //Choose existing
        [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}


@end
