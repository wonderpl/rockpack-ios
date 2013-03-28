//
//  SYNSearchRootViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 27/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAbstractTopTabViewController.h"

@interface SYNSearchRootViewController : SYNAbstractTopTabViewController {
    @private
    NSString* searchTerm;
    BOOL viewIsOnScreen;
}

-(void)showSearchResultsForTerm:(NSString*)newSearchTerm;
-(void)clearController;

@end
