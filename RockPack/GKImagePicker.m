//
//  GKImagePicker.m
//  GKImagePicker
//
//  Created by Georg Kitz on 6/1/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//

#import "GKImagePicker.h"
#import "GKImageCropViewController.h"
#import "UIFont+SYNFont.h"

@interface GKImagePicker ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, GKImageCropControllerDelegate>
@property (nonatomic, strong, readwrite) UIImagePickerController *imagePickerController;
- (void)_hideController;
@end

@implementation GKImagePicker

#pragma mark -
#pragma mark Getter/Setter

@synthesize cropSize, delegate, resizeableCropArea;
@synthesize imagePickerController = _imagePickerController;


#pragma mark -
#pragma mark Init Methods

- (id)init{
    if (self = [super init]) {
        
        self.cropSize = CGSizeMake(320, 320);
        self.resizeableCropArea = NO;
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
<<<<<<< HEAD

=======
        
>>>>>>> origin/develop
    }
    return self;
}


- (void) navigationController: (UINavigationController *) navigationController
<<<<<<< HEAD
        willShowViewController: (UIViewController *) viewController
=======
       willShowViewController: (UIViewController *) viewController
>>>>>>> origin/develop
                     animated: (BOOL) animated
{
    DebugLog (@"Items: %@", navigationController.navigationBar.items);
    UIView *containerView = [[UIView alloc] initWithFrame: CGRectMake (0, 0, 200, 28)];
    containerView.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake (0, 4, 180, 28)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont rockpackFontOfSize: 20.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    label.text = navigationController.navigationBar.topItem.title.uppercaseString;
<<<<<<< HEAD

=======
    
>>>>>>> origin/develop
    [containerView addSubview: label];
    navigationController.navigationBar.topItem.titleView = containerView;
}

<<<<<<< HEAD

=======
>>>>>>> origin/develop
# pragma mark -
# pragma mark Private Methods

- (void)_hideController{
    
    if (![_imagePickerController.presentedViewController isKindOfClass:[UIPopoverController class]]){
        
        [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
        
    } 
    
}

#pragma mark -
#pragma mark UIImagePickerDelegate Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    if ([self.delegate respondsToSelector:@selector(imagePickerDidCancel:)]) {
      
        [self.delegate imagePickerDidCancel:self];
        
    } else {
        
        [self _hideController];
    
    }
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{

    GKImageCropViewController *cropController = [[GKImageCropViewController alloc] init];
    cropController.contentSizeForViewInPopover = picker.contentSizeForViewInPopover;
    cropController.sourceImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    cropController.resizeableCropArea = self.resizeableCropArea;
    cropController.cropSize = self.cropSize;
    cropController.delegate = self;
    [picker pushViewController:cropController animated:YES];
    
}

#pragma mark -
#pragma GKImagePickerDelegate

- (void)imageCropController:(GKImageCropViewController *)imageCropController didFinishWithCroppedImage:(UIImage *)croppedImage{
    
    if ([self.delegate respondsToSelector:@selector(imagePicker:pickedImage:)]) {
        [self.delegate imagePicker:self pickedImage:croppedImage];   
    }
}

@end
