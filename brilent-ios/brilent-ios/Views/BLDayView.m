//
//  BLDayView.m
//  brilent-ios
//
//  Created by Yong Lin on 9/3/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import "BLDayView.h"
#import "BLEvent.h"

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

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
    _eventLabels = [NSMutableArray new];
}

- (void)setup
{
    BLLog(@"intersect: %d", CGRectIntersectsRect(CGRectMake(0, 0, 1, 1), CGRectMake(0, 1, 1, 1)));
    self.contentSize = CGSizeMake(self.frame.size.width, kHourlySpacing * 24);
    self.contentInset = UIEdgeInsetsMake(kTopMargin, 0, kBottomMargin, 0);
    for (int i = 0; i <= 24; i++) {
        UILabel *label = [UILabel new];
        label.text = [self textForHour:i];
        label.font = kHourFont;
        [label sizeToFit];
        CGRect rect = label.frame;
        rect.origin = CGPointMake(kHourLabelRightEdgeX - rect.size.width, i * kHourlySpacing);
        label.frame = rect;
        [self addSubview:label];
        
        UIView *hourMark = [[UIView alloc] initWithFrame:CGRectMake(kHourLabelRightEdgeX + kMarginX, CGRectGetMidY(rect), kDayTableWidth, 1)];
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

- (void)setEvents:(NSMutableArray *)events
{
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
    UILabel *label = [UILabel new];
    label.backgroundColor = [self colorFromEventType:event.type];
    label.alpha = 0.5;
    label.text = event.title;
    NSTimeInterval day = 3600 * 24;
    NSTimeInterval start = [event.start timeIntervalSinceDate:[event.start startOfDayWithCalendar:nil]];
    NSTimeInterval duration = [event.end timeIntervalSinceDate:event.start];
    label.frame = CGRectMake(kHourLabelRightEdgeX + kMarginX, start/day*kDayTableHeight, kDayTableWidth, duration/day*kDayTableHeight);
    
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
    CGFloat width = kDayTableWidth/(labelsToRedraw.count+1);
    for (int i = 0; i < labelsToRedraw.count; i++) {
        UILabel *l = labelsToRedraw[i];
        l.frame = CGRectMake(kHourLabelRightEdgeX + kMarginX + i * width, l.frame.origin.y, width, l.frame.size.height);
    }
    label.frame = CGRectMake(kHourLabelRightEdgeX + kMarginX + labelsToRedraw.count * width, label.frame.origin.y, width, label.frame.size.height);
    [_eventLabels addObject:label];
    [self addSubview:label];
}

- (UIColor *)colorFromEventType:(NSString *)type
{
    if ([type isEqualToString:@"a"]) {
        return [UIColor greenColor];
    } else if ([type isEqualToString:@"r"]) {
        return [UIColor lightGrayColor];
    } else if ([type isEqualToString:@"c"]) {
        return [UIColor blueColor];
    } else {
        return [UIColor purpleColor];
    }
}

@end
