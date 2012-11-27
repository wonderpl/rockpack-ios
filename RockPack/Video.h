//
//  Video.h
//  rockpack
//
//  Created by Nick Banks on 27/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Channel;

@interface Video : NSManagedObject

@property (nonatomic, retain) NSString * keyframeURL;
@property (nonatomic, retain) NSNumber * packedByUser;
@property (nonatomic, retain) NSNumber * rockedByUser;
@property (nonatomic, retain) NSNumber * totalRocks;
@property (nonatomic, retain) NSNumber * totalPacks;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * videoURL;
@property (nonatomic, retain) NSSet *channels;
@end

@interface Video (CoreDataGeneratedAccessors)

- (void)addChannelsObject:(Channel *)value;
- (void)removeChannelsObject:(Channel *)value;
- (void)addChannels:(NSSet *)values;
- (void)removeChannels:(NSSet *)values;

@end
