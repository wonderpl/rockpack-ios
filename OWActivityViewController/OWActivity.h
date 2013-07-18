//
// OWActivity.h
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

#import "Appirater.h"
#import <Foundation/Foundation.h>

@class OWActivityViewController;
@class OWActivity;

typedef void (^OWActivityActionBlock)(OWActivity *activity, OWActivityViewController *activityViewController);

@interface OWActivity : NSObject

@property (strong, readonly, nonatomic) NSString *title;
@property (strong, readonly, nonatomic) UIImage *image;
@property (copy, nonatomic) OWActivityActionBlock actionBlock;
@property (strong, nonatomic) OWActivityViewController *activityViewController;
@property (strong, nonatomic) NSDictionary *userInfo;

- (id) initWithTitle: (NSString *) title
               image: (UIImage *) image
         actionBlock: (OWActivityActionBlock) actionBlock;

- (void) updateAPIRater;

@end
