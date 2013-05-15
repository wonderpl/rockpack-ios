//
//  SYNCoverChooserController.h
//  rockpack
//
//  Created by Michael Michailidis on 14/05/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface SYNCoverChooserController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate , NSFetchedResultsControllerDelegate>

@property (nonatomic, readonly) UICollectionView* collectionView;

@property (nonatomic, strong) IBOutlet UIButton *cameraButton;

-(void)updateCoverArt;

@end
