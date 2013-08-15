//
//  SYNAggregateChannelCell.m
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAggregateChannelCell.h"

@implementation SYNAggregateChannelCell

@synthesize boldTextAttributes;
@synthesize lightTextAttributes;



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
    if(labelsContainerView)
    {
        [labelsContainerView removeFromSuperview];
        labelsContainerView = nil;
    }
    self.coverButton.hidden = NO;
    self.mainTitleLabel.hidden = NO;
    
}


-(void)setCoverImagesAndTitlesWithArray:(NSArray*)array
{
    if(!array)
        return;
    
    for (UIImageView* imageView in self.imageContainer.subviews) // there should only be UIImageView instances
    {
        [imageView removeFromSuperview];
    }
    CGRect containerRect = CGRectZero;
    
    NSInteger count = array.count;
    UIImageView* imageView;
    
    UIButton* button;
    UILabel* label;
    NSString* channelTitle;
    CGSize expectedLabelSize;
    
    if(count == 1)
    {
        containerRect.size = self.imageContainer.frame.size;
        
        
        self.coverButton.hidden = NO;
        self.mainTitleLabel.hidden = NO;
        
        imageView = [[UIImageView alloc] initWithFrame:containerRect];
        [imageView setImageWithURL: [NSURL URLWithString: ((NSString*)array[0][@"image"])]
                  placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                           options: SDWebImageRetryFailed];
        
        
        [self.imageContainer addSubview:imageView];
        
        
        self.mainTitleLabel.text = (NSString*)array[0][@"title"];
        
        
        return;
    }
    
    if(count == 2 || count == 3)
    {
        
        CGRect shrinkingSelfFrame = self.frame;
        shrinkingSelfFrame.size.height = 149.0f;
        
        self.frame = shrinkingSelfFrame;
        
        CGRect smallerCellFrame = self.imageContainer.frame; // the 2 - 3 options have a smaller total frame
        smallerCellFrame.size.height = 149.0f;
        self.imageContainer.frame = smallerCellFrame;
        
        containerRect.size = self.imageContainer.frame.size;
        
        buttonContainerView = [[UIView alloc] initWithFrame:containerRect];
        [self insertSubview:buttonContainerView belowSubview:self.coverButton];
        
        labelsContainerView = [[UIView alloc] initWithFrame:containerRect];
        labelsContainerView.userInteractionEnabled = NO;
        labelsContainerView.backgroundColor = [UIColor clearColor];
        [self insertSubview:labelsContainerView aboveSubview:buttonContainerView];
        
        containerRect.size.width = containerRect.size.width / 2.0;
        
        self.coverButton.hidden = YES;
        self.mainTitleLabel.hidden = YES;
        for (int i = 0; i < 2; i++)
        {
            NSDictionary* coverInfo = (NSDictionary*)array[i];
            imageView = [[UIImageView alloc] initWithFrame: containerRect];
            if(coverInfo[@"image"])
            {
                [imageView setImageWithURL: [NSURL URLWithString: coverInfo[@"image"]]
                          placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                                   options: SDWebImageRetryFailed];
            }
            else
            {
                imageView.image = [UIImage imageNamed: @"PlaceholderChannelSmall.png"];
            }
            
            
            [self.imageContainer addSubview:imageView];
            
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor clearColor];
            button.frame = containerRect;
            [button setImage:[UIImage imageNamed:@"channelFeedCoverFourth"] forState:UIControlStateNormal];
            
            [buttonContainerView addSubview:button];
            
            label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont boldRockpackFontOfSize:14.0f];
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.textColor = [UIColor whiteColor];
            channelTitle = coverInfo[@"title"];
            expectedLabelSize = [channelTitle sizeWithFont: label.font
                                         constrainedToSize: CGSizeMake(containerRect.size.width, 500.0)
                                             lineBreakMode: label.lineBreakMode];
            
            
            
            label.frame = CGRectMake(containerRect.origin.x + 6.0, (containerRect.origin.y + containerRect.size.height) - (expectedLabelSize.height), expectedLabelSize.width, expectedLabelSize.height);
            label.text = channelTitle;
            
            [labelsContainerView addSubview:label];
            
            containerRect.origin.x += containerRect.size.width;
            
        }
        
        return;
    }
    
    if(count == 4)
    {
        self.coverButton.hidden = YES;
        self.mainTitleLabel.hidden = YES;
        
        containerRect.size = self.imageContainer.frame.size;
        
        buttonContainerView = [[UIView alloc] initWithFrame:containerRect];
        [self insertSubview:buttonContainerView belowSubview:self.coverButton];
        
        labelsContainerView = [[UIView alloc] initWithFrame:containerRect];
        labelsContainerView.userInteractionEnabled = NO;
        labelsContainerView.backgroundColor = [UIColor clearColor];
        [self insertSubview:labelsContainerView aboveSubview:buttonContainerView];
        
        
        containerRect.size.width = containerRect.size.width / 2.0;
        containerRect.size.height = containerRect.size.height / 2.0;
        
        NSInteger idx = 0;
        
        for (NSDictionary* coverInfo in array)
        {
            imageView = [[UIImageView alloc] initWithFrame:containerRect];
            if(coverInfo[@"image"])
            {
                [imageView setImageWithURL: [NSURL URLWithString: coverInfo[@"image"]]
                          placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                                   options: SDWebImageRetryFailed];
            }
            else
            {
                imageView.image = [UIImage imageNamed: @"PlaceholderChannelSmall.png"];
            }
            
            
            [self.imageContainer addSubview:imageView];
            
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor clearColor];
            button.frame = containerRect;
            [button setImage:[UIImage imageNamed:@"channelFeedCoverFourth"] forState:UIControlStateNormal];
            
            [buttonContainerView addSubview:button];
            
            
            label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont boldRockpackFontOfSize:14.0f];
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.textColor = [UIColor whiteColor];
            channelTitle = coverInfo[@"title"];
            expectedLabelSize = [channelTitle sizeWithFont: label.font
                                           constrainedToSize: CGSizeMake(containerRect.size.width, 500.0)
                                               lineBreakMode: label.lineBreakMode];
            
            
            
            label.frame = CGRectMake(containerRect.origin.x + 6.0, (containerRect.origin.y + containerRect.size.height) - (expectedLabelSize.height), expectedLabelSize.width, expectedLabelSize.height);
            label.text = channelTitle;
            
            [labelsContainerView addSubview:label];
            // set rect
            
            containerRect.origin.x += containerRect.size.width;
            
            if(++idx == 2) {
                containerRect.origin.x = 0.0f;
                containerRect.origin.y += containerRect.size.height;
            }
            
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

    NSNumber* itemCountNumber = messageDictionary[@"item_count"] ? messageDictionary[@"item_count"] : @1;
    NSString* actionString = [NSString stringWithFormat:@"%i pack%@", itemCountNumber.integerValue, itemCountNumber.integerValue > 1 ? @"s" : @""];
    
    
    // craete the attributed string //
    
    NSMutableAttributedString *attributedCompleteString = [[NSMutableAttributedString alloc] init];
    
    [attributedCompleteString appendAttributedString:[[NSAttributedString alloc] initWithString:channelOwnerName
                                                                                     attributes:boldTextAttributes]];
    
    
    [attributedCompleteString appendAttributedString:[[NSAttributedString alloc] initWithString:@" created "
                                                                                     attributes:lightTextAttributes]];
    
    [attributedCompleteString appendAttributedString:[[NSAttributedString alloc] initWithString:actionString
                                                                                     attributes:lightTextAttributes]];
    
    
    
    
    
    
    self.messageLabel.attributedText = attributedCompleteString;
}


@end
