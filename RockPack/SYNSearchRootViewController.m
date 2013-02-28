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

@interface SYNSearchRootViewController ()

@property (nonatomic) NSInteger tabSelected;

@property (nonatomic, strong) SYNSearchVideosViewController* searchVideosController;
@property (nonatomic, strong) SYNSearchChannelsViewController* searchChannelsController;

@property (nonatomic, weak) SYNAbstractViewController* currentController;

@property (nonatomic, strong) NSString* currentSelectionId;



@end

@implementation SYNSearchRootViewController

@synthesize searchTerm = _searchTerm;


-(void)loadView
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect frame = CGRectMake(0.0, 0.0, screenBounds.size.width, screenBounds.size.height);
    self.view = [[UIView alloc] initWithFrame:frame];
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchVideosController = [[SYNSearchVideosViewController alloc] initWithViewId:viewId];
    self.searchChannelsController = [[SYNSearchChannelsViewController alloc] initWithViewId:viewId];
    
	
}


-(void)setSearchTerm:(NSString *)term
{
    if(!_searchTerm && term) { // first time
        _searchTerm = term;
        [self.tabViewController setSelectedWithId:@"0"];
        return;
    }
        
    _searchTerm = term;
    
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.searchTerm = nil;
    
    // clear the context
    
    
}

-(void)handleNewTabSelectionWithId:(NSString *)selectionId
{
    
    SYNAbstractViewController* newController;
    
    if ([selectionId isEqualToString:@"0"])
    {
        
        [self.view insertSubview:self.searchVideosController.view belowSubview:self.tabViewController.view];
        [self.searchVideosController performSearchWithTerm:self.searchTerm];
        newController = self.searchVideosController;
        
    }
    else
    {
        [self.view insertSubview:self.searchChannelsController.view belowSubview:self.tabViewController.view];
        [self.searchChannelsController performSearchWithTerm:self.searchTerm];
        newController = self.searchChannelsController;
    }
    
    
    if(self.currentController)
        [self.currentController.view removeFromSuperview];
    
    self.currentController = newController;
    
    
}


@end
