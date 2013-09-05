//
//  BLCalendarViewController.m
//  brilent-ios
//
//  Created by Yong Lin on 8/30/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import "BLCalendarViewController.h"
#import "BLWeekView.h"
#import "BLDayViewContainer.h"
#import "BLEvent.h"

@interface BLCalendarViewController () <BLDayViewDelegate, BLWeekViewDelegate, BLDayViewContainerDelegate>
@property (weak, nonatomic) IBOutlet BLWeekView *weekView;
@property (weak, nonatomic) IBOutlet BLDayViewContainer *dayViewContainer;

@end

@implementation BLCalendarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[self.dayViewContainer setDate:[NSDate date] animated:NO];
    self.dayViewContainer.delegate = self;
    self.dayViewContainer.currentDayView.blDelegate = self;
    self.weekView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)locateToday:(UIBarButtonItem *)sender {
    [self.weekView locateToday];
}

#pragma mark - BLDayView Delegate

- (void)dayView:(BLDayView *)dayView tappedOnEvent:(BLEvent *)event
{
    BLLog(@"event tapped: %@ %@ ~ %@", event.title, event.start, event.end);
}

#pragma mark - BLDayViewContainer Delegate

- (void)dayViewContainer:(BLDayViewContainer *)dayViewContainer didChangeToDate:(NSDate *)date
{
    [self.weekView locateDay:date];
}

#pragma mark - BLWeekView Delegate

- (void)weekView:(BLWeekView *)weekView didSelectDate:(NSDate *)date
{
    [self.dayViewContainer setDate:date animated:YES];
}


@end
