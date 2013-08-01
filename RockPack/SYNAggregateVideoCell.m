//
//  SYNAggregateVideoCell.m
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAggregateVideoCell.h"

@implementation SYNAggregateVideoCell


-(void)awakeFromNib
{
    [super awakeFromNib];
    self.likeLabel.font = [UIFont rockpackFontOfSize:self.likeLabel.font.pointSize];
}


-(void)setCoverImageWithString:(NSString*)imageString
{
    if(!videoImageView) {
        videoImageView = [[UIImageView alloc] initWithFrame:self.imageContainer.frame];
        [self.imageContainer addSubview:videoImageView];
    }
        
    
    [videoImageView setImageWithURL: [NSURL URLWithString: imageString]
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


-(void)setCoverImageWithArray:(NSArray*)imageArray
{
    
    // not relevent yet for this cell (they all have a single image)
    
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

@end
