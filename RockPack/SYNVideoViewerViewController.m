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
#import "LXReorderableCollectionViewFlowLayout.h"
#import "SYNVideoThumbnailSmallCell.h"

@interface SYNVideoViewerViewController () <UIWebViewDelegate>

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
@property (nonatomic, strong) NSMutableArray *videoInstancesArray;
@property (nonatomic, strong) IBOutlet UICollectionView *videoThumbnailCollectionView;


@end

@implementation SYNVideoViewerViewController

#pragma mark - View lifecycle

- (id) initWithVideoInstance: (VideoInstance *) videoInstance
{
	
	if ((self = [super init]))
    {
		self.videoInstance = videoInstance;
//        self.videoInstancesArray = [NSMutableArray arrayWithArray: self.channel.videoInstancesSet.array];

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

    // Setup web player
    self.videoWebView.backgroundColor = [UIColor blackColor];
	self.videoWebView.opaque = NO;
    self.videoWebView.scrollView.scrollEnabled = false;
    self.videoWebView.scrollView.bounces = false;
    self.videoWebView.alpha = 0.0f;
    self.videoWebView.delegate = self;
    
    [self loadWebViewWithJSAPIUsingYouTubeId: self.videoInstance.video.sourceId
                                       width: 740
                                      height: 416];
    
    self.channelCreatorLabel.text = self.videoInstance.channel.channelOwner.name;
    self.channelTitleLabel.text = self.videoInstance.channel.title;
    self.videoTitleLabel.text = self.videoInstance.title;
    self.numberOfRocksLabel.text = self.videoInstance.video.starCount.stringValue;
    
    // Add a custom flow layout to our thumbail collection view (with the right size and spacing)
    LXReorderableCollectionViewFlowLayout *layout = [[LXReorderableCollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(258.0f , 179.0f);
    layout.minimumInteritemSpacing = 0.0f;
    layout.minimumLineSpacing = 0.0f;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.videoThumbnailCollectionView.collectionViewLayout = layout;
    
    // Regster video thumbnail cell
    UINib *videoThumbnailCellNib = [UINib nibWithNibName: @"SYNVideoThumbnailSmallCell"
                                                  bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: videoThumbnailCellNib
                        forCellWithReuseIdentifier: @"SYNVideoThumbnailSmallCell"];
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


#pragma mark - Collection view support

- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    NSLog (@"Number of items %d", self.videoInstancesArray.count);
    return self.videoInstancesArray.count;
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) cv
{
    return 1;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNVideoThumbnailSmallCell *cell = [cv dequeueReusableCellWithReuseIdentifier: @"SYNVideoThumbnailSmallCell"
                                                                       forIndexPath: indexPath];
    
    VideoInstance *videoInstance = self.videoInstancesArray[indexPath.item];
    cell.videoImageViewImage = videoInstance.video.thumbnailURL;
    cell.titleLabel.text = videoInstance.title;
    
    return cell;
}


- (void) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    VideoInstance *videoInstance = self.videoInstancesArray[indexPath.row];
    
//    SYNMyRockpackMovieViewController *movieVC = [[SYNMyRockpackMovieViewController alloc] initWithVideo: videoInstance.video];
//    
//    [self animatedPushViewController: movieVC];
    
}


- (void) collectionView: (UICollectionView *) cv
                 layout: (UICollectionViewLayout *) layout
        itemAtIndexPath: (NSIndexPath *) fromIndexPath
    willMoveToIndexPath: (NSIndexPath *) toIndexPath
{
    // Actually swap the video thumbnails around in the visible list
//    id fromItem = self.videoInstancesArray[fromIndexPath.item];
//    id fromObject = self.channel.videoInstances[fromIndexPath.item];
//    
//    [self.videoInstancesArray removeObjectAtIndex: fromIndexPath.item];
//    [self.channel.videoInstancesSet removeObjectAtIndex: fromIndexPath.item];
//    
//    [self.videoInstancesArray insertObject: fromItem atIndex: toIndexPath.item];
//    [self.channel.videoInstancesSet insertObject: fromObject atIndex: toIndexPath.item];
//    
//    [self saveDB];
}



#pragma mark - Video view

- (IBAction) userTouchedPreviousVideoButton: (id) sender
{
    
}

- (IBAction) userTouchedNextVideoButton: (id) sender
{
    
}


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
//    NSDictionary *parameterDictionary = @{@"api" : @"0",
//    @"player_id" : @"player"};
    
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
    if ([components count] >= 3 && [(NSString *)[components objectAtIndex:0] isEqualToString: @"rockpack"])
    {
        // Look for specific actions
        NSString *parameter2 = (NSString *)[components objectAtIndex: 1];
        if ([parameter2 isEqualToString: @"onStateChange"])
        {
//            [self.videoWebView stringByEvaluatingJavaScriptFromString: @"helloWorld()"];
            
            NSString *parameter3 = (NSString *)[components objectAtIndex: 2];
            
            if ([parameter3 isEqualToString: @"1"])
            {
//                self.videoWebView.alpha = 1.0f;
                
                [UIView animateWithDuration: 0.25f
                                      delay: 0.0f
                                    options: UIViewAnimationOptionCurveEaseInOut
                                 animations: ^
                 {
                     // Contract thumbnail view
                     self.videoWebView.alpha = 1.0f;
                 }
                                 completion: ^(BOOL finished)
                 {
                 }];
            }
        }
        
        // Return 'NO' to prevent navigation
        return NO;
    }
    
    // Return 'YES', navigate to requested URL as normal
    return YES;
}


@end
