//
//  BLCalendarViewController.m
//  brilent-ios
//
//  Created by Yong Lin on 8/30/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import "BLCalendarViewController.h"
#import "BLWeekView.h"
#import "BLDayView.h"
#import "BLEvent.h"

@interface BLCalendarViewController ()
@property (weak, nonatomic) IBOutlet BLWeekView *weekView;
@property (weak, nonatomic) IBOutlet BLDayView *dayView;

@end

@implementation BLCalendarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    BLEvent *e1 = [BLEvent new];
    e1.start = [NSDate dateWithTimeIntervalSinceNow:-40*60];
    e1.end = [NSDate dateWithTimeIntervalSinceNow:60*60];
    e1.title = @"Event 1";
    e1.type = @"a";
    
    BLEvent *e2 = [BLEvent new];
    e2.start = [NSDate dateWithTimeIntervalSinceNow:-60*60];
    e2.end = [NSDate dateWithTimeIntervalSinceNow:0];
    e2.title = @"Event 2";
    e2.type = @"c";
    
    BLEvent *e3 = [BLEvent new];
    e3.start = [NSDate dateWithTimeIntervalSinceNow:-60*60];
    e3.end = [NSDate dateWithTimeIntervalSinceNow:-41*60];
    e3.title = @"Event 3";
    e3.type = @"r";
    
	self.dayView.events = [NSMutableArray arrayWithArray:@[e1, e2, e3]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)locateToday:(UIBarButtonItem *)sender {
    [self.weekView locateToday];
}

@end
