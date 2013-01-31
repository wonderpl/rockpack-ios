//
//  SYNChannelsDetailViewController.m
//  rockpack
//
//  Created by Nick Banks on 30/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "Channel.h"
#import "SYNAppDelegate.h"
#import "SYNChannelsDetailViewController.h"
#import "SYNNetworkEngine.h"

@interface SYNChannelsDetailViewController ()

@end

@implementation SYNChannelsDetailViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    SYNAppDelegate *appDelegate = UIApplication.sharedApplication.delegate;
    
    [appDelegate.networkEngine updateChannel: self.channel.resourceURL];
}

@end
