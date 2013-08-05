//
//  SYNAggregateVideoCell.m
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAggregateVideoCell.h"
#import "ChannelOwner.h"

@implementation SYNAggregateVideoCell


-(void)awakeFromNib
{
    [super awakeFromNib];
    self.likeLabel.font = [UIFont rockpackFontOfSize:self.likeLabel.font.pointSize];
}


-(void)setCoverImagesAndTitlesWithArray:(NSArray*)array
{
    if(!videoImageView) {
        CGRect videoImageFrame = CGRectZero;
        videoImageFrame.size = self.imageContainer.frame.size;
        videoImageView = [[UIImageView alloc] initWithFrame:videoImageFrame];
        [self.imageContainer addSubview:videoImageView];
    }
    
    NSDictionary* coverInfo = (NSDictionary*)array[0];
    
    [videoImageView setImageWithURL: [NSURL URLWithString: coverInfo[@"image"]]
                   placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                            options: SDWebImageRetryFailed];
    
    
}

- (void) setViewControllerDelegate: (UIViewController *) viewControllerDelegate
{
    
    [super setViewControllerDelegate:viewControllerDelegate];
    
    
    [self.addButton addTarget: self.viewControllerDelegate
                       action: @selector(videoAddButtonTapped:)
             forControlEvents: UIControlEventTouchUpInside];
    
    
    
    [self.userThumbnailButton addTarget: self.viewControllerDelegate
                                 action: @selector(profileButtonTapped:)
                       forControlEvents: UIControlEventTouchUpInside];
    
}




-(void)setTitleMessageWithDictionary:(NSDictionary*)messageDictionary
{
    NSString* channelOwnerName = messageDictionary[@"display_name"] ? messageDictionary[@"display_name"] : @"User";
    NSString* added = @"added";
    NSNumber* itemCountNumber = messageDictionary[@"item_count"] ? messageDictionary[@"item_count"] : @1;
    NSString* actionString = [NSString stringWithFormat:@"%i video%@", itemCountNumber.integerValue, itemCountNumber.integerValue > 1 ? @"s" : @""];
    NSString* toString = @"to";
    NSString* channelNameString = messageDictionary[@"channel_name"] ? messageDictionary[@"channel_name"] : @"his channel";
    
    NSString* completeString = [NSString stringWithFormat:@"%@ %@ %@ %@ %@", channelOwnerName, added, actionString, toString, channelNameString];
    
    // craete the attributed string //
    
    NSMutableAttributedString *attributedCompleteString = [[NSMutableAttributedString alloc] initWithString:completeString];
    
    NSRange indexRange = NSMakeRange(0, 0);
    indexRange.length = channelOwnerName.length;
    
    [attributedCompleteString addAttribute:NSFontAttributeName value:[UIFont boldRockpackFontOfSize:12.0] range:indexRange];
    [attributedCompleteString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:indexRange];
    
    indexRange.location += indexRange.length + 1;
    indexRange.length = added.length;
    
    [attributedCompleteString addAttribute:NSFontAttributeName value:[UIFont rockpackFontOfSize:12.0] range:indexRange];
    [attributedCompleteString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:indexRange];
    
    indexRange.location += indexRange.length + 1;
    indexRange.length = actionString.length;
    
    [attributedCompleteString addAttribute:NSFontAttributeName value:[UIFont rockpackFontOfSize:12.0] range:indexRange];
    [attributedCompleteString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:indexRange];
    
    indexRange.location += indexRange.length + 1;
    indexRange.length = toString.length;
    
    [attributedCompleteString addAttribute:NSFontAttributeName value:[UIFont rockpackFontOfSize:12.0] range:indexRange];
    [attributedCompleteString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:indexRange];
    
    indexRange.location += indexRange.length + 1;
    indexRange.length = channelNameString.length;
    
    [attributedCompleteString addAttribute:NSFontAttributeName value:[UIFont boldRockpackFontOfSize:12.0] range:indexRange];
    [attributedCompleteString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:indexRange];
    
    self.messageLabel.attributedText = attributedCompleteString;
}

-(void)setSupplementaryMessageWithDictionary:(NSDictionary*)messageDictionary
{
    
    
    
    
    NSNumber* likesNumber = messageDictionary[@"star_count"] ? messageDictionary[@"star_count"] : @(0);
    NSString* likesString = [NSString stringWithFormat:@"%i likes", likesNumber.integerValue];
    
    if(likesNumber.integerValue == 0)
    {
        self.likeLabel.font = [UIFont boldRockpackFontOfSize:12.0];
        self.likeLabel.textColor = [UIColor blackColor];
        self.likeLabel.text = @"0 likes";
        
        return;
    }
    
    NSString* including = @"including";
    
    NSMutableString* namesString = [[NSMutableString alloc] init];
    NSOrderedSet* users = messageDictionary[@"starrers"] ? messageDictionary[@"starrers"] : [NSOrderedSet orderedSet];
    
    if(users.count > 0)
    {
        if(users.count > 1)
        {
            for (int i = 0; i < users.count - 1; i++)
            {
                
                
                [namesString appendString:((ChannelOwner*)users[0]).displayName];
                [namesString appendString:@", "];
                
            }
            
            [namesString deleteCharactersInRange:NSMakeRange(namesString.length - 2, 2)];
            [namesString appendString:@" & "];
        }
        
        [namesString appendString:((ChannelOwner*)users[(users.count - 1)]).displayName];
    }
    
    
    
    NSString* completeString = [NSString stringWithFormat:@"%@ %@ %@", likesString, including, namesString];
    
    // craete the attributed string //
    
    NSMutableAttributedString *attributedCompleteString = [[NSMutableAttributedString alloc] initWithString:completeString];
    
    NSRange indexRange = NSMakeRange(0, 0);
    indexRange.length = likesString.length;
    
    [attributedCompleteString addAttribute:NSFontAttributeName value:[UIFont boldRockpackFontOfSize:12.0] range:indexRange];
    [attributedCompleteString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:indexRange];
    
    indexRange.location += indexRange.length + 1;
    indexRange.length = including.length;
    
    [attributedCompleteString addAttribute:NSFontAttributeName value:[UIFont rockpackFontOfSize:12.0] range:indexRange];
    [attributedCompleteString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:indexRange];
    
    indexRange.location += indexRange.length + 1;
    indexRange.length = namesString.length;
    
    [attributedCompleteString addAttribute:NSFontAttributeName value:[UIFont boldRockpackFontOfSize:12.0] range:indexRange];
    [attributedCompleteString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:indexRange];
    
    
    self.likeLabel.attributedText = attributedCompleteString;
}

-(void)setCoverTitleWithString:(NSString*)coverTitle
{
    
}


@end
