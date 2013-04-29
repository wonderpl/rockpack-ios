//
//  SYNChannelMidCell.m
//  rockpack
//
//  Created by Michael Michailidis on 17/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNChannelMidCell.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+ImageProcessing.h"

@implementation SYNChannelMidCell

@synthesize specialSelected;

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: self.titleLabel.font.pointSize];
    
    self.specialSelected = NO;
    
    self.deleteButton.hidden = YES;
}

- (void) setChannelImageViewImage: (NSString*) imageURLString
{
    [self.imageView setAsynchronousImageFromURL: [NSURL URLWithString: imageURLString]
                               placeHolderImage: nil];
}

- (void) setChannelTitle: (NSString*) titleString
{
    
    CGRect titleFrame = self.titleLabel.frame;
    
    CGSize expectedSize = [titleString sizeWithFont:self.titleLabel.font
                                  constrainedToSize:CGSizeMake(titleFrame.size.width, 500.0)
                                      lineBreakMode:self.titleLabel.lineBreakMode];
    
    titleFrame.size.height = expectedSize.height;
    titleFrame.origin.y = self.imageView.frame.size.height - titleFrame.size.height - 4.0;
    
    self.titleLabel.frame = titleFrame;
    
    
    self.titleLabel.text = titleString;
    
}

- (void) setViewControllerDelegate: (UIViewController *) viewControllerDelegate
{
    
    [self.deleteButton addTarget: viewControllerDelegate
                          action: @selector(channelDeleteButtonTapped:)
                forControlEvents: UIControlEventTouchUpInside];
}

-(void)setSpecialSelected:(BOOL)value
{
    
    if(value)
    {
        self.panelSelectedImageView.hidden = NO;
    }
    else
    {
        self.panelSelectedImageView.hidden = YES;
    }
}

-(BOOL)specialSelected
{
    return !self.panelSelectedImageView.hidden;
}

@end
