//
//  Channel.h
//  rockpack
//
//  Created by Nick Banks on 27/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Video;

@interface Channel : NSManagedObject

@property (nonatomic, retain) NSString * keyframeURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSNumber * rockedByUser;
@property (nonatomic, retain) NSNumber * packedByUser;
@property (nonatomic, retain) NSNumber * totalRocks;
@property (nonatomic, retain) NSNumber * totalPacks;
@property (nonatomic, retain) NSSet *videos;
@end

@interface Channel (CoreDataGeneratedAccessors)

- (void)addVideosObject:(Video *)value;
- (void)removeVideosObject:(Video *)value;
- (void)addVideos:(NSSet *)values;
- (void)removeVideos:(NSSet *)values;

@end
