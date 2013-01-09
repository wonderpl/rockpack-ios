//
//  AppContants.h
//  RockPack
//
//  Created by Nick Banks on 13/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#ifndef RockPack_AppContants_h
#define RockPack_AppContants_h

// Savecontext

#define kSaveSynchronously TRUE
#define kSaveAsynchronously FALSE

// Settings

#define kDownloadedVideoContentBool @"kDownloadedVideoContentBool"

// Major functionality switches

// Enable user interface sounds
#define SOUND_ENABLED

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
#define kVideoQueueEffectiveHeight 99

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

//
// Tabs
//

// Used to work out what button is pressed on the bottom tab
#define kBottomTabIndexOffset 100

#define kTopTabCount 10

//
// Tracking
//

// TestFlight support
#define  kTestFlightTeamToken @"7476be3185f5971ed3af8d0c6a136c80_MTQyOTYxMjAxMi0xMC0xMyAxMjoyMTozOS41MDgxNDA"

#endif
