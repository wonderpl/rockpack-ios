//
//  SYNMyRockPackViewController.m
//  RockPack
//
//  Created by Nick Banks on 13/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "Channel.h"
#import "SYNMyRockPackDetailViewController.h"
#import "SYNMyRockpackCell.h"
#import "UIFont+SYNFont.h"
#import "Video.h"
#import "SYNMyRockpackMovieViewController.h"

@interface SYNMyRockpackDetailViewController ()

@property (nonatomic, strong) Channel *channel;
@property (nonatomic, strong) IBOutlet UICollectionView *thumbnailView;
@property (nonatomic, strong) IBOutlet UIImageView *wallpackImage;
@property (nonatomic, strong) IBOutlet UILabel *biogBody;
@property (nonatomic, strong) IBOutlet UILabel *biogTitle;
@property (nonatomic, strong) IBOutlet UILabel *wallpackTitle;
@property (nonatomic, strong) NSArray *videos;

@end

@implementation SYNMyRockpackDetailViewController

- (id) initWithChannel: (Channel *) channel
{
	
	if ((self = [super init]))
    {
		self.channel = channel;
        self.videos = self.channel.videos.array;
	}
    
	return self;
}


- (void) viewDidLoad
{
    [super viewDidLoad];

    
    self.wallpackTitle.font = [UIFont boldRockpackFontOfSize: 28.0f];
    self.biogTitle.font = [UIFont boldRockpackFontOfSize: 24.0f];
    self.biogBody.font = [UIFont rockpackFontOfSize: 17.0f];
    
    // Init collection view
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNMyRockpackCell"
                                             bundle: nil];
    
    [self.thumbnailView registerNib: thumbnailCellNib
         forCellWithReuseIdentifier: @"MyRockpackCell"];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];

    self.wallpackTitle.text = self.channel.title;
    self.wallpackImage.image = self.channel.wallpaperImage;
    self.biogTitle.text = self.channel.biogTitle;
    self.biogBody.text = [NSString stringWithFormat: @"%@\n\n\n", self.channel.biog];
    
    [self.thumbnailView reloadData];
}


#pragma mark - Collection view support

- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    return self.videos.count;
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) cv
{
    return 1;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNMyRockpackCell *cell = [cv dequeueReusableCellWithReuseIdentifier: @"MyRockpackCell"
                                                            forIndexPath: indexPath];
    
    Video *video = [self.videos objectAtIndex: indexPath.row];
    cell.imageView.image = video.keyframeImage;
    
    return cell;
}


- (void) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    Video *video = [self.videos objectAtIndex: indexPath.row];
    
    SYNMyRockpackMovieViewController *movieVC = [[SYNMyRockpackMovieViewController alloc] initWithVideo: video];
    
    [self animatedPushViewController: movieVC];

}



- (IBAction) popCurrentView: (id) sender
{
    //	[self.navigationController popViewControllerAnimated: YES];
    
    UIViewController *parentVC = self.navigationController.viewControllers[0];
    parentVC.view.alpha = 0.0f;
    
    [self.navigationController popViewControllerAnimated: NO];
    
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         // Contract thumbnail view
         self.view.alpha = 0.0f;
         parentVC.view.alpha = 1.0f;
         
     }
                     completion: ^(BOOL finished)
     {
     }];
}

@end
