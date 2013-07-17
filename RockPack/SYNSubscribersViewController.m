//
//  SYNSubscribersViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 09/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "Channel.h"
#import "SYNSubscribersViewController.h"
#import "UIFont+SYNFont.h"

@interface SYNSubscribersViewController ()

@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UILabel *infoLabel;

@end


@implementation SYNSubscribersViewController


- (id) initWithChannel: (Channel *) channel
{
    if (self = [super initWithViewId: kSubscribersListViewId])
    {
        self.title = NSLocalizedString(@"SUBSCRIBERS", nil);
        self.channel = channel;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame: CGRectMake(-(self.contentSizeForViewInPopover.width * 0.5), -15.0, self.contentSizeForViewInPopover.width, 40.0)];
        titleLabel.backgroundColor = [UIColor clearColor];
        
        titleLabel.textColor = [UIColor colorWithRed: (28.0 / 255.0)
                                               green: (31.0 / 255.0)
                                                blue: (33.0 / 255.0)
                                               alpha: (1.0)];
        
        titleLabel.text = NSLocalizedString(@"SUBSCRIBERS", nil);
        titleLabel.font = [UIFont rockpackFontOfSize: 19.0];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.shadowColor = [UIColor whiteColor];
        titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        
        UIView *labelContentView = [[UIView alloc]init];
        [labelContentView addSubview: titleLabel];
        
        self.navigationItem.titleView = labelContentView;
        
        self.infoLabel = [[UILabel alloc] initWithFrame: CGRectMake(0.0f, 0.0f, self.contentSizeForViewInPopover.width, 0.0f)];
        self.infoLabel.backgroundColor = [UIColor clearColor];
        
        self.infoLabel.textColor = [UIColor colorWithRed: (28.0 / 255.0)
                                                   green: (31.0 / 255.0)
                                                    blue: (33.0 / 255.0)
                                                   alpha: (1.0)];
        
        self.infoLabel.font = [UIFont boldRockpackFontOfSize: 15.0];
        self.infoLabel.textAlignment = NSTextAlignmentCenter;
        self.infoLabel.shadowColor = [UIColor whiteColor];
        self.infoLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        self.infoLabel.numberOfLines = 0;
    }
    
    return self;
}


- (void) setInfoLabelText: (NSString *) text
{
    CGFloat width = self.infoLabel.frame.size.width;
    
    if (!text) // clear
    {
        [self.infoLabel removeFromSuperview];
        return;
    }
    
    self.infoLabel.text = text;
    [self.infoLabel sizeToFit];
    CGRect newFrame = self.infoLabel.frame;
    newFrame.size.width = width;
    self.infoLabel.frame = newFrame;
    CGPoint position = CGPointMake(self.view.center.x, 200.0);
    self.infoLabel.center = position;
    self.infoLabel.frame = CGRectIntegral(self.infoLabel.frame);
    
    [self.view
     addSubview: self.infoLabel];
    
    position.y += 40.0;
    self.activityView.center = position;
}


- (void) viewDidAppear: (BOOL) animated
{
    self.usersThumbnailCollectionView.backgroundColor = [UIColor whiteColor];
    
    
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
    
    self.activityView.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.5);
    
    [self.activityView hidesWhenStopped];
    
    [self.activityView startAnimating];
    
    [self setInfoLabelText: @"LOADING"];
    
    [self.view
     addSubview: self.activityView];
    
    [appDelegate.networkEngine subscribersForUserId: appDelegate.currentUser.uniqueId
                                          channelId: self.channel.uniqueId
                                           forRange: self.dataRequestRange
                                  completionHandler: ^(int count) {
                                      self.dataItemsAvailable = count;
                                      
                                      [self displayUsers];
                                      
                                      [self.activityView stopAnimating];
                                  }
                                       errorHandler: ^{
                                           [self.activityView stopAnimating];
                                       }];
}


- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
    UICollectionReusableView *supplementaryView;
    
    
    if (kind == UICollectionElementKindSectionFooter)
    {
        if (self.users.count == 0 || (self.dataRequestRange.location + self.dataRequestRange.length) >= self.dataItemsAvailable)
        {
            return supplementaryView;
        }
        
        self.footerView = [self.usersThumbnailCollectionView
                           dequeueReusableSupplementaryViewOfKind: kind
                           withReuseIdentifier: @"SYNChannelFooterMoreView"
                           forIndexPath: indexPath];

        //[self loadMoreChannels:self.footerView.loadMoreButton];
        
        supplementaryView = self.footerView;
    }
    
    return supplementaryView;
}


- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (IS_IPHONE)
    {
        [appDelegate.viewStackManager hideModallyController];
    }
    
    [super collectionView: collectionView
           didSelectItemAtIndexPath: indexPath];
}


- (void) displayUsers
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity: [NSEntityDescription entityForName: @"ChannelOwner"
                                    inManagedObjectContext: appDelegate.searchManagedObjectContext]];
    
    
    [request setPredicate: [NSPredicate predicateWithFormat: @"viewId == %@", self.viewId]];
    
    NSArray *sortDescriptorsArray = @[[NSSortDescriptor sortDescriptorWithKey: @"position"
                                                                    ascending: YES]];
    [request setSortDescriptors: sortDescriptorsArray];
    
    request.fetchBatchSize = 20;
    
    NSError *error = nil;
    NSArray *resultsArray = [appDelegate.searchManagedObjectContext
                             executeFetchRequest: request
                             error: &error];
    
    if (!resultsArray)
    {
        return;
    }
    
    self.users = [NSMutableArray arrayWithArray: resultsArray];
    
    if (self.users.count == 0)
    {
        [self setInfoLabelText: @"NO USERS HAVE SUBSCRIBED TO THIS CHANNEL YET"];
    }
    else
    {
        [self setInfoLabelText: nil];
    }
    
    [self.usersThumbnailCollectionView reloadData];
}


- (CGSize) footerSize
{
    return CGSizeMake(100.0, 40.0);
}

@end
