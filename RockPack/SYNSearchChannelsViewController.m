//
//  SYNSearchChannelsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 27/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchChannelsViewController.h"
#import "SYNSearchTabView.h"
#import "SYNSearchRootViewController.h"

@interface SYNSearchChannelsViewController ()


@end



@implementation SYNSearchChannelsViewController

@synthesize itemToUpdate;

#pragma mark - View lifecycle

-(id)initWithViewId:(NSString *)vid
{
    if (self = [super initWithViewId:vid])
    {
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleDataModelChange:)
                                                     name: NSManagedObjectContextObjectsDidChangeNotification
                                                   object: appDelegate.searchManagedObjectContext];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.trackedViewName = @"Search - Channels";
    
    
    
    CGRect collectionFrame = self.channelThumbnailCollectionView.frame;
    collectionFrame.origin.y += 60.0;
    collectionFrame.size.height -= 60.0;
    self.channelThumbnailCollectionView.frame = collectionFrame;
    
    
}

-(void)handleDataModelChange:(NSNotification*)dataNotification
{
    NSArray* updatedObjects = (NSArray*)[[dataNotification userInfo] objectForKey: NSInsertedObjectsKey];
    
    [self reloadCollectionViews];
    
    
}

-(void)reloadCollectionViews
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Channel"
                                   inManagedObjectContext:appDelegate.searchManagedObjectContext]];
    
    
    
    
    NSPredicate* notOwnedByUserPredicate = [NSPredicate predicateWithFormat:@"channelOwner.uniqueId != %@", appDelegate.currentUser.uniqueId];
    
    [request setPredicate:notOwnedByUserPredicate];
    
    NSSortDescriptor *positionDescriptor = [[NSSortDescriptor alloc] initWithKey:@"position"
                                                                       ascending:YES];
    
    [request setSortDescriptors:@[positionDescriptor]];
    
    NSError *error = nil;
    NSArray *resultsArray = [appDelegate.searchManagedObjectContext executeFetchRequest:request
                                                                                  error:&error];
    if (!resultsArray)
        return;
    
    channels = [NSMutableArray arrayWithArray:resultsArray];
    
    [self.channelThumbnailCollectionView reloadData];
    
    if(self.itemToUpdate)
        [self.itemToUpdate setNumberOfItems:resultsArray.count animated:YES];
}

- (void) viewWillAppear: (BOOL) animated
{
    // override the data loading
    
}


-(void)loadChannelsForGenre:(Genre*)genre
{
    // override 
}

- (void) performSearchWithTerm: (NSString*) term
{

    
    if(!appDelegate)
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.networkEngine searchChannelsForTerm:term];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextObjectsDidChangeNotification
                                                  object:appDelegate.searchManagedObjectContext];
    
}


#pragma mark - Override

- (void) handleMainTap: (UITapGestureRecognizer *) recogniser
{
    // override with empty functiokn
}


- (void) handleNewTabSelectionWithId: (NSString *) selectionId
{
    // override with emtpy function
}

- (void) handleNewTabSelectionWithGenre: (Genre*) name
{
    // override with emtpy function
}


#pragma mark - Delegate



@end
