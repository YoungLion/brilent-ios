//
//  BLWeekView.m
//  brilent-ios
//
//  Created by Yong Lin on 8/29/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import "BLWeekView.h"

#define daysOfWeek @[@"S", @"M", @"T", @"W", @"T", @"F", @"S"]

#define selectedTextColor           [UIColor whiteColor]
#define selectedNontodayBGColor     [UIColor blackColor]
#define selectedTodayBGColor        [UIColor redColor]
#define BGRadius                    15
#define selectedTextFont            [UIFont fontWithName:@"HelveticaNeue-Medium" size:18]
#define unselectedWeekdayTextColor  [UIColor blackColor]
#define unselectedWeekendTextColor  [UIColor lightGrayColor]
#define unselectedTodayTextColor    [UIColor redColor]
#define unselectedTextFont          [UIFont fontWithName:@"HelveticaNeue" size:18]
#define dayOfWeekFont               [UIFont fontWithName:@"HelveticaNeue" size:10]
#define dayOfWeekdayTextColor       [UIColor blackColor]
#define dayOfWeekendTextColor       [UIColor lightGrayColor]
#define dayFormatFont               [UIFont fontWithName:@"HelveticaNeue" size:16]

@interface BLWeekView()
{
    NSDate *_selectedDay;
    int _selectedDayOfWeek;
    NSDate *_firstDay;
}
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@end

@implementation BLWeekView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    _selectedDay = [NSDate date];
    _firstDay = [_selectedDay startDayOfWeekWithCalendar:nil];
    _selectedDayOfWeek = [_selectedDay dayOfWeek] - 1;

    for (int i = 0; i < 7; i++)
    {
        UIColor *dayOfWeekTextColor;
        if (i == 0 || i == 6) dayOfWeekTextColor = dayOfWeekendTextColor;
        else dayOfWeekTextColor = dayOfWeekdayTextColor;
        [_scrollView drawString:daysOfWeek[i] font:dayOfWeekFont color:dayOfWeekTextColor centeredAt:CGPointMake(320.f/14 + i*320.f/7, 20)];
        
        /*UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(320.f/7*i, 25, 320.f/7, 50)];
        [control addTarget:self action:@selector(touched:) forControlEvents:UIControlEventTouchUpInside];
        control.tag = i;
        [self addSubview:control];*/
    }
}

- (void)drawRect:(CGRect)rect
{
    UIColor *textColor;
    UIFont *textFont;
    
    for (int i = 0; i < 7; i++)
    {
        UIColor *BGColor = nil;
        NSDate *date = [_firstDay addDay:i];
        if ([date isOnSameDayAsDate:_selectedDay withCalendar:nil])
        {
            textColor = selectedTextColor;
            textFont = selectedTextFont;
            if ([date isOnSameDayAsDate:[NSDate date] withCalendar:nil])
            {
                BGColor = selectedTodayBGColor;
            }
            else BGColor = selectedNontodayBGColor;
        }
        else
        {
            textFont = unselectedTextFont;
            if ([date isOnSameDayAsDate:[NSDate date] withCalendar:nil])
            {
                textColor = unselectedTodayTextColor;
            }
            else if (i == 0 || i == 6) textColor = unselectedWeekendTextColor;
            else textColor = unselectedWeekdayTextColor;
            
        }

        
        CGPoint position = CGPointMake(320.f/14 + i*320.f/7, 50);
        if (BGColor)
        {
            [_scrollView drawCircleWithRadius:BGRadius color:BGColor centeredAt:position];

        }
        [_scrollView drawString:@(date.day).stringValue font:textFont color:textColor centeredAt:position];
    }
    
    NSString *dateString = [NSDateFormatter localizedStringFromDate:_selectedDay dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterNoStyle];
    [self drawString:dateString font:dayFormatFont color:[UIColor blackColor] centeredAt:CGPointMake(CGRectGetMidX(self.bounds), 80)];
}

- (IBAction)touched:(UIControl *)sender
{
    if (_selectedDayOfWeek != sender.tag)
    {
        _selectedDayOfWeek = sender.tag;
        _selectedDay = [_firstDay addDay:_selectedDayOfWeek];
        [self setNeedsDisplay];
    }
}

- (IBAction)showNextWeek
{
    _selectedDay = [_selectedDay addDay:-7];
    _firstDay = [_firstDay addDay:-7];
}

- (IBAction)showPreviousWeek
{
    _selectedDay = [_selectedDay addDay:7];
    _firstDay = [_firstDay addDay:7];
}
@end
