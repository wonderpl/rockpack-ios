//
//  SYNSearchRootViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 27/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchRootViewController.h"

#import "SYNSearchVideosViewController.h"
#import "SYNSearchChannelsViewController.h"
#import "AppConstants.h"
#import "SYNSearchTabViewController.h"

@interface SYNSearchRootViewController ()

@property (nonatomic) NSInteger tabSelected;

@property (nonatomic, strong) SYNSearchVideosViewController* searchVideosController;
@property (nonatomic, strong) SYNSearchChannelsViewController* searchChannelsController;

@property (nonatomic, weak) SYNAbstractViewController* currentController;

@property (nonatomic, weak) UIView* currentOverlayView;

@property (nonatomic, strong) NSString* currentSelectionId;


@end

@implementation SYNSearchRootViewController



-(void)loadView
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect frame = CGRectMake(0.0, 0.0, screenBounds.size.width, screenBounds.size.height);
    self.view = [[UIView alloc] initWithFrame:frame];
    self.view.backgroundColor = [UIColor clearColor];
}



-(void)showSearchResultsForTerm:(NSString*)newSearchTerm
{
    
    if(searchTerm && [searchTerm isEqualToString:newSearchTerm])
        return;
    
    
    searchTerm = newSearchTerm;
    
    if(!searchTerm)
        return;
    
    if(!viewIsOnScreen)
        return;
    
    
    [self performSearchForCurrentSearchTerm];
    
    
}




-(void)viewWillAppear:(BOOL)animated
{
    
    // TODO: Check why we have to invert
    
    self.searchVideosController = [[SYNSearchVideosViewController alloc] initWithViewId:viewId];
    self.searchVideosController.itemToUpdate = ((SYNSearchTabViewController*)self.tabViewController).searchVideosItemView;
    self.searchVideosController.parent = self;
    
    self.searchChannelsController = [[SYNSearchChannelsViewController alloc] initWithViewId:viewId];
    self.searchChannelsController.itemToUpdate = ((SYNSearchTabViewController*)self.tabViewController).searchChannelsItemView;
    self.searchChannelsController.parent = self;
    
    
    viewIsOnScreen = YES;
    
    if(searchTerm)
        [self performSearchForCurrentSearchTerm];
    
    
}

-(void)performSearchForCurrentSearchTerm
{
    
    [self clearOldSearchData];
    
    if(!self.currentController)
        [self.tabViewController setSelectedWithId:@"0"];
    
    
    [self.searchVideosController performSearchWithTerm:searchTerm];
    [self.searchChannelsController performSearchWithTerm:searchTerm];
}

-(void)clearOldSearchData
{
    
    [appDelegate.searchRegistry clearImportContextFromEntityName:@"VideoInstance"];
    
    [appDelegate.searchRegistry clearImportContextFromEntityName:@"Channel"];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self clearController];
    
}

-(void)clearController
{
    
    //searchTerm = nil;
    
    viewIsOnScreen = NO;
    
    
    [self.currentController.view removeFromSuperview];
    
    self.currentController = nil;
    
    
    self.searchVideosController = nil;
    self.searchChannelsController = nil;
}

-(void)handleNewTabSelectionWithId:(NSString *)selectionId
{
    
    SYNAbstractViewController* newController;
    
    if ([selectionId isEqualToString:@"0"])
    {
        
        [self.view insertSubview:self.searchVideosController.view belowSubview:self.tabViewController.view];
        newController = self.searchVideosController;
        
    }
    else
    {
        [self.view insertSubview:self.searchChannelsController.view belowSubview:self.tabViewController.view];
        newController = self.searchChannelsController;
    }
    
    
    if(self.currentController)
        [self.currentController.view removeFromSuperview];
    
    self.currentController = newController;
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kVideoQueueShow
                                                        object:self
                                                      userInfo:@{@"lock" : @(YES)}];
}




#pragma mark - Animation support

// Old method, might come in use again

// Special animation of pushing new view controller onto UINavigationController's stack
//- (void) animatedPushViewController: (UIViewController *) vc
//{
//    
//    vc.view.alpha = 0.0f;
//    [self.view insertSubview:vc.view belowSubview:self.tabViewController.view];
//    
//    [UIView animateWithDuration: 0.5f
//                          delay: 0.0f
//                        options: UIViewAnimationOptionCurveEaseInOut
//                     animations: ^{
//                         
//                         vc.view.alpha = 1.0f;
//                         self.tabViewController.view.alpha = 0.0;
//        
//         
//     } completion: ^(BOOL finished) {
//         
//     }];
//    
//    [self.navigationController pushViewController: vc
//                                         animated: NO];
//    
//    _currentOverlayView = vc.view;
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNoteBackButtonShow object:self];
//}
//
//
//- (void) animatedPopViewController
//{
//    
//    [self.navigationController popViewControllerAnimated: NO];
//    
//    [UIView animateWithDuration: 0.5f
//                          delay: 0.0f
//                        options: UIViewAnimationOptionCurveEaseInOut
//                     animations: ^{
//                         
//                         _currentOverlayView.alpha = 0.0f;
//                         self.tabViewController.view.alpha = 1.0;
//                         
//                     }
//                     completion: ^(BOOL finished) {
//                         [self.navigationController popViewControllerAnimated: NO];
//                         _currentOverlayView = nil;
//         
//                     }];
//    
//    
//    
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNoteBackButtonHide object:self];
//}


@end
