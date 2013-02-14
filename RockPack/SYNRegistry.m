//
//  SYNRegistry.m
//  rockpack
//
//  Created by Michael Michailidis on 14/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNRegistry.h"
#import <CoreData/CoreData.h>

#import "SYNAppDelegate.h"
#import "Category.h"

@interface SYNRegistry ()

@property (nonatomic, strong) NSString *localeString;
@property (nonatomic, strong) NSEntityDescription *videoInstanceEntity;
@property (nonatomic, strong) NSEntityDescription *channelEntity;
@property (nonatomic, strong) NSManagedObjectContext *importManagedObjectContext;
@property (nonatomic, strong) SYNAppDelegate *appDelegate;

-(void)saveImportContext;

@end

@implementation SYNRegistry

-(id)initWithManagedObjectContext:(NSManagedObjectContext*)moc
{
    if (self = [super init])
    {
        // This is where the magic occurs
        // Create our own ManagedObjectContext with NSConfinementConcurrencyType as suggested in the WWDC2011 What's new in CoreData video
        self.appDelegate = UIApplication.sharedApplication.delegate;
        self.importManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSConfinementConcurrencyType];
        self.importManagedObjectContext.parentContext = self.appDelegate.mainManagedObjectContext;
        
        // Cache frequently used vars
        self.videoInstanceEntity = [NSEntityDescription entityForName: @"VideoInstance"
                                               inManagedObjectContext: self.importManagedObjectContext];
        
        self.channelEntity = [NSEntityDescription entityForName: @"Channel"
                                         inManagedObjectContext: self.importManagedObjectContext];
        
    }
    
    return self;
}


#pragma mark - Update Data Methods

-(void)registerCategoriesFromDictionary:(NSDictionary*)dictionary
{
    // Get Root Object
    NSDictionary *categoriesDictionary = [dictionary objectForKey: @"categories"];
    
    
    if (categoriesDictionary && [categoriesDictionary isKindOfClass:[NSDictionary class]])
    {
        
        NSArray *itemArray = [categoriesDictionary objectForKey: @"items"];
        
        if ([itemArray isKindOfClass: [NSArray class]])
        {
            
            // === Main Processing === //
            for (NSDictionary *categoryDictionary in itemArray)
            {
                if ([categoryDictionary isKindOfClass: [NSDictionary class]])
                {
                    
                    
                    Category* category = [Category instanceFromDictionary: categoryDictionary usingManagedObjectContext: self.importManagedObjectContext];
                    
                    DebugLog(@"Found Category: %@\n", category);
                }
            }
            
            // [[NSNotificationCenter defaultCenter] postNotificationName: kCategoriesUpdated object: nil];
            
        }
        
        
        [self saveImportContext];
        
        
        
        
    }
    else
    {
        AssertOrLog(@"Not a dictionary");
    }
}


#pragma mark - Context Management

-(void)saveImportContext
{
    NSError* error;
    if (![self.importManagedObjectContext save: &error])
    {
        NSArray* detailedErrors = [[error userInfo] objectForKey: NSDetailedErrorsKey];
        
        if ([detailedErrors count] > 0)
        {
            for(NSError* detailedError in detailedErrors)
            {
                DebugLog(@" DetailedError: %@", [detailedError userInfo]);
            }
        }
    }
}

@end
