//
//  CDAViewController.m
//  CoreDataAnalyser
//
//  Created by Mats Trovik on 24/07/2013.
//  Copyright (c) 2013 Rockpack. All rights reserved.
//

#import "CDAViewController.h"
#import <CoreData/CoreData.h>
#import "VideoInstance.h"
#import "CDAAppDelegate.h"
#import "MKNetworkKit.h"
#import "SYNVideoThumbnailWideCell.h"

//#define USE_FETCHED_RESULT_CONTROLLER

@interface CDAViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate>
{
    int refreshCount;
}

@property (nonatomic, strong)NSFetchedResultsController* fetchedResultController;
@property (nonatomic, strong)NSFetchRequest* request;
@property (nonatomic, strong)NSArray* result;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) MKNetworkEngine* engine;
@property (nonatomic, strong) MKNetworkOperation* operation;
@property (nonatomic, strong) UIRefreshControl* refreshControl;
@property (nonatomic, strong) NSDictionary* JSON;

@end

@implementation CDAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.request = [[NSFetchRequest alloc] initWithEntityName:@"VideoInstance"];
    self.request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES]];
    self.request.fetchBatchSize = 25;
    CDAAppDelegate* appDelegate =(CDAAppDelegate*)[[UIApplication sharedApplication] delegate];
#ifdef USE_FETCHED_RESULT_CONTROLLER
    self.fetchedResultController = [[NSFetchedResultsController alloc]initWithFetchRequest:self.request managedObjectContext:appDelegate.mainManagedObjectContext sectionNameKeyPath:nil cacheName:@"DAVE"];
    self.fetchedResultController.delegate = self;
    [self.fetchedResultController performFetch:nil];
#else
    
    self.result = [appDelegate.mainManagedObjectContext executeFetchRequest:self.request error:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveNotification:) name:kMainUpdated object:appDelegate.mainManagedObjectContext];

    
#endif
    UINib* nib = [UINib nibWithNibName:@"SYNVideoThumbnailWideCell" bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"SYNVideoThumbnailWideCell"];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchVideos:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
    
    self.engine = [[MKNetworkEngine alloc] init];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
#ifdef USE_FETCHED_RESULT_CONTROLLER
    return [self.fetchedResultController.sections count];
#else
    return 1;
#endif
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
#ifdef USE_FETCHED_RESULT_CONTROLLER
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
#else
    return [self.result count];
#endif

}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SYNVideoThumbnailWideCell* cell = (SYNVideoThumbnailWideCell*)[self.collectionView dequeueReusableCellWithReuseIdentifier:@"SYNVideoThumbnailWideCell" forIndexPath:indexPath];
#ifdef USE_FETCHED_RESULT_CONTROLLER
    VideoInstance *videoInstance = [self.fetchedResultController objectAtIndexPath:indexPath];
#else
    VideoInstance *videoInstance = [self.result objectAtIndex:indexPath.row];
#endif
    
    cell.videoTitle.text = videoInstance.title;
    return cell;
}

-(void)saveNotification:(NSNotification*)note
{
    refreshCount++;
    if(refreshCount<100)
    {
        [self.collectionView reloadData];
        [self parseVideos];
    }
    else
    {
        NSError* error;
        NSManagedObjectContext* mainContext = [note object];
        self.result = [mainContext executeFetchRequest:self.request error:&error];
        if(!error)
        {
            [self.collectionView reloadData];
            [self.refreshControl endRefreshing];
            refreshCount = 0;
        }
    }
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    refreshCount++;
    if(refreshCount<100)
    {
        [self parseVideos];
    }
    else
    {
        [self.collectionView reloadData];
        [self.refreshControl endRefreshing];
        refreshCount = 0;
    }
}

-(void)parseVideos
{
    NSDictionary *videosDictionary = self.JSON;
    
    CDAAppDelegate* appDelegate =(CDAAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* importManagedObjectContext = appDelegate.importManagedObjectContext;
    
    
    
    [importManagedObjectContext performBlock:^{
        
         NSError *error = nil;
        
//        NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
//        
//        NSEntityDescription* entityDescription = [NSEntityDescription entityForName: @"VideoInstance"
//                                                             inManagedObjectContext: importManagedObjectContext];
//        [fetchRequest setEntity: entityDescription];
//        
//        NSError *error = nil;
//        NSArray *result = [importManagedObjectContext executeFetchRequest: fetchRequest
//                                                                    error: &error];
//        
//        // Bail, if our fetch request failed
//        NSAssert(!error,@"clearImportContextFromEntityName: Fetch request failed");
//        
//        
//        for (id basket in result)
//        {
//            [importManagedObjectContext deleteObject: basket];
//        }
//        
        
        if (!videosDictionary || ![videosDictionary isKindOfClass: [NSDictionary class]])
        {
            
        }
        
        NSArray *itemArray = videosDictionary[@"items"];
        
        if (![itemArray isKindOfClass: [NSArray class]])
        {
            
        }
        
        NSFetchRequest *videoFetchRequest = [[NSFetchRequest alloc] init];
        [videoFetchRequest setEntity: [NSEntityDescription entityForName: @"Video"
                                                  inManagedObjectContext: importManagedObjectContext]];
        
        NSMutableArray *videoIds = [NSMutableArray array];
        
        for (NSDictionary *itemDictionary in itemArray)
        {
            id uniqueId = [itemDictionary[@"video"]
                           objectForKey: @"id"];
            
            if (uniqueId)
            {
                [videoIds addObject: uniqueId];
            }
        }
        
        NSPredicate *videoPredicate = [NSPredicate predicateWithFormat: @"uniqueId IN %@", videoIds];
        
        videoFetchRequest.predicate = videoPredicate;
        
        NSArray *existingVideos = [importManagedObjectContext executeFetchRequest: videoFetchRequest
                                                                            error: nil];
        
        // === Main Processing === //
        
        for (NSDictionary *itemDictionary in itemArray)
        {
            if ([itemDictionary isKindOfClass: [NSDictionary class]])
            {
                NSMutableDictionary *fullItemDictionary = [NSMutableDictionary dictionaryWithDictionary: itemDictionary];
                
                // video instances on search do not have channels attached to them
                VideoInstance *videoInstance = [VideoInstance instanceFromDictionary: fullItemDictionary
                                                           usingManagedObjectContext: importManagedObjectContext
                                                                 ignoringObjectTypes: kIgnoreChannelObjects
                                                                      existingVideos: existingVideos];
                
                videoInstance.viewId = @"CDA";
            }
        }
        
        error = nil;
        [importManagedObjectContext save:&error];
        
        NSAssert1(!error, @"save error import ctx, %@", [error description]);
        
        NSManagedObjectContext* mainContext = importManagedObjectContext.parentContext;
        [mainContext performBlock:^{
            NSError* error = nil;
            [mainContext save:&error];
            
            NSAssert1(!error, @"save error import ctx, %@", [error description]);
            
            NSManagedObjectContext* bgContext = mainContext.parentContext;
            
            [bgContext performBlock:^{
                NSError* error = nil;
                [bgContext save:&error];
                
                NSAssert1(!error, @"save error import ctx, %@", [error description]);
            }];
        }];
        
    }];

}

-(void)fetchVideos:(id)sender
{
    
    NSMutableDictionary *tempParameters = [NSMutableDictionary dictionary];
    
    tempParameters[@"q"] = @"gangnam style";
    tempParameters[@"start"] = @"0";
    tempParameters[@"size"] = @"1000";
    [tempParameters addEntriesFromDictionary: [NSDictionary dictionaryWithObject: @"en-us" forKey:@"locale"]];
    
    self.operation = [[MKNetworkOperation alloc] initWithURLString:@"http://demo.rockpack.com/ws/search/videos/" params:tempParameters httpMethod:@"GET"];
    
    __weak MKNetworkOperation* weakOperation = self.operation;
    __weak CDAViewController* weakSelf = self;
    [weakOperation setCompletionBlock:^{
       if(weakOperation.responseJSON)
       {
           
           NSDictionary* dictionary = weakOperation.responseJSON;
           NSDictionary *videosDictionary = dictionary[@"videos"];
           
           weakSelf.JSON = videosDictionary;
          
           [weakSelf parseVideos];
           
       }
    }];
    
    
    [self.engine enqueueOperation:self.operation];
    
}






@end
