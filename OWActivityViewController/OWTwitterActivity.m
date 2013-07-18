//
// OWTwitterActivity.m
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

#import "OWActivityViewController.h"
#import "OWTwitterActivity.h"
#import <Twitter/Twitter.h>

@implementation OWTwitterActivity

- (id) init
{
    self = [super initWithTitle: NSLocalizedStringFromTable(@"activity.Twitter.title", @"OWActivityViewController", @"Twitter")
                          image: [UIImage imageNamed: @"OWActivityViewController.bundle/Icon_Twitter"]
                    actionBlock: nil];
    
    if (!self)
    {
        return nil;
    }
    
    __typeof(&*self) __weak weakSelf = self;
    self.actionBlock = ^(OWActivity *activity, OWActivityViewController *activityViewController) {
        UIViewController *presenter = activityViewController.presentingController;
        NSDictionary *userInfo = weakSelf.userInfo ? weakSelf.userInfo : activityViewController.userInfo;
        
        [activityViewController dismissViewControllerAnimated: YES
                                                   completion: ^{
                                                       [weakSelf  shareFromViewController: presenter
                                                                                     text: userInfo[@"text"]
                                                                                      url: userInfo[@"url"]
                                                                                    image: userInfo[@"image"]];
                                                   }];
    };
    
    return self;
}
- (void) shareFromViewController: (UIViewController *) viewController text: (NSString *) text url: (NSURL *) url image: (UIImage *) image
{
    SLComposeViewController *twitterViewComposer = nil;
    
    twitterViewComposer = [SLComposeViewController composeViewControllerForServiceType: SLServiceTypeTwitter];
    
    // Add a completion handler so that we can check for completion
    twitterViewComposer.completionHandler = ^(SLComposeViewControllerResult result) {
        if (result == SLComposeViewControllerResultDone)
        {
            [self updateAPIRater];
        }
    };
    
    viewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    if (text)
    {
        [twitterViewComposer setInitialText: text];
    }
    
    if (image)
    {
        [twitterViewComposer addImage: image];
    }
    
    if (url)
    {
        [twitterViewComposer addURL: url];
    }
    
    [viewController presentViewController: twitterViewComposer
                                 animated: YES
                               completion: nil];
}
@end
