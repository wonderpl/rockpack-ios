//
//  AppContants.h
//  RockPack
//
//  Created by Nick Banks on 13/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#ifndef RockPack_AppContants_h
#define RockPack_AppContants_h


//
// API
//

// Host for API


//#define kAPIHostName @"dev.rockpack.com"
#define kAPIHostName @"demo.rockpack.com"

// Returns a list of all the recently added videos associated with a user's subscribed channels (the %@ represents the USERID)
#define kAPIRecentlyAddedVideoInSubscribedChannelsForUser @"ws/%@/subscriptions/recent_videos/"

// Returns a list of the trending videos
#define kAPIPopularVideos @"ws/videos/"

// Search according to term, currently a wrapper around YouTube
#define kAPISearchVideos @"/ws/search/videos/"
#define kAPICompleteVideos @"/ws/complete/videos/"
#define kAPISearchChannels @"/ws/search/channels/"
#define kAPICompleteChannels @"/ws/complete/channels/"

//
#define kAPICategories @"ws/categories/"

// Returns a list of
#define kAPIPopularChannels @"ws/channels/"


// Timeout for API calls

#define kAPIDefaultTimout 30

// API default batch size (we may need different ones for each API at some stage)
#define kDefaultBatchSize 20

// Savecontext

#define kSaveSynchronously TRUE
#define kSaveAsynchronously FALSE


// Notifications

// One the APIs imported some new data - we will need to be more specific at some stage.
#define kDataUpdated @"kDataUpdated"

// One the APIs imported some new data - we will need to be more specific at some stage.
#define kCategoriesUpdated @"kCategoriesUpdated"

// Settings

#define kDownloadedVideoContentBool @"kDownloadedVideoContentBool"

// Major functionality switches


// Enable full screen thumbnail view 
#define FULL_SCREEN_THUMBNAILS__

//
// Colours
//

// Highlighted RockIt number text colour
#define kHighlightedRockItTextColour [UIColor colorWithRed: 0.894f green: 0.945f blue: 0.965f alpha: 1.0f]

// Default
#define kDefaultRockItTextColour

//
// Animations
//

// Switch label
#define kSwitchLabelAnimation 0.25f

// Splash screen
#define kSplashViewDuration 2.0f
#define kSplashAnimationDuration  0.75f

// Tabs
#define kTabAnimationDuration 0.3f

// Rockie-talkie
#define kRockieTalkieAnimationDuration 0.3f

// Image well
#define kVideoQueueAnimationDuration 0.3f
#define kVideoQueueOnScreenDuration 10.0f
//#define kVideoQueueOnScreenDuration 10000.0f

// Large Video panel
#define kLargeVideoPanelAnimationDuration 0.3f

// Camera preview animation
#define kCameraPreviewAnimationDuration 0.3f

// Large Video panel
#define kCreateChannelPanelAnimationDuration 0.3f

//
// Dimensions
//

// Effective height (exlcuding shadow) of the image well
//#define kVideoQueueEffectiveHeight 99

#define kVideoQueueWidth 490
//#define kVideoQueueWidth 475
#define kVideoQueueOffsetX 10

#define kVideoQueueShow @"kVideoQueueShow"
#define kVideoQueueHide @"kVideoQueueHide"
#define kVideoQueueAdd @"kVideoQueueAdd"

typedef enum {
    EntityTypeChannel = 0,
    EntityTypeVideo,
    EntityTypeVideoInstance,
    EntityTypeCategory
    
} EntityType;

// Height of the bottom tab bar in pixels
#define kBottomTabBarHeight 62

// Height of the header bar
#define kHeaderBarHeight 44

// Height of the top tab bar
#define kTopTabBarHeight 45

// Offset from the bottom of the status bar to the bottom of the top tab bar
#define kTabTopContentOffset (kHeaderBarHeight + kTopTabBarHeight)

// Amount of overspill for top tab bar
#define kTopTabOverspill 7

#define kCategorySecondRowHeight 35.0f

//
// Tabs
//

// Used to work out what button is pressed on the bottom tab
#define kBottomTabIndexOffset 100

#define kTopTabCount 10


// Notifications
#define kNoteBackButtonShow @"kNoteBackButtonShow"
#define kNoteBackButtonHide @"kNoteBackButtonHide"
#define kNoteTabPressed @"kNoteTabPressed"
#define kNoteSharePanelRequested @"kNoteSharePanelRequested"

//
// Tracking
//

// TestFlight support
#define  kTestFlightAppToken @"350faab3-e77f-4954-aa44-b85dba25d029"


// Block Definitions
typedef void (^JSONResponseBlock)(id jsonObject);



#endif
