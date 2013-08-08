//
//  SYNSearchRootViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 27/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNAbstractViewController.h"

@class SYNSearchBoxViewController;

@interface SYNSearchRootViewController : SYNAbstractViewController
{
@private
    NSString *searchTerm;
    BOOL viewIsOnScreen;
}

//iPhone specific
@property (nonatomic, weak) SYNSearchBoxViewController *searchBoxViewController;

- (void) showSearchResultsForTerm: (NSString *) newSearchTerm;

@end
