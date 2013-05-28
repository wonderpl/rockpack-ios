//
//  SYNSearchRootViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 27/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAbstractViewController.h"
@class SYNSearchBoxViewController;

@interface SYNSearchRootViewController : SYNAbstractViewController {
    @private
    NSString* searchTerm;
    BOOL viewIsOnScreen;
}

-(void)showSearchResultsForTerm:(NSString*)newSearchTerm;

//iPhone specific
@property (nonatomic, weak) SYNSearchBoxViewController* searchBoxViewController;

@end
