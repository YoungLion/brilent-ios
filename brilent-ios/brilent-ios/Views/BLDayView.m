//
//  BLDayView.m
//  brilent-ios
//
//  Created by Yong Lin on 9/3/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import "BLDayView.h"
#import "BLEvent.h"
#import "BLEventLabel.h"

#define kTopMargin              5
#define kBottomMargin           20
#define kHourlySpacing          50
#define kHourLabelRightEdgeX    50
#define kHourFont               [UIFont fontWithName:@"HelveticaNeue" size:12]
#define kMarginX                10
#define kDayTableWidth          (self.bounds.size.width - kHourLabelRightEdgeX - kMarginX)
#define kDayTableHeight         (kHourlySpacing * 24)
@interface BLDayView()
{
    NSMutableArray *_eventLabels;
}

@end

@implementation BLDayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        _eventLabels = [NSMutableArray new];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
    _eventLabels = [NSMutableArray new];
}

- (void)setup
{
    self.contentSize = CGSizeMake(self.frame.size.width, kHourlySpacing * 24);
    self.contentInset = UIEdgeInsetsMake(kTopMargin, 0, kBottomMargin, 0);
    self.directionalLockEnabled = YES;
    self.alwaysBounceHorizontal = NO;
    for (int i = 0; i <= 24; i++) {
        UILabel *label = [UILabel new];
        label.text = [self textForHour:i];
        label.font = kHourFont;
        [label sizeToFit];
        CGRect rect = label.frame;
        rect.origin = CGPointMake(kHourLabelRightEdgeX - rect.size.width, kHourlySpacing*i - rect.size.height/2);
        label.frame = rect;
        [self addSubview:label];
        
        UIView *hourMark = [[UIView alloc] initWithFrame:CGRectMake(kHourLabelRightEdgeX + kMarginX, kHourlySpacing*i, kDayTableWidth, 1)];
        hourMark.backgroundColor = [UIColor lightlightGrayColor];
        [self addSubview:hourMark];
    }
}

- (NSString *)textForHour:(int)h
{
    switch (h) {
        case 12: return @"Noon";
        case 0:
        case 24: return @"12";
        default:
            return @(h % 12).stringValue;
    }
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    
    BLEvent *e1 = [BLEvent new];
    e1.start = [NSDate dateWithTimeInterval:arc4random()%24 * 3600 sinceDate:[[NSDate date] startOfDayWithCalendar:nil]];
    e1.end = [NSDate dateWithTimeInterval:60*60 sinceDate:e1.start];
    e1.title = @"Event 1";
    e1.type = @"a";
    
    BLEvent *e2 = [BLEvent new];
    e2.start = [NSDate dateWithTimeInterval:arc4random()%24 * 3600 sinceDate:[[NSDate date] startOfDayWithCalendar:nil]];
    e2.end = [NSDate dateWithTimeInterval:60*60 sinceDate:e2.start];
    e2.title = @"Event 2";
    e2.type = @"c";
    
    BLEvent *e3 = [BLEvent new];
    e3.start = [NSDate dateWithTimeInterval:arc4random()%24 * 3600 sinceDate:[[NSDate date] startOfDayWithCalendar:nil]];
    e3.end = [NSDate dateWithTimeInterval:60*60 sinceDate:e3.start];
    e3.title = @"Event 3";
    e3.type = @"r";

    self.events = [NSMutableArray arrayWithArray:@[e1, e2, e3]];
}

- (void)setEvents:(NSMutableArray *)events
{
    for (UIView *v in _eventLabels) [v removeFromSuperview];
    [_eventLabels removeAllObjects];
    _events = events;
    for (BLEvent *event in events) [self drawEvent:event];
}

- (void)addEvent:(BLEvent *)event
{
    [_events addObject:event];
    [self drawEvent:event];
}

- (void)drawEvent:(BLEvent *)event
{
    NSTimeInterval day = 3600 * 24;
    NSTimeInterval start = [event.start timeIntervalSinceDate:[event.start startOfDayWithCalendar:nil]];
    NSTimeInterval duration = [event.end timeIntervalSinceDate:event.start];
    BLEventLabel *label = [[BLEventLabel alloc] initWithFrame:CGRectMake(kHourLabelRightEdgeX + kMarginX, start/day*kDayTableHeight, kDayTableWidth, duration/day*kDayTableHeight)];
    label.event = event;
    [label addTarget:self action:@selector(eventTapped:) forControlEvents:UIControlEventTouchUpInside];

    NSMutableArray *labelsToRedraw = [NSMutableArray new];
    for (UILabel *eLabel in _eventLabels) {
        if (CGRectIntersectsRect(label.frame, eLabel.frame)) {
            [labelsToRedraw addObject:eLabel];
        }
    }
    [labelsToRedraw sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        UILabel *l1 = obj1;
        UILabel *l2 = obj2;
        if (l1.frame.origin.x < l2.frame.origin.x) return NSOrderedAscending;
        else if (l1.frame.origin.x == l2.frame.origin.x) return NSOrderedSame;
        else return NSOrderedDescending;
    }];
    if (labelsToRedraw.count) {
        CGFloat width = kDayTableWidth/(labelsToRedraw.count+1);
        for (int i = 0; i < labelsToRedraw.count; i++) {
            UILabel *l = labelsToRedraw[i];
            l.frame = CGRectMake(kHourLabelRightEdgeX + kMarginX + i * width, l.frame.origin.y, width, l.frame.size.height);
        }
        label.frame = CGRectMake(kHourLabelRightEdgeX + kMarginX + labelsToRedraw.count * width, label.frame.origin.y, width, label.frame.size.height);
    }
    [_eventLabels addObject:label];
    [self addSubview:label];
}

- (void)eventTapped:(BLEventLabel *)sender
{
    [_blDelegate dayView:self tappedOnEvent:sender.event];
}

@end
