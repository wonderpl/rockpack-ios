//
// OWSaveToCameraRollActivity.m
// OWActivityViewController
//
// Copyright (c) 2013 Roman Efimov (https://github.com/romaonthego)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "OWSaveToCameraRollActivity.h"
#import "OWActivityViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation OWSaveToCameraRollActivity

- (id)init
{
    self = [super initWithTitle:NSLocalizedStringFromTable(@"activity.CameraRoll.title", @"OWActivityViewController", @"Save to Camera Roll")
                          image:[UIImage imageNamed:@"OWActivityViewController.bundle/Icon_Photos"]
                    actionBlock:nil];
    
    if (!self)
        return nil;
    
    __typeof(&*self) __weak weakSelf = self;
    self.actionBlock = ^(OWActivity *activity, OWActivityViewController *activityViewController) {
        [activityViewController dismissViewControllerAnimated:YES completion:nil];
        NSDictionary *userInfo = weakSelf.userInfo ? weakSelf.userInfo : activityViewController.userInfo;
        UIImage *image = [userInfo objectForKey:@"image"];
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageToSavedPhotosAlbum:image.CGImage
                                  orientation:(ALAssetOrientation)image.imageOrientation
                              completionBlock:nil];
    };
    
    return self;
}

@end
