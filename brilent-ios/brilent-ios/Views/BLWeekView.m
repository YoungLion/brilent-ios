//
//  BLWeekView.m
//  brilent-ios
//
//  Created by Yong Lin on 8/29/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import "BLWeekView.h"

#define daysOfWeek @[@"S", @"M", @"T", @"W", @"T", @"F", @"S"]

@interface BLWeekView()
{
    NSDate *_selectedDay;
}
@end

@implementation BLWeekView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _selectedDay = [NSDate date];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    NSDate *start = [_selectedDay dateStartOfWeek];
    UIFont *labelFont = [UIFont fontWithName:@"HelveticaNeue" size:10];
    UIFont *weekdayFont = [UIFont fontWithName:@"HelveticaNeue" size:18];
    UIFont *weekendFont = [UIFont fontWithName:@"HelveticaNeue" size:18];
    UIFont *highlightColorForToday = [UIFont fontWithName:@"HelveticaNeue" size:18];
    UIFont *highlightColorForNonToday = [UIFont fontWithName:@"HelveticaNeue" size:18];
    
    UIColor *textColor = [UIColor blackColor];
    for (int i = 0; i < 7; i++)
    {
        NSDate *date = [start addDay:i];
        if ([date isOnSameDayAsDate:_selectedDay withCalendar:nil])
        {
            if ([date isOnSameDayAsDate:[NSDate date] withCalendar:nil])
            {
                
            }
            else
            {
                
            }
        }
        else if ([date isOnSameDayAsDate:[NSDate date] withCalendar:nil])
        {
            
        }
        [self drawString:daysOfWeek[i] font:labelFont color:textColor centeredAt:CGPointMake(320.f/14 + i*320.f/7, 20)];
        [self drawString:@(date.day).stringValue font:weekdayFont color:textColor centeredAt:CGPointMake(320.f/14 + i*320.f/7, 50)];
    }
}

- (void)drawString:(NSString *)string
              font:(UIFont *)font
             color:(UIColor *)color
        centeredAt:(CGPoint)center
{
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:string];
    NSRange range = NSMakeRange(0, [string length]);
    
    [attrString addAttribute:NSFontAttributeName value:font range:range];
    [attrString addAttribute:NSForegroundColorAttributeName value:color range:range];
    
    CGSize size = [attrString size];
    CGPoint point;
    point.x = center.x - size.width / 2;
    point.y = center.y - size.height / 2;
    [attrString drawAtPoint:point];
}
@end
