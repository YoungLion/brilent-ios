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
#import "BLTimer.h"

#define kTopMargin              5
#define kBottomMargin           20
#define kHourlySpacing          50
#define kHourLabelRightEdgeX    50
#define kHourFont               [UIFont fontWithName:@"HelveticaNeue" size:12]
#define kCurrentTimeFont        [UIFont fontWithName:@"HelveticaNeue" size:11]
#define kMarginX                10
#define kDayTableWidth          (self.bounds.size.width - kHourLabelRightEdgeX - kMarginX)
#define kDayTableHeight         (kHourlySpacing * 24)


@interface BLDayView()
{
    NSMutableArray *_eventLabels, *_hourLabels;
    BLTimer *_clockTimer;
    UIView *_currentTimeMark;
    UILabel *_currentTimeLabel;
}
@property (nonatomic, strong) NSDate *currentTime;
@end

@implementation BLDayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)dealloc
{
    _clockTimer = nil;
    _currentTimeMark = nil;
    _currentTimeLabel = nil;
    _eventLabels = nil;
    _hourLabels = nil;
}

#pragma mark - Public

- (void)setDate:(NSDate *)date
{
    _date = date;
    
    if ([date isOnSameDayAsDate:[NSDate date] withCalendar:nil]) {
        _currentTimeLabel.hidden = NO;
        _currentTimeMark.hidden = NO;
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self scrollToCurrentHour];
        });
    } else {
        _currentTimeLabel.hidden = YES;
        _currentTimeMark.hidden = YES;
    }
    [self updateHourLabels];
    
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

#pragma mark - Private

- (void)setup
{
    _eventLabels = [NSMutableArray new];
    _hourLabels = [NSMutableArray arrayWithCapacity:25];
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
        [_hourLabels addObject:label];
        [self addSubview:label];
        
        UIView *hourMark = [[UIView alloc] initWithFrame:CGRectMake(kHourLabelRightEdgeX + kMarginX, kHourlySpacing*i, kDayTableWidth, 1)];
        hourMark.backgroundColor = [UIColor lightlightGrayColor];
        [self addSubview:hourMark];
    }
    
    _currentTimeMark = [UIView new];
    _currentTimeMark.backgroundColor = [UIColor redColor];
    _currentTimeMark.hidden = YES;
    [self addSubview:_currentTimeMark];
    _currentTimeLabel = [UILabel new];
    _currentTimeLabel.textColor = [UIColor redColor];
    _currentTimeLabel.font = kCurrentTimeFont;
    _currentTimeLabel.hidden = YES;
    [self addSubview:_currentTimeLabel];
    [self setCurrentTime:[NSDate date]];
    
    __weak BLDayView *weakSelf = self;
    _clockTimer = [[BLTimer alloc] initWithInitialFireDate:[[[NSDate date] startOfMinuteWithCalendar:nil] dateByAddingTimeInterval:60]
                                                         repeatInterval:60.0
                                                                  queue:dispatch_get_main_queue()
                                                              fireBlock: ^{
                                                                  [weakSelf setCurrentTime:[NSDate date]];
                                                              }
                                ];
}

- (void)setCurrentTime:(NSDate *)currentTime
{
    _currentTime = currentTime;
    NSTimeInterval day = 3600 * 24;
    NSTimeInterval t = [currentTime timeIntervalSinceDate:[currentTime startOfDayWithCalendar:nil]];
    _currentTimeMark.frame = CGRectMake(kHourLabelRightEdgeX + 5, t/day*kDayTableHeight, self.frame.size.width - kHourLabelRightEdgeX - 1, 1);
    _currentTimeLabel.text = [NSDateFormatter localizedStringFromDate:currentTime dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    [_currentTimeLabel sizeToFit];
    _currentTimeLabel.frame = CGRectMake(kHourLabelRightEdgeX - _currentTimeLabel.frame.size.width, _currentTimeMark.frame.origin.y - _currentTimeLabel.frame.size.height / 2, _currentTimeLabel.frame.size.width, _currentTimeLabel.frame.size.height);
    [self updateHourLabels];
}

- (void)scrollToCurrentHour
{
    NSTimeInterval day = 3600 * 24;
    NSTimeInterval t = [[[NSDate date] startOfHourWithCalendar:nil] timeIntervalSinceDate:[[NSDate date] startOfDayWithCalendar:nil]];
    CGFloat y = t/day*kDayTableHeight - kTopMargin;
    [self setContentOffset:CGPointMake(0, y) animated:YES];
}

- (void)updateHourLabels
{
    if (_currentTimeLabel.hidden) {
        for (UILabel *l in _hourLabels) {
            if (l.hidden) l.hidden = NO;
        }
    } else {
        for (UILabel *l in _hourLabels) {
            if ( (CGRectGetMinY(l.frame) - CGRectGetMaxY(_currentTimeLabel.frame) > 1) || (CGRectGetMinY(_currentTimeLabel.frame) - CGRectGetMaxY(l.frame) > 1)) {
                if (l.hidden) l.hidden = NO;
            } else {
                if (!l.hidden) l.hidden = YES;
            }
        }
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
