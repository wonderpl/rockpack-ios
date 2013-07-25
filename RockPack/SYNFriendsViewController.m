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



//iPhone specific
@property (nonatomic, strong) IBOutlet UIView* searchContainer;
@property (weak, nonatomic) IBOutlet UIImageView *searchFieldBackground;
@property (weak, nonatomic) IBOutlet UIView *searchSlider;

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
    
    self.allFriendsButton.titleLabel.font = [UIFont rockpackFontOfSize: IS_IPAD ? 14.0f : 12.0f];
    self.allFriendsButton.contentEdgeInsets = UIEdgeInsetsMake(IS_IPAD ? 7.0f : 5.0, 0.0f, 0.0f, 0.0f);
    self.onRockpackButton.titleLabel.font = [UIFont rockpackFontOfSize: IS_IPAD ? 14.0f : 12.0f];
    self.onRockpackButton.contentEdgeInsets = UIEdgeInsetsMake(IS_IPAD ? 7.0f : 5.0, 0.0f, 0.0f, 0.0f);
    
    self.searchField.font = [UIFont rockpackFontOfSize: self.searchField.font.pointSize];
    
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
    
    if(IS_IPHONE)
    {
        // iPhone specific setup
        
        //Resizing images
        UIImage* backgroundImageOff = [[UIImage imageNamed:@"SearchTab"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 1.0f, 0.0f, 1.0f)];
        UIImage* backgroundImageOn = [[UIImage imageNamed:@"SearchTabSelected" ]resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 1.0f, 0.0f, 1.0f)];
        UIImage* backgroundImageHighlighted = [[UIImage imageNamed:@"SearchTabHighlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 1.0f, 0.0f, 1.0f)];
        
        [self.onRockpackButton setBackgroundImage:backgroundImageOff forState:UIControlStateNormal];
        [self.onRockpackButton setBackgroundImage:backgroundImageOn forState:UIControlStateSelected];
        [self.onRockpackButton setBackgroundImage:backgroundImageHighlighted forState:UIControlStateHighlighted];
        
        [self.allFriendsButton setBackgroundImage:backgroundImageOff forState:UIControlStateNormal];
        [self.allFriendsButton setBackgroundImage:backgroundImageOn forState:UIControlStateSelected];
        [self.allFriendsButton setBackgroundImage:backgroundImageHighlighted forState:UIControlStateHighlighted];
        
        self.searchFieldBackground.image = [[UIImage imageNamed: @"FieldSearch"]
                                            resizableImageWithCapInsets: UIEdgeInsetsMake(0.0f,20.0f, 0.0f, 20.0f)];
        
        //Push the search slider out to the right.
        CGRect searchSliderFrame = self.searchSlider.frame;
        searchSliderFrame.origin.x = searchSliderFrame.size.width;
        self.searchSlider.frame= searchSliderFrame;
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
    
    [self.friendsCollectionView reloadData];
}


-(void)fetchAndDisplayFriends
{
    
    
    [self.activityIndicator startAnimating];
    
    __weak SYNFriendsViewController* weakSelf = self;
    
    [appDelegate.oAuthNetworkEngine friendsForUser:appDelegate.currentUser completionHandler:^(id dictionary) {
        
        NSDictionary* usersDictionary = dictionary[@"users"];
        if(!usersDictionary)
            return;
        
        NSArray* itemsDictionary = usersDictionary[@"items"];
        if(!itemsDictionary)
            return;
        
        NSInteger friendsCount = itemsDictionary.count;
        
        [weakSelf.allFriendsButton setTitle:[NSString stringWithFormat:@"ALL FRIENDS (%i)", friendsCount] forState:UIControlStateNormal];
        [weakSelf.allFriendsButton setTitle:[NSString stringWithFormat:@"ALL FRIENDS (%i)", friendsCount] forState:UIControlStateHighlighted];
        [weakSelf.allFriendsButton setTitle:[NSString stringWithFormat:@"ALL FRIENDS (%i)", friendsCount] forState:UIControlStateSelected];
        
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
            
            
        }

        [weakSelf.onRockpackButton setTitle:[NSString stringWithFormat:@"ON ROCKPACK (%i)", friendsCount] forState:UIControlStateNormal];
        [weakSelf.onRockpackButton setTitle:[NSString stringWithFormat:@"ON ROCKPACK (%i)", friendsCount] forState:UIControlStateHighlighted];
        [weakSelf.onRockpackButton setTitle:[NSString stringWithFormat:@"ON ROCKPACK (%i)", friendsCount] forState:UIControlStateSelected];
        
        weakSelf.iOSFriends = [NSArray arrayWithArray:iOSFriendsMutableArray];
        weakSelf.displayFriends = weakSelf.iOSFriends;
        
        [weakSelf.activityIndicator stopAnimating];
        
        weakSelf.allFriendsButton.enabled = YES;
        weakSelf.onRockpackButton.enabled = YES;
        
        [weakSelf.allFriendsButton setSelected:YES];
        
        [weakSelf.friendsCollectionView reloadData];
        
    } errorHandler:^(id dictionary) {
        
        [weakSelf.activityIndicator stopAnimating];
    }];
}

-(IBAction)facebookLoginPressed:(id)sender
{
    self.activityIndicator.center = self.facebookLoginButton.center;
    
    [self.activityIndicator startAnimating];
    
    self.facebookLoginButton.hidden = YES;
    
    self.preLoginLabel.text = @"Logging In";
    
    //Weak variables to avoid block retain cycles
    __weak SYNFriendsViewController* weakSelf = self;
    __weak SYNAppDelegate* weakAppDelegate = appDelegate;
    
    SYNFacebookManager* facebookManager = [SYNFacebookManager sharedFBManager];
    
    [facebookManager loginOnSuccess: ^(NSDictionary<FBGraphUser> *dictionary) {
        
        FBAccessTokenData* accessTokenData = [[FBSession activeSession] accessTokenData];
        
        
        [weakAppDelegate.oAuthNetworkEngine connectToFacebookAccoundForUserId:weakAppDelegate.currentUser.uniqueId
                                                                    token:accessTokenData.accessToken
                                                        completionHandler:^(id response) {
                                                            
                                                            
                                                            [weakSelf.activityIndicator stopAnimating];
                                                            
                                                            weakSelf.friendsCollectionView.hidden = NO;
                                                            weakSelf.preLoginLabel.hidden = YES;
                                                            weakSelf.facebookLoginButton.hidden = YES;
                                                            
                                                            weakSelf.onRockpackButton.hidden = NO;
                                                            weakSelf.allFriendsButton.hidden = NO;
                                                            
                                                            [weakSelf fetchAndDisplayFriends];
                                                             
                                                            
                                                        } errorHandler:^(id response) {
                                                            
                                                            [weakSelf.activityIndicator stopAnimating];
                                                            
                                                            weakSelf.facebookLoginButton.hidden = NO;
                                                            
                                                            weakSelf.preLoginLabel.text = @"We could not Log you in becuase this FB account seems to be associated with a different User.";
                                                            
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

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.displayFriends = self.iOSFriends;
    [self.friendsCollectionView reloadData];
    return YES;
}



- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    SYNFriendThumbnailCell* cellClicked = (SYNFriendThumbnailCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    self.currentlySelectedFriend = objc_getAssociatedObject(cellClicked, association_key);
    
    if(!self.currentlySelectedFriend.isOnRockpack) // facebook friend, invite to rockpack
    {
        
        NSString* firstName = [self.currentlySelectedFriend.displayName componentsSeparatedByString:@" "][0];
        
        self.currentInviteFriendView = (SYNInviteFriendView*)[[[NSBundle mainBundle] loadNibNamed:@"SYNInviteFriendView"
                                                                                            owner:self
                                                                                          options:nil] objectAtIndex:0];
        
        self.currentInviteFriendView.profileImageView.image = cellClicked.imageView.image;
        self.currentInviteFriendView.titleLabel.text = [NSString stringWithFormat:@"%@ IS NOT ON ROCKPACK YET", firstName];
        
        [appDelegate.viewStackManager presentPopoverView:self.currentInviteFriendView];
    }
    else // on rockpack, go to profile
    {
        ChannelOwner* friendAsChannelOwner = (ChannelOwner*)self.currentlySelectedFriend;
        
        [appDelegate.viewStackManager viewProfileDetails:friendAsChannelOwner];
        
    }
    
    
    
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
    [self.searchContainer removeFromSuperview];
    // clean associations
    for (UICollectionViewCell* visibleCell in self.friendsCollectionView.visibleCells) {
        objc_removeAssociatedObjects(visibleCell);
    }
}

#pragma mark - iPhone Search bar

-(void)addSearchBarToView:(UIView*)view
{
    CGRect searchContainerFrame = self.searchContainer.frame;
    searchContainerFrame.origin = CGPointMake(46.0f, 0.0f);
    self.searchContainer.frame = searchContainerFrame;
    [view addSubview:self.searchContainer];
}

- (IBAction)closeSearchBox:(id)sender {
    [self.searchField resignFirstResponder];
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationCurveEaseOut animations:^{
        CGRect newFrame = self.searchSlider.frame;
        newFrame.origin.x = newFrame.size.width;
        self.searchSlider.frame = newFrame;
    } completion:nil];
}

- (IBAction)revealSearchBox:(id)sender {
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationCurveEaseIn animations:^{
        CGRect newFrame = self.searchSlider.frame;
        newFrame.origin.x = 0.0f;
        self.searchSlider.frame = newFrame;
    } completion:^(BOOL finished) {
        [self.searchField becomeFirstResponder];
    }];
}

@end
