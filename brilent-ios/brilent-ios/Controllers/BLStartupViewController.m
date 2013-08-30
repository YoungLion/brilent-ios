//
//  BLStartupViewController.m
//  brilent-ios
//
//  Created by Yong Lin on 8/27/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import "BLStartupViewController.h"
#import "BLWeekView.h"

@implementation BLStartupViewController

- (void)viewDidLoad
{
    BLWeekView *weekView = [[BLWeekView alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, 100)];
    [self.view addSubview:weekView];
}

@end
