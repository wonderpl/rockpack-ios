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
        
        // load data
        
        [self.activityIndicator startAnimating];
        
        [appDelegate.oAuthNetworkEngine friendsForUser:appDelegate.currentUser completionHandler:^(id dictionary) {
            
            [self.activityIndicator stopAnimating];
            
        } errorHandler:^(id dictionary) {
            
            [self.activityIndicator stopAnimating];
        }];
    }
    else
    {
        self.facebookLoginButton.hidden = NO;
        self.preLoginLabel.hidden = NO;
        self.friendsCollectionView.hidden = YES;
        self.activityIndicator.hidden = YES;
        
        
    }
    
    
    
    
}

-(IBAction)facebookLoginPressed:(id)sender
{
    [appDelegate.oAuthNetworkEngine connectToFacebookAccoundForUserId:appDelegate.currentUser.uniqueId
                                                                token:@""
                                                    completionHandler:^(id response) {
                                                        
                                                    } errorHandler:^(id response) {
                                                        
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
