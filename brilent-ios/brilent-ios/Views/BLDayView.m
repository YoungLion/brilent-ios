//
//  BLDayView.m
//  brilent-ios
//
//  Created by Yong Lin on 9/3/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import "BLDayView.h"
#import "BLEvent.h"

#define kTopMargin 5
#define kBottomMargin 20
#define kHourlySpacing 50
#define kHourLabelRightEdgeX 50
#define kHourFont               [UIFont fontWithName:@"HelveticaNeue" size:12]

@interface BLDayView()
{
}

@end

@implementation BLDayView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
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
        
        UIView *hourMark = [[UIView alloc] initWithFrame:CGRectMake(kHourLabelRightEdgeX + 10, CGRectGetMidY(rect), self.bounds.size.width - kHourLabelRightEdgeX - 10, 1)];
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
    
}

@end
