//
//  SYNWallpacksDB.m
//  rockpack
//
//  Created by Nick Banks on 12/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNWallpacksDB.h"

@implementation SYNWallpacksDB

// Singleton
+ (id) sharedWallpacksDBManager
{
    static dispatch_once_t onceQueue;
    static SYNWallpacksDB *wallpacksDBManager = nil;
    
    dispatch_once(&onceQueue, ^
                  {
                      wallpacksDBManager = [[self alloc] init];
                  });
    
    return wallpacksDBManager;
}

- (id) init
{
    if ((self = [super init]))
    {
        // Nasty, but only for demo
        NSMutableDictionary *d1 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"",
                                   @"thumbnail" : @"WallpackCover1",
                                   @"title" : @"MANCHESTER UNITED WALLPACK",
                                   @"biog" : @"Glory, glory Man Utd! Thanks to players like Bobby Charlton, George Best, Eric Cantona, Cristiano Ronaldo and Wayne Rooney, the Red Devils are the biggest football club in the world. Show your dedication by nabbing a Man Utd Wallpack, which contains six trading cards, a trend avatar, channel wallpaper and a video message from Sir Alex!",
                                   @"price" : @"200"}];
        
        NSMutableDictionary *d2 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"",
                                   @"thumbnail" : @"WallpackCover2",
                                   @"title" : @"JUSTIN BIEBER WALLPACK",
                                   @"biog" : @"Did someone mention popularity? Ok, 30 million Justin Bieber fans can’t be wrong. Everything the Canadian megastar touches turns to gold. Much like his Rockpack Wallpack. Bieberettes, get your hands on six trading cards, a trend avatar, channel wallpaper and a special message from the man himself. It’s not our world; it’s Justin’s.",
                                   @"price" : @"100"}];
        
        NSMutableDictionary *d3 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"",
                                   @"thumbnail" : @"WallpackCover3",
                                   @"title" : @"MONSTERS UNIVERSITY WALLPACK",
                                   @"biog" : @"The companion piece to Pixar’s smash hit Monsters, Inc. is here! Monsters University is set 10 years before the events of Monsters, Inc. and explains how Sulley and Mike become best buddies while at college. The official Monsters University Wallpack features six trading cards, a trend avatar, channel wallpaper and a special video message.",
                                   @"price" : @"200"}];
        
        NSMutableDictionary *d4 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"",
                                   @"thumbnail" : @"WallpackCover4",
                                   @"title" : @"RIHANNA WALLPACK",
                                   @"biog" : @"The best pop stars only need one name and Barbadian glamour gal Rihanna certainly is the best. She’s a Good Girl Gone Bad and we love her. Be Unapologetic in your love and nab her Rockpack Wallpack. Contains six trading cards, a trend avatar, channel wallpaper and an exclusive voice message from the lady herself.",
                                   @"price" : @"117"}];
        
        NSMutableDictionary *d5 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"",
                                   @"thumbnail" : @"WallpackCover5",
                                   @"title" : @"MINECRAFT WALLPACK",
                                   @"biog" : @"Gaming sensations don’t come much bigger, or better, than Minecraft. There are no limits to what you can achieve in Minecraft. Demonstrate your devotion by unlocking the potential of the Minecraft Wallpack. Six trading cards, a trend avatar, channel wallpaper and a special audio message from the game’s makers.",
                                   @"price" : @"FREE"}];
        
        NSMutableDictionary *d6 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"",
                                   @"thumbnail" : @"WallpackCover6",
                                   @"title" : @"TES WALLPACK",
                                   @"biog" : @"Burn the Bunsens and ditch the white coats. Bring science alive with our exclusive Rockpack Wallpack. Featuring six trading cards, a trend avatar, channel wallpaper and a special greeting from ace scientist, Professor Brian Cox. Who knows, maybe you could be the next Albert Einstein?",
                                   @"price" : @"200"}];
        
        NSMutableDictionary *d7 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"",
                                   @"thumbnail" : @"WallpackCover7",
                                   @"title" : @"DISNEY CHANNEL WALLPACK",
                                   @"biog" : @"Mickey Mouse, Donald Duck, Snow White, Buzz Lightyear… everybody loves Disney! Celebrate the timeless appeal of the good ship Disney with an official Disney Rockpack Wallpack. Contained in the pack are six trading cards, a trend avatar, channel wallpaper and a voice message from your favourite Disney character.",
                                   @"price" : @"460"}];
        
        NSMutableDictionary *d8 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"",
                                   @"thumbnail" : @"WallpackCover8",
                                   @"title" : @"HARRY POTTER WALLPACK",
                                   @"biog" : @"Harry Potter is the ultimate 21st Century hero: a schoolboy fantasy wizard fighting evil in the shape of Lord Voldemort. After conquering the books and the films, keep Harry’s cause alive with the Harry Potter Rockpack Wallpack. It contains six trading cards, a trend avatar, channel wallpaper and an audio greeting from Harry.",
                                   @"price" : @"650"}];
        
        self.thumbnailDetailsArray = @[d1, d2, d3, d4, d5, d6, d7, d8];
    }
    
    return self;
}

- (NSString *) priceForIndex: (int) index
                  withOffset: (int) offset
{
    NSDictionary *videoDetails = [self.thumbnailDetailsArray objectAtIndex: [self adjustedIndexForIndex: index withOffset: offset]];
    NSString *videoTitle = [videoDetails objectForKey: @"price"];
    
    return videoTitle;
}

@end
