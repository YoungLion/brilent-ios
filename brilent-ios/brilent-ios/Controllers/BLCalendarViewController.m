//
//  BLCalendarViewController.m
//  brilent-ios
//
//  Created by Yong Lin on 8/30/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import "BLCalendarViewController.h"
#import "BLWeekView.h"

@interface BLCalendarViewController ()
@property (weak, nonatomic) IBOutlet BLWeekView *weekView;

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
	// Do any additional setup after loading the view.
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
