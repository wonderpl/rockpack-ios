//
//  SYNFriendsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 22/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNFriendsViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNFacebookManager.h"
#import "ChannelOwner.h"
#import "SYNFriendThumbnailCell.h"
#import "UIImageView+WebCache.h"
#import "SYNAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SYNOAuthNetworkEngine.h"

@interface SYNFriendsViewController ()

@property (nonatomic, strong) NSArray* friends;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;

@end

@implementation SYNFriendsViewController

@synthesize appDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    self.friends = [NSArray array];
    
    // Register Cells
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNFriendThumbnailCell"
                                             bundle: nil];
    
    [self.friendsCollectionView registerNib: thumbnailCellNib
                 forCellWithReuseIdentifier: @"SYNFriendThumbnailCell"];
    
    self.preLoginLabel.font = [UIFont rockpackFontOfSize:self.preLoginLabel.font.pointSize];
    
    [self.activityIndicator hidesWhenStopped];
    
    if([[SYNFacebookManager sharedFBManager] hasOpenSession])
    {
        self.facebookLoginButton.hidden = YES;
        self.preLoginLabel.hidden = YES;
        self.friendsCollectionView.hidden = NO;
        self.activityIndicator.hidden = NO;
        
        [self fetchAndDisplayFriends];
    }
    else
    {
        
        self.facebookLoginButton.hidden = NO;
        self.preLoginLabel.hidden = NO;
        self.friendsCollectionView.hidden = YES;
        self.activityIndicator.hidden = YES;
        
    }
    
    
}

-(void)fetchAndDisplayFriends
{
    [self.activityIndicator startAnimating];
    
    [appDelegate.oAuthNetworkEngine friendsForUser:appDelegate.currentUser completionHandler:^(id dictionary) {
        
        NSDictionary* usersDictionary = dictionary[@"users"];
        if(!usersDictionary)
            return;
        
        NSArray* itemsDictionary = usersDictionary[@"items"];
        if(!itemsDictionary)
            return;
        
        NSMutableArray* friendsMutableArray = [NSMutableArray arrayWithCapacity:itemsDictionary.count];
        for (NSDictionary* itemDictionary in itemsDictionary)
        {
            ChannelOwner* channelOwner = [ChannelOwner instanceFromDictionary:itemDictionary
                                                    usingManagedObjectContext:appDelegate.mainManagedObjectContext
                                                          ignoringObjectTypes:kIgnoreChannelObjects];
            
            if(!channelOwner)
                return;
            
            [friendsMutableArray addObject:channelOwner];
            
        }
        
        self.friends = [NSArray arrayWithArray:friendsMutableArray];
        
        [self.activityIndicator stopAnimating];
        
        [self.friendsCollectionView reloadData];
        
    } errorHandler:^(id dictionary) {
        
        [self.activityIndicator stopAnimating];
    }];
}

-(IBAction)facebookLoginPressed:(id)sender
{
    self.activityIndicator.center = self.facebookLoginButton.center;
    
    [self.activityIndicator startAnimating];
    
    self.facebookLoginButton.hidden = YES;
    
    self.preLoginLabel.text = @"Logging In";
    
    SYNFacebookManager* facebookManager = [SYNFacebookManager sharedFBManager];
    
    [facebookManager loginOnSuccess: ^(NSDictionary<FBGraphUser> *dictionary) {
        
        FBAccessTokenData* accessTokenData = [[FBSession activeSession] accessTokenData];
        
        
        [appDelegate.oAuthNetworkEngine connectToFacebookAccoundForUserId:appDelegate.currentUser.uniqueId
                                                                    token:accessTokenData.accessToken
                                                        completionHandler:^(id response) {
                                                            
                                                            [self.activityIndicator stopAnimating];
                                                            
                                                            self.friendsCollectionView.hidden = NO;
                                                            self.preLoginLabel.hidden = YES;
                                                            self.facebookLoginButton.hidden = YES;
                                                            
                                                            [self fetchAndDisplayFriends];
                                                            
                                                        } errorHandler:^(id response) {
                                                            
                                                            [self.activityIndicator stopAnimating];
                                                            
                                                            self.facebookLoginButton.hidden = NO;
                                                            
                                                            self.preLoginLabel.text = @"We could not Log you in becuase this FB account seems to be associated with a different User.";
                                                        }];
        
    } onFailure: ^(NSString* errorString) {
         
     }];
    
}

#pragma mark - UICollectionView Delegate

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    return self.friends.count;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    ChannelOwner *user = self.friends[indexPath.row];
    
    SYNFriendThumbnailCell *userThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNFriendThumbnailCell"
                                                                                        forIndexPath: indexPath];
    
    userThumbnailCell.nameLabel.text = user.displayName;
    
    [userThumbnailCell.imageView setImageWithURL: [NSURL URLWithString: user.thumbnailLargeUrl]
                                placeholderImage: [UIImage imageNamed: @"PlaceholderAvatarChannel"]
                                         options: SDWebImageRetryFailed];
        
    
    [userThumbnailCell setDisplayName: user.displayName];
    
    return userThumbnailCell;
}


- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    
    
    
}

@end
