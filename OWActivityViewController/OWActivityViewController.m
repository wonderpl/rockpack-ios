//
// OWActivityViewController.m
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

#import "OWActivityView.h"
#import "OWActivityViewController.h"

@interface OWActivityViewController ()

- (NSInteger) height;

@end

@implementation OWActivityViewController

- (void) loadView
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        self.view = [[UIView alloc] initWithFrame: rootViewController.view.bounds];
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

    }
    else
    {
        [super loadView];
    }
}


- (id) initWithViewController: (UIViewController *) viewController
                   activities: (NSArray *) activities
{
    self = [super init];
    
    if (self)
    {
        self.presentingController = viewController;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
             self.view.frame = CGRectMake(0, 0, 420, 96);
            
            _backgroundView = [[UIView alloc] initWithFrame: self.view.bounds];
            _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _backgroundView.backgroundColor = [UIColor blackColor];
            _backgroundView.alpha = 0;
            
            // Tap outside of view to close share
            UITapGestureRecognizer *tapOutside =
            [[UITapGestureRecognizer alloc] initWithTarget: self
                                                    action: @selector(dismissViewControllerOnTouch)];
            
            [_backgroundView addGestureRecognizer: tapOutside];
            
            [self.view addSubview: _backgroundView];
        }
        else
        {
            self.view.frame = CGRectMake(0, 0, 420, 96);
        }
        
        _activities = activities;
        
        _activityView = [[OWActivityView alloc] initWithFrame: CGRectMake(0, 0,
                                                                          self.view.frame.size.width, self.height)
                                                   activities: activities];
        
        _activityView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        _activityView.activityViewController = self;
        
        [self.view addSubview: _activityView];
        
//        self.contentSizeForViewInPopover = CGSizeMake(320 + 8, self.height);
    }
    
    return self;
}


- (void) dismissViewControllerAnimated: (BOOL) flag completion: (void (^)(void)) completion
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        __typeof(&*self) __weak weakSelf = self;
        [UIView animateWithDuration: 0.2
                         animations: ^{
                             _backgroundView.alpha = 0;
                             CGRect frame = _activityView.frame;
                             frame.origin.y = [UIScreen mainScreen].bounds.size.height;
                             _activityView.frame = frame;
                         }
                         completion: ^(BOOL finished) {
                             [weakSelf.view removeFromSuperview];
                             [weakSelf removeFromParentViewController];
                             
                             if (completion)
                             {
                                 completion();
                             }
                         }];
    }
    else
    {
        [self.presentingPopoverController dismissPopoverAnimated: YES];
        
        [self performBlock: ^{
            if (completion)
            {
                completion();
            }
        } afterDelay: 0.4];
    }
}


//This handles the tap outside
- (void) dismissViewControllerOnTouch
{
    [self dismissViewControllerAnimated: YES
                             completion: nil];
}


- (void) presentFromRootViewController
{
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    
    [rootViewController addChildViewController: self];
    [rootViewController.view addSubview: self.view];
    [self didMoveToParentViewController: rootViewController];
}


- (void) didMoveToParentViewController: (UIViewController *) parent
{
    [super didMoveToParentViewController: parent];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [UIView animateWithDuration: 0.2
                         animations: ^{
                             _backgroundView.alpha = 0.4;
                             
                             CGRect frame = _activityView.frame;
                             frame.origin.y = self.view.frame.size.height - self.height;
                             _activityView.frame = frame;
                         }];
    }
}


- (NSInteger) height
{
    return 56;
}


- (void) viewDidLoad
{
    [super viewDidLoad];
}


#pragma mark -
#pragma mark Helpers

- (void) performBlock: (void (^)(void)) block afterDelay: (NSTimeInterval) delay
{
    block = [block copy];
    
    [self performSelector: @selector(runBlockAfterDelay:)
               withObject: block
               afterDelay: delay];
}


- (void) runBlockAfterDelay: (void (^)(void)) block
{
    if (block != nil)
    {
        block();
    }
}


#pragma mark -
#pragma mark Orientation

- (NSUInteger) supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return UIInterfaceOrientationMaskAll;
    }
    
    return UIInterfaceOrientationMaskPortrait;
}


- (BOOL) shouldAutorotate
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return YES;
    }
    
    return NO;
}


- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) orientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return YES;
    }
    
    return orientation == UIInterfaceOrientationPortrait;
}


//- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
//                                          duration: (NSTimeInterval) duration
//{
//    [super willAnimateRotationToInterfaceOrientation: toInterfaceOrientation
//                                            duration: duration];
//    
//    self.view.center = self.view.superview.center;
//}
//
//- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation
//{
//        self.view.center = self.view.superview.center;
//}


@end
