//
//  SYNCollectionViewController.m
//  rockpack
//
//  Created by Nick Banks on 24/09/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCollectionViewController.h"
#import "SYNCellHighlightProtocol.h"
#import "SYNAbstractViewController.h"

@interface SYNCollectionViewController () <UIGestureRecognizerDelegate,
                                           SYNCellHighlightProtocol>

@property (nonatomic, assign) id<UICollectionViewDelegate> delegate;
@property (nonatomic, assign) id<UICollectionViewDataSource> dataSource;

@end


@implementation SYNCollectionViewController

#pragma mark - View Lifecycle

- (void) commonInit
{
    // Make sure our wrapper view has a clear background
    self.view.backgroundColor = [UIColor clearColor];
    
    // Now set up a few things that never change about our collection view
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.scrollsToTop = NO;
}


- (id) initWithNibName: (NSString *) nibNameOrNil bundle: (NSBundle *) nibBundleOrNil
{
    if (self = [super initWithNibName: nibNameOrNil
                           bundle: nibBundleOrNil])
    {
        [self commonInit];
    }
    
    return self;
}


- (id) initWithCollectionViewLayout: (UICollectionViewLayout *) layout
{
    if (self = [super initWithCollectionViewLayout: layout])
    {
        [self commonInit];
    }
    
    return self;

}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Set up our gesture recognisers
    self.touchGestureRecognizer = [[SYNTouchGestureRecognizer alloc] initWithTarget: self
                                                                             action: @selector(touchRecognized:)];
    self.touchGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer: self.touchGestureRecognizer];
    
    // Tap for showing video
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                        action: @selector(tapRecognized:)];
    self.tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer: self.tapGestureRecognizer];

    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget: self
                                                                                    action: @selector(longPressRecognized:)];
    self.longPressGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer: self.longPressGestureRecognizer];
}


#pragma mark - Gesture support

// We need this to ensure that on UICollectionViewCells with controls, those controls receive the touches
// the delete 'X' is one of these controls (this is why we set up the delegates above)
- (BOOL) gestureRecognizer: (UIGestureRecognizer *) gestureRecognizer
        shouldReceiveTouch: (UITouch *) touch
{
    if ([touch.view isKindOfClass: [UIControl class]])
    {
        // we touched a button, slider, or other UIControl
        return NO; // ignore the touch
    }
    
    return YES; // handle the touch
}


#pragma mark - Gesture targets

- (void) touchRecognized: (SYNTouchGestureRecognizer *) recognizer
{
    DebugLog(@"Touch recognised");
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint: [recognizer locationOfTouch: 0
                                                                                                inView: self.collectionView]];
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath: indexPath];
    
    if ([cell respondsToSelector: @selector(lowlight:)])
    {
        CGPoint pointInCell = [recognizer locationOfTouch: 0 inView: cell];
        
        switch (recognizer.state)
        {
            case UIGestureRecognizerStateBegan:
            {
                [(SYNAbstractViewController *)self.collectionView.delegate arcMenuSelectedCell: cell
                                               andComponentIndex: kArcMenuInvalidComponentIndex];
                
                [(id <SYNCellHighlightProtocol>)cell setLowlight: TRUE
                                                        forPoint: pointInCell];
                break;
            }
                
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateFailed:
            {
                [(id <SYNCellHighlightProtocol>)cell setLowlight: TRUE
                                                        forPoint: pointInCell];
                break;
            }
                
            default:
                break;
        }


    }
}


- (void) tapRecognized: (UITapGestureRecognizer *) recognizer
{
    DebugLog(@"Tap recognised");
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint: [recognizer locationOfTouch: 0
                                                                                                inView: self.collectionView]];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath: indexPath];
    
    if (self.tapRecognizedBlock)
    {
        self.tapRecognizedBlock(cell);
    }
}


- (void) longPressRecognized: (UILongPressGestureRecognizer *) recognizer
{
    DebugLog(@"Long press recognised");
    if (self.longPressRecognizedBlock)
    {
        self.longPressRecognizedBlock(recognizer);
    }
}


@end
