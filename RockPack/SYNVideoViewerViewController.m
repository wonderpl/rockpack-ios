//
//  SYNVideoViewerViewController.m
//  rockpack
//
//  Created by Nick Banks on 23/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNVideoViewerViewController.h"
#import "UIFont+SYNFont.h"
#import "VideoInstance.h"
#import "Video.h"
#import "Channel.h"
#import "ChannelOwner.h"

@interface SYNVideoViewerViewController ()

@property (nonatomic, strong) IBOutlet UIButton *closeButton;
@property (nonatomic, strong) IBOutlet UIButton *nextVideoButton;
@property (nonatomic, strong) IBOutlet UIButton *previousVideoButton;
@property (nonatomic, strong) IBOutlet UILabel *channelCreatorLabel;
@property (nonatomic, strong) IBOutlet UILabel *channelTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *followLabel;
@property (nonatomic, strong) IBOutlet UILabel *numberOfRocksLabel;
@property (nonatomic, strong) IBOutlet UILabel *numberOfSharesLabel;
@property (nonatomic, strong) IBOutlet UILabel *videoTitleLabel;
@property (nonatomic, strong) IBOutlet UIWebView *videoWebView;
@property (nonatomic, strong) VideoInstance *videoInstance;


@end

@implementation SYNVideoViewerViewController

#pragma mark - View lifecycle

- (id) initWithVideoInstance: (VideoInstance *) videoInstance
{
	
	if ((self = [super init]))
    {
		self.videoInstance = videoInstance;
	}
    
	return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.channelTitleLabel.font = [UIFont rockpackFontOfSize: 15.0f];
    self.channelCreatorLabel.font = [UIFont rockpackFontOfSize: 12.0f];
    self.followLabel.font = [UIFont boldRockpackFontOfSize: 14.0f];
    self.videoTitleLabel.font = [UIFont boldRockpackFontOfSize: 25.0f];
    self.numberOfRocksLabel.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.numberOfSharesLabel.font = [UIFont boldRockpackFontOfSize: 20.0f];
    
    [self.videoWebView setBackgroundColor: [UIColor clearColor]];
    [self.videoWebView setBackgroundColor: [UIColor whiteColor]];
	[self.videoWebView setOpaque: NO];
    
    [self loadWebViewWithJSAPIUsingYouTubeId: self.videoInstance.video.sourceId
                                       width: 740
                                      height: 416];
    
    self.channelCreatorLabel.text = self.videoInstance.channel.channelOwner.name;
    self.channelTitleLabel.text = self.videoInstance.channel.title;
    self.videoTitleLabel.text = self.videoInstance.title;
    self.numberOfRocksLabel.text = self.videoInstance.video.starCount.stringValue;
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
}


// Don't call these here as called when going full-screen

- (void) viewWillDisappear: (BOOL) animated
{    
    [super viewWillDisappear: animated];
}


#pragma mark - Video view

- (IBAction) userTouchedPreviousVideoButton: (id) sender
{
    
}

- (IBAction) userTouchedNextVideoButton: (id) sender
{
    
}

//    [self loadWebViewWithIFrameUsingYouTubeId: @"diP-o_JxysA"
//                                        width: 475
//                                       height: 267];

//    [self loadWebViewWithJSAPIUsingYouTubeId: @"diP-o_JxysA"
//                                       width: 475
//                                      height: 267];

//    [self loadWebViewWithIFrameUsingVimeoId: @"55351724"
//                                      width: 475
//                                     height: 267];



- (void) loadWebViewWithIFrameUsingYouTubeId: (NSString *) videoId
                                       width: (int) width
                                      height: (int) height
{
    NSDictionary *parameterDictionary = @{@"autoplay" : @"1",
    @"modestbranding" : @"1",
    @"origin" : @"http://example.com\\",
    @"showinfo" : @"0"};
    
    NSString *parameterString = [self createParamStringFromDictionary: parameterDictionary];
    
    NSError *error = nil;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource: @"YouTubeIFramePlayer"
                                                         ofType: @"html"];
    
    NSString *templateHTMLString = [NSString stringWithContentsOfFile: fullPath
                                                             encoding: NSUTF8StringEncoding
                                                                error: &error];
    
    NSString *iFrameHTML = [NSString stringWithFormat: templateHTMLString, width, height, videoId, parameterString];
    
    [self.videoWebView loadHTMLString: iFrameHTML
                              baseURL: nil];
}

- (void) loadWebViewWithJSAPIUsingYouTubeId: (NSString *) videoId
                                      width: (int) width
                                     height: (int) height
{
    NSError *error = nil;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource: @"YouTubeJSAPIPlayer"
                                                         ofType: @"html"];
    
    NSString *templateHTMLString = [NSString stringWithContentsOfFile: fullPath
                                                             encoding: NSUTF8StringEncoding
                                                                error: &error];
    
    NSString *iFrameHTML = [NSString stringWithFormat: templateHTMLString, width, height, videoId];
    
    [self.videoWebView loadHTMLString: iFrameHTML
                              baseURL: [NSURL URLWithString:@"http://www.youtube.com"]];
    
    self.videoWebView.mediaPlaybackRequiresUserAction = FALSE;
}


- (void) loadWebViewWithIFrameUsingVimeoId: (NSString *) videoId
                                     width: (int) width
                                    height: (int) height
{
    // api=1&player_id=player
    NSDictionary *parameterDictionary = @{@"api" : @"0",
    @"player_id" : @"player"};
    
    //    NSString *parameterString = [self createParamStringFromDictionary: parameterDictionary];
    NSString *parameterString = @"";
    
    NSError *error = nil;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource: @"VimeoIFramePlayer"
                                                         ofType: @"html"];
    
    NSString *templateHTMLString = [NSString stringWithContentsOfFile: fullPath
                                                             encoding: NSUTF8StringEncoding
                                                                error: &error];
    
    NSString *iFrameHTML = [NSString stringWithFormat: templateHTMLString, videoId, parameterString, width, height];
    
    [self.videoWebView loadHTMLString: iFrameHTML
                              baseURL: nil];
}


//- (void) loadVideoViewWithURL: (NSString *) videoURLString
//{
//    NSURL *videoURL = [NSURL URLWithString: videoURLString];
//
//    self.mainVideoPlayerController = [[MPMoviePlayerController alloc] initWithContentURL: videoURL];
//
//    self.mainVideoPlayerController.shouldAutoplay = NO;
//    [self.mainVideoPlayerController prepareToPlay];
//
//    [[self.mainVideoPlayerController view] setFrame: [self.videoPlaceholderView bounds]]; // Frame must match parent view
//
//    [self.videoPlaceholderView addSubview: [self.mainVideoPlayerController view]];
//
//    [self.mainVideoPlayerController pause];
//}



- (NSString *) createParamStringFromDictionary: (NSDictionary *) params
{
    __block NSString *result = @"";
    
    [params enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop)
     {
         result = [result stringByAppendingFormat: @"%@=%@&", key, obj];
     }];
    
    // Chop off last ampersand
    result = [result substringToIndex: [result length] - 2];
    return [result stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
}


- (BOOL) webView: (UIWebView *) webView
shouldStartLoadWithRequest: (NSURLRequest *) request
  navigationType: (UIWebViewNavigationType) navigationType
{
    // Break apart request URL
    NSString *requestString = [[request URL] absoluteString];
    NSArray *components = [requestString componentsSeparatedByString :@":"];
    
    // Check for your protocol
    if ([components count] > 1 && [(NSString *)[components objectAtIndex:0] isEqualToString: @"streamtest"])
    {
        // Look for specific actions
        if ([(NSString *)[components objectAtIndex:1] isEqualToString: @"onReady"])
        {
            // Parameters can be found at [components objectAtIndex:n]
            // where 'n' is the ordinal position of the colon-delimited parameter
            
            [self.videoWebView stringByEvaluatingJavaScriptFromString: @"helloWorld()"];
        }
        
        // Return 'NO' to prevent navigation
        return NO;
    }
    
    // Return 'YES', navigate to requested URL as normal
    return YES;
}


@end
