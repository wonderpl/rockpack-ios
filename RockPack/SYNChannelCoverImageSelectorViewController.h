//
//  SYNChannelCoverImageSelectorViewController.h
//  rockpack
//
//  Created by Mats Trovik on 08/05/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class SYNChannelCoverImageSelectorViewController;

@protocol SYNChannelCoverImageSelectorDelegate <NSObject>

@optional
-(void)imageSelector:(SYNChannelCoverImageSelectorViewController*)imageSelector didSelectImage:(NSString*)imageUrl;
-(void)closeImageSelector:(SYNChannelCoverImageSelectorViewController*)imageSelector;

@end

@interface SYNChannelCoverImageSelectorViewController : UIViewController

@property (nonatomic, strong) NSFetchedResultsController *channelCoverFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *userChannelCoverFetchedResultsController;

@property (nonatomic, weak) id<SYNChannelCoverImageSelectorDelegate> imageSelectorDelegate;
-(void)refreshChannelCoverData;

@end
