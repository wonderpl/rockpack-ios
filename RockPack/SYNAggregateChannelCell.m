//
//  SYNAggregateChannelCell.m
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAggregateChannelCell.h"

@implementation SYNAggregateChannelCell


-(void)awakeFromNib
{
    [super awakeFromNib];
}

-(void)setCoverImageWithString:(NSString*)imageString
{
    if(!imageString)
        return;
    
    UIImageView* imageView;
    for (imageView in self.imageContainer.subviews)
    {
        [imageView removeFromSuperview];
    }
    
    imageView = [[UIImageView alloc] initWithFrame:self.imageContainer.frame];
    
    [self.imageContainer addSubview:imageView];
    
    [imageView setImageWithURL: [NSURL URLWithString: imageString]
              placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                       options: SDWebImageRetryFailed];
}

-(void)prepareForReuse
{
    if(buttonContainerView)
    {
        [buttonContainerView removeFromSuperview];
        buttonContainerView = nil;
    }
    
}
-(void)setCoverImageWithArray:(NSArray*)imageArray
{
    if(!imageArray)
        return;
    
    for (UIImageView* imageView in self.imageContainer.subviews) // there should only be UIImageView instances
    {
        [imageView removeFromSuperview];
    }
    CGRect containerRect;
    
    NSInteger imagesCount = imageArray.count;
    UIImageView* imageView;
    
    if(imagesCount == 1)
    {
        containerRect = self.imageContainer.frame;
        self.coverButton.hidden = NO;
        
        imageView = [[UIImageView alloc] initWithFrame:containerRect];
        [imageView setImageWithURL: [NSURL URLWithString: ((NSString*)imageArray[0])]
                  placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                           options: SDWebImageRetryFailed];
        
        [self.imageContainer addSubview:imageView];
        
        
        return;
    }
    
    if(imagesCount == 2 || imagesCount == 3)
    {
        
        
        CGRect shrinkingFrame = self.frame;
        shrinkingFrame.size.height = 149.0f;
        
        self.frame = shrinkingFrame;
        
        containerRect = self.imageContainer.frame;
        
        buttonContainerView = [[UIView alloc] initWithFrame:containerRect];
        [self addSubview:buttonContainerView];
        
        containerRect.size.width = containerRect.size.width / 2.0;
        
        self.coverButton.hidden = YES;
        
        UIButton* button;
        for (NSString* imageString in imageArray)
        {
            imageView = [[UIImageView alloc] initWithFrame: containerRect];
            [imageView setImageWithURL: [NSURL URLWithString: imageString]
                      placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                               options: SDWebImageRetryFailed];
            
            [self.imageContainer addSubview:imageView];
            
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor clearColor];
            button.frame = containerRect;
            
            [buttonContainerView addSubview:button];
            
            
            containerRect.origin.x += containerRect.size.width;
            
        }
        
        
        
        return;
    }
    
    if(imagesCount == 4)
    {
        self.coverButton.hidden = YES;
        
        containerRect = self.imageContainer.frame;
        
        buttonContainerView = [[UIView alloc] initWithFrame:containerRect];
        [self addSubview:buttonContainerView];
        
        
        
        containerRect.size.width = containerRect.size.width / 2.0;
        containerRect.size.height = containerRect.size.width / 2.0;
        
        NSInteger idx = 0;
        UIButton* button;
        for (NSString* imageString in imageArray)
        {
            imageView = [[UIImageView alloc] initWithFrame:containerRect];
            [imageView setImageWithURL: [NSURL URLWithString: imageString]
                      placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                               options: SDWebImageRetryFailed];
            
            [self.imageContainer addSubview:imageView];
            
            containerRect.origin.x += containerRect.size.width;
            
            if(++idx == 2)
                containerRect.origin.y += containerRect.size.height;
            
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor clearColor];
            button.frame = containerRect;
            
            [buttonContainerView addSubview:button];
            
            
        }
        
        return;
    }
    
}


- (void) setViewControllerDelegate: (UIViewController *) viewControllerDelegate
{
    
    [super setViewControllerDelegate:viewControllerDelegate];
    
    if(buttonContainerView)
    {
        for (UIButton* button in buttonContainerView.subviews)
        {
            [button addTarget: self.viewControllerDelegate
                       action: @selector(pressedAggregateCellCoverButton:)
             forControlEvents: UIControlEventTouchUpInside];
        }
    }
    
    [self.userThumbnailButton addTarget: self.viewControllerDelegate
                                 action: @selector(profileButtonTapped:)
                       forControlEvents: UIControlEventTouchUpInside];
    
}

-(NSInteger)indexForButtonPressed:(UIButton*)button
{
    if(!buttonContainerView)
        return -1;
    
    return [buttonContainerView.subviews indexOfObject:button];
}

-(void)setTitleMessageWithDictionary:(NSDictionary*)messageDictionary
{
    NSString* channelOwnerName = messageDictionary[@"display_name"] ? messageDictionary[@"display_name"] : @"User";
    NSString* hasCreated = @"has created";
    NSNumber* itemCountNumber = messageDictionary[@"item_count"] ? messageDictionary[@"item_count"] : @1;
    NSString* actionString = [NSString stringWithFormat:@"%i new channel%@", itemCountNumber.integerValue, itemCountNumber.integerValue > 1 ? @"s" : @""];
    
    NSString* completeString = [NSString stringWithFormat:@"%@ %@ %@", channelOwnerName, hasCreated, actionString];
    
    // craete the attributed string //
    
    NSMutableAttributedString *attributedCompleteString = [[NSMutableAttributedString alloc] initWithString:completeString];
    
    NSRange indexRange = NSMakeRange(0, 0);
    indexRange.length = channelOwnerName.length;
    
    [attributedCompleteString addAttribute:NSFontAttributeName value:[UIFont boldRockpackFontOfSize:12.0] range:indexRange];
    [attributedCompleteString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:indexRange];
    
    indexRange.location += indexRange.length + 1;
    indexRange.length = hasCreated.length;
    
    [attributedCompleteString addAttribute:NSFontAttributeName value:[UIFont rockpackFontOfSize:12.0] range:indexRange];
    [attributedCompleteString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:indexRange];
    
    indexRange.location += indexRange.length + 1;
    indexRange.length = actionString.length;
    
    [attributedCompleteString addAttribute:NSFontAttributeName value:[UIFont rockpackFontOfSize:12.0] range:indexRange];
    [attributedCompleteString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:indexRange];
    
    self.messageLabel.attributedText = attributedCompleteString;
}

@end
