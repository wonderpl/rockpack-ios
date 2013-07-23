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
#import "Friend.h"
#import "SYNInviteFriendView.h"
#import "SYNFacebookManager.h"
#import <objc/runtime.h>

static char* association_key = "SYNFriendThumbnailCell to Friend";

@interface SYNFriendsViewController ()

@property (nonatomic, strong) NSArray* iOSFriends;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;
@property (nonatomic) BOOL onRockpackFilterOn;
@property (nonatomic, strong) NSArray* displayFriends;
@property (nonatomic, strong) SYNInviteFriendView* currentInviteFriendView;
@property (nonatomic, weak) Friend* currentlySelectedFriend;

@end

@implementation SYNFriendsViewController

@synthesize appDelegate;
@synthesize onRockpackFilterOn;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    onRockpackFilterOn = NO;
    
    [self.searchField setAutocorrectionType:UITextAutocorrectionTypeNo];
    
    self.iOSFriends = [NSArray array];
    
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
        
        self.onRockpackButton.hidden = NO;
        self.allFriendsButton.hidden = NO;
        
        [self fetchAndDisplayFriends];
    }
    else
    {
        
        self.onRockpackButton.hidden = YES;
        self.allFriendsButton.hidden = YES;
        self.facebookLoginButton.hidden = NO;
        self.preLoginLabel.hidden = NO;
        self.friendsCollectionView.hidden = YES;
        self.activityIndicator.hidden = YES;
        
    }
    
    
}

-(IBAction)switchClicked:(id)sender
{
    if( ((UIButton*)sender).selected ) // do not re-select
        return;
    
    if(sender == self.onRockpackButton)
    {
        NSPredicate* searchPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            
            return ((Friend*)evaluatedObject).isOnRockpack; // resourceURL != nil; (derived property)
        }];
        
        self.displayFriends = [self.iOSFriends filteredArrayUsingPredicate:searchPredicate];
        
        [self.allFriendsButton setSelected:NO];
        
    }
    else if (sender == self.allFriendsButton)
    {
        self.displayFriends = self.iOSFriends;
        [self.onRockpackButton setSelected:NO];
    }
    
    [((UIButton*)sender) setSelected:YES];
    
    
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
        
        NSInteger friendsCount = itemsDictionary.count;
        
        [self.allFriendsButton setTitle:[NSString stringWithFormat:@"ALL FRIENDS (%i)", friendsCount] forState:UIControlStateNormal];
        [self.allFriendsButton setTitle:[NSString stringWithFormat:@"ALL FRIENDS (%i)", friendsCount] forState:UIControlStateHighlighted];
        [self.allFriendsButton setTitle:[NSString stringWithFormat:@"ALL FRIENDS (%i)", friendsCount] forState:UIControlStateSelected];
        
        NSMutableArray* iOSFriendsMutableArray = [NSMutableArray arrayWithCapacity:friendsCount];
        
        for (NSDictionary* itemDictionary in itemsDictionary)
        {
            Friend* friend = [Friend instanceFromDictionary:itemDictionary
                                  usingManagedObjectContext:appDelegate.searchManagedObjectContext];
            
            if(!friend || !friend.hasIOSDevice) // filter for users with iOS devices only
                return;
            
            [iOSFriendsMutableArray addObject:friend];
            
            if(!friend.isOnRockpack)
                friendsCount--;
            
            NSLog(@"%@", friend);
            
        }
        
        [self.onRockpackButton setTitle:[NSString stringWithFormat:@"ON ROCKPACK (%i)", friendsCount] forState:UIControlStateNormal];
        [self.onRockpackButton setTitle:[NSString stringWithFormat:@"ON ROCKPACK (%i)", friendsCount] forState:UIControlStateHighlighted];
        [self.onRockpackButton setTitle:[NSString stringWithFormat:@"ON ROCKPACK (%i)", friendsCount] forState:UIControlStateSelected];
        
        self.iOSFriends = [NSArray arrayWithArray:iOSFriendsMutableArray];
        self.displayFriends = self.iOSFriends;
        
        [self.activityIndicator stopAnimating];
        
        self.allFriendsButton.enabled = YES;
        self.onRockpackButton.enabled = YES;
        
        [self.allFriendsButton setSelected:YES];
        
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
                                                            
                                                            self.onRockpackButton.hidden = NO;
                                                            self.allFriendsButton.hidden = NO;
                                                            
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
    return self.displayFriends.count;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    Friend *friend = self.displayFriends[indexPath.row];
    
    SYNFriendThumbnailCell *userThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNFriendThumbnailCell"
                                                                                        forIndexPath: indexPath];
    
    userThumbnailCell.nameLabel.text = friend.displayName;
    
    userThumbnailCell.plusSignView.hidden = friend.isOnRockpack; // if he is on rockpack dont display
    
    [userThumbnailCell.imageView setImageWithURL: [NSURL URLWithString: friend.thumbnailLargeUrl]
                                placeholderImage: [UIImage imageNamed: @"PlaceholderAvatarChannel"]
                                         options: SDWebImageRetryFailed];
    
    [userThumbnailCell setDisplayName: friend.displayName];
    
    
    
    objc_setAssociatedObject(userThumbnailCell, association_key, friend, OBJC_ASSOCIATION_ASSIGN);
    
    return userThumbnailCell;
}

#pragma mark - UITextViewDelegate

- (BOOL) textField: (UITextField *) textField shouldChangeCharactersInRange: (NSRange) range replacementString: (NSString *) newCharacter
{
    NSUInteger oldLength = textField.text.length;
    NSUInteger newCharacterLength = newCharacter.length;
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = (oldLength + newCharacterLength) - rangeLength;
    
    
    NSMutableString* searchTerm = [NSMutableString stringWithString:[self.searchField.text uppercaseString]];
    if(oldLength < newLength)
        [searchTerm appendString:[newCharacter uppercaseString]];
    else
        [searchTerm deleteCharactersInRange:NSMakeRange(searchTerm.length - 1, 1)];
    
    if([searchTerm isEqualToString:@""])
    {
        self.displayFriends = self.iOSFriends;
    }
    else
    {
        
        NSPredicate* searchPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            
            NSString* nameToCompare = [((Friend*)evaluatedObject).displayName uppercaseString];
            
            BOOL result = [nameToCompare hasPrefix:searchTerm];
            
            
            return result;
        }];
        
        self.displayFriends = [self.iOSFriends filteredArrayUsingPredicate:searchPredicate];
    }
    
    
    [self.friendsCollectionView reloadData];
    
    return YES;
}

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    
    return YES;
}

- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    SYNFriendThumbnailCell* cellClicked = (SYNFriendThumbnailCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    self.currentlySelectedFriend = objc_getAssociatedObject(cellClicked, association_key);
    
    if(self.currentlySelectedFriend.isOnRockpack)
        return;
    
    // create view
    NSString* firstName = [self.currentlySelectedFriend.displayName componentsSeparatedByString:@" "][0];
    
    self.currentInviteFriendView = (SYNInviteFriendView*)[[[NSBundle mainBundle] loadNibNamed:@"SYNInviteFriendView"
                                                                                        owner:self
                                                                                      options:nil] objectAtIndex:0];
    
    self.currentInviteFriendView.profileImageView.image = cellClicked.imageView.image;
    self.currentInviteFriendView.titleLabel.text = [NSString stringWithFormat:@"%@ IS NOT ON ROCKPACK YET", firstName];
    
    [appDelegate.viewStackManager presentPopoverView:self.currentInviteFriendView];
    
}

-(IBAction)inviteButtonPressed:(id)sender
{
    [[SYNFacebookManager sharedFBManager] sendAppRequestToFriend:self.currentlySelectedFriend
                                                       onSuccess:^{
                                                           
                                                           [appDelegate.viewStackManager removePopoverView];
        
                                                       } onFailure:^(NSError *error) {
                                                           
                                                           [appDelegate.viewStackManager removePopoverView];
        
                                                       }];
    
}

-(void)dealloc
{
    // clean associations
    for (UICollectionViewCell* visibleCell in self.friendsCollectionView.visibleCells) {
        objc_removeAssociatedObjects(visibleCell);
    }
}

@end
