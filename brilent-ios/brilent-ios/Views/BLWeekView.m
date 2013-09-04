//
//  BLWeekView.m
//  brilent-ios
//
//  Created by Yong Lin on 8/29/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import "BLWeekView.h"

#define daysOfWeek @[@"S", @"M", @"T", @"W", @"T", @"F", @"S"]

#define kSelectedTextColor           [UIColor whiteColor]
#define kSelectedNontodayBGColor     [UIColor blackColor]
#define kSelectedTodayBGColor        [UIColor redColor]
#define kBGRadius                    20.f
#define kSelectedTextFont            [UIFont fontWithName:@"HelveticaNeue-Medium" size:18]
#define kUnselectedWeekdayTextColor  [UIColor blackColor]
#define kUnselectedWeekendTextColor  [UIColor lightGrayColor]
#define kUnselectedTodayTextColor    [UIColor redColor]
#define kUnselectedTextFont          [UIFont fontWithName:@"HelveticaNeue" size:18]
#define kDayOfWeekFont               [UIFont fontWithName:@"HelveticaNeue" size:10]
#define kDayOfWeekdayTextColor       [UIColor blackColor]
#define kDayOfWeekendTextColor       [UIColor lightGrayColor]
#define kDayFormatFont               [UIFont fontWithName:@"HelveticaNeue" size:16]

#define kDayButtonTagBase           100
#define kScrollViewHeight           50.f

@interface BLWeekView() <UIScrollViewDelegate>
{
    int _selectedDayOfWeek;
    NSDate *_firstDay, *_pickedDate;
    BOOL _shouldManuallySetDayAfterScroll;
}
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UILabel *selectedDateLabel;
@property (nonatomic, strong) NSDate *selectedDay;
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
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width*3, kScrollViewHeight);
    _scrollView.bounds = CGRectMake(_scrollView.frame.size.width, 0, self.bounds.size.width, kScrollViewHeight);
    _scrollView.delegate = self;
    self.backgroundColor = [UIColor clearColor];
    _selectedDay = [NSDate date];
    _selectedDayOfWeek = [_selectedDay dayOfWeek] - 1;
    _firstDay = [self firstDayOfLastWeekFromDate:_selectedDay];
    
    for (int i = 0; i < 7; i++)
    {
        UIColor *dayOfWeekTextColor;
        if (i == 0 || i == 6) dayOfWeekTextColor = kDayOfWeekendTextColor;
        else dayOfWeekTextColor = kDayOfWeekdayTextColor;
        [self drawString:daysOfWeek[i] font:kDayOfWeekFont color:dayOfWeekTextColor centeredAt:CGPointMake(_scrollView.frame.size.width/14 + i*_scrollView.frame.size.width/7, 30)];
    }
    for (int i = 0; i < 21; i++)
    {
        NSDate *date = [_firstDay addDay:i];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(_scrollView.frame.size.width/7*i, 0, _scrollView.frame.size.width/7, kScrollViewHeight)];
        [button setTitle:@(date.day).stringValue forState:UIControlStateNormal];
        [button addTarget:self action:@selector(touched:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = kDayButtonTagBase + i;
        [self.scrollView addSubview:button];
        [self configureButton:button forDate:date animated:NO];
        [button setBackgroundImage:[UIImage circleImageWithDiameter:kBGRadius edgeInsets:UIEdgeInsetsMake((kScrollViewHeight - 2*kBGRadius)/2, (_scrollView.frame.size.width/7 - 2 * kBGRadius)/2, (kScrollViewHeight - 2*kBGRadius)/2, (_scrollView.frame.size.width/7 - 2 * kBGRadius)/2) color:[UIColor lightlightGrayColor] backgroundColor:nil] forState:UIControlStateHighlighted];
    }
    
    NSString *dateString = [NSDateFormatter localizedStringFromDate:_selectedDay dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterNoStyle];
    self.selectedDateLabel.font = kDayFormatFont;
    self.selectedDateLabel.textColor = [UIColor blackColor];
    self.selectedDateLabel.text = dateString;
}

- (void)configureWeeks
{
    for (int i = 0; i < 21; i++)
    {
        NSDate *date = [_firstDay addDay:i];
        UIButton *button = (UIButton *)[self viewWithTag:kDayButtonTagBase + i];
        [button setTitle:@(date.day).stringValue forState:UIControlStateNormal];
        [self configureButton:button forDate:date animated:NO];
    }
}

- (void)configureButton:(UIButton *)button forDate:(NSDate *)date animated:(BOOL)animated
{
    UIColor *textColor;
    UIFont *textFont;
    UIColor *BGColor = nil;
    if ([date isOnSameDayAsDate:_selectedDay withCalendar:nil])
    {
        textColor = kSelectedTextColor;
        textFont = kSelectedTextFont;
        if ([date isOnSameDayAsDate:[NSDate date] withCalendar:nil])
        {
            BGColor = kSelectedTodayBGColor;
        }
        else BGColor = kSelectedNontodayBGColor;
    }
    else
    {
        textFont = kUnselectedTextFont;
        if ([date isOnSameDayAsDate:[NSDate date] withCalendar:nil])
        {
            textColor = kUnselectedTodayTextColor;
        }
        else if (date.dayOfWeek == 1 || date.dayOfWeek == 7) textColor = kUnselectedWeekendTextColor;
        else textColor = kUnselectedWeekdayTextColor;
    }
    if (animated)
    {
        [UIView animateWithDuration:0.1
                              delay:0 options:UIViewAnimationOptionCurveLinear
                         animations:^{
                                        button.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                                        [button setTitleColor:textColor forState:UIControlStateNormal];
                                        button.titleLabel.font = textFont;
                                        [button setBackgroundImage:[UIImage circleImageWithDiameter:kBGRadius edgeInsets:UIEdgeInsetsMake((kScrollViewHeight - 2*kBGRadius)/2, (_scrollView.frame.size.width/7 - 2 * kBGRadius)/2, (kScrollViewHeight - 2*kBGRadius)/2, (_scrollView.frame.size.width/7 - 2 * kBGRadius)/2) color:BGColor backgroundColor:nil] forState:UIControlStateNormal];
                                        [UIView animateWithDuration:0.1
                                                              delay:0
                                                            options:UIViewAnimationOptionCurveLinear
                                                         animations:^{
                                                                        button.alpha = 1;
                                                        }
                                                         completion:nil];
                        }
        ];
    }
    else
    {
        [button setTitleColor:textColor forState:UIControlStateNormal];
        button.titleLabel.font = textFont;
        [button setBackgroundImage:[UIImage circleImageWithDiameter:kBGRadius edgeInsets:UIEdgeInsetsMake((kScrollViewHeight - 2*kBGRadius)/2, (_scrollView.frame.size.width/7 - 2 * kBGRadius)/2, (kScrollViewHeight - 2*kBGRadius)/2, (_scrollView.frame.size.width/7 - 2 * kBGRadius)/2) color:BGColor backgroundColor:nil] forState:UIControlStateNormal];
    }
}

#pragma mark - Public

- (IBAction)touched:(UIButton *)sender
{
    if (_selectedDayOfWeek != (sender.tag - kDayButtonTagBase) % 7) {
        UIButton *button = (UIButton *)[self viewWithTag: kDayButtonTagBase + _selectedDayOfWeek + 7];
        NSDate *previousSelectedDay = _selectedDay;
        self.selectedDay = [_firstDay addDay:sender.tag - kDayButtonTagBase];
        [self configureButton:button forDate:previousSelectedDay animated:YES];
        [self configureButton:sender forDate:_selectedDay animated:NO];
    }
}

- (IBAction)showNextWeek
{
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * 2, 0) animated:YES];
}

- (IBAction)showPreviousWeek
{
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)locateDay:(NSDate *)day
{
    NSDate *newFirstDay = [self firstDayOfLastWeekFromDate:day];
    NSTimeInterval timeDiff = [newFirstDay timeIntervalSinceDate:_firstDay];
    if ( timeDiff == 0) {
        self.selectedDay = day;
    } else {
        _pickedDate = day;
        _shouldManuallySetDayAfterScroll = YES;
        NSDate *weekStart = [day startDayOfWeekWithCalendar:nil];
        int factor = timeDiff > 0 ? 2 : 0;
        for (int i = 0; i < 7; i++)
        {
            NSDate *date = [weekStart addDay:i];
            UIButton *button = (UIButton *)[self viewWithTag:kDayButtonTagBase + 7 * factor + i];
            [button setTitle:@(date.day).stringValue forState:UIControlStateNormal];
            [self configureButton:button forDate:date animated:NO];
        }
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * factor, 0) animated:YES];
    }
}

- (void)locateToday
{
    [self locateDay:[NSDate date]];
}

#pragma mark - Private

- (void)setSelectedDay:(NSDate *)selectedDay
{
    NSTimeInterval timeDiff = [selectedDay timeIntervalSinceDate:_selectedDay];
    _selectedDay = selectedDay;
    _selectedDayOfWeek = selectedDay.dayOfWeek - 1;
    [self setDateLabelText:[NSDateFormatter localizedStringFromDate:_selectedDay dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterNoStyle] fadeInFromLeft:timeDiff < 0];
    NSDate *newFirstDay = [self firstDayOfLastWeekFromDate:_selectedDay];
    if (![_firstDay isEqualToDate:newFirstDay]) {
        _firstDay = newFirstDay;
        [self configureWeeks];
    }
}

- (void)setDateLabelText:(NSString *)text fadeInFromLeft:(BOOL)left
{
    int factor = left ? 1 : -1;
    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         _selectedDateLabel.transform = CGAffineTransformMakeTranslation(30 * factor, 0);
                         _selectedDateLabel.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         _selectedDateLabel.transform = CGAffineTransformMakeTranslation(-30 * factor, 0);
                         _selectedDateLabel.text = text;
                         [UIView animateWithDuration:0.15
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              _selectedDateLabel.transform = CGAffineTransformIdentity;
                                              _selectedDateLabel.alpha = 1;
                                          }
                                          completion:nil];
                     }
     ];
}

- (NSDate *)firstDayOfLastWeekFromDate:(NSDate *)date
{
    return [[date addDay:-7] startDayOfWeekWithCalendar:nil];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_scrollView.contentOffset.x < _scrollView.frame.size.width ) {
        [scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:NO];
        self.selectedDay = [_selectedDay addDay:-7];
    }
    else if ( _scrollView.contentOffset.x >= 2 *  _scrollView.frame.size.width ) {
        [scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:NO];
        self.selectedDay = [_selectedDay addDay:7];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (_scrollView.contentOffset.x < _scrollView.frame.size.width ) {
        [scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:NO];
        if (!_shouldManuallySetDayAfterScroll) {
            self.selectedDay = [_selectedDay addDay:-7];
        }
        else {
            self.selectedDay = _pickedDate;
            _shouldManuallySetDayAfterScroll = NO;
        }
    }
    else if ( _scrollView.contentOffset.x >= 2 *  _scrollView.frame.size.width  ) {
        [scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:NO];
        if (!_shouldManuallySetDayAfterScroll) {
            self.selectedDay = [_selectedDay addDay:7];
        }
        else {
            self.selectedDay = _pickedDate;
            _shouldManuallySetDayAfterScroll = NO;
        }
    }
}

@end
