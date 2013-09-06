//
//  BLDayViewContainer.m
//  brilent-ios
//
//  Created by Yong Lin on 9/5/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import "BLDayViewContainer.h"
#import "BLDayView.h"

@interface BLDayViewContainer ()<UIScrollViewDelegate>
{
    BLDayView *_leftDayView, *_rightDayView, *_currentDayView;
    BOOL _shouldManuallySetDayAfterScroll;
    NSDate *_pickedDate;
}
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@end

@implementation BLDayViewContainer

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    _scrollView.contentSize = CGSizeMake(self.frame.size.width*3, self.frame.size.height);
    [_scrollView setContentOffset:CGPointMake(self.frame.size.width, 0)];
    _scrollView.delegate = self;
    self.backgroundColor = [UIColor clearColor];
    
    _leftDayView = [[BLDayView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [_scrollView addSubview:_leftDayView];
    _currentDayView = [[BLDayView alloc] initWithFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
    [_currentDayView setDate:[NSDate date]];
    [_scrollView addSubview:_currentDayView];
    _rightDayView = [[BLDayView alloc] initWithFrame:CGRectMake(self.frame.size.width*2, 0, self.frame.size.width, self.frame.size.height)];
    [_scrollView addSubview:_rightDayView];
}

#pragma mark - Public

- (void)setDate:(NSDate *)date animated:(BOOL)animated
{
    NSTimeInterval timeDiff = [[date startOfDayWithCalendar:nil] timeIntervalSinceDate:[self.currentDayView.date startOfDayWithCalendar:nil]];
    if (timeDiff != 0) {
        if (animated) {
            _shouldManuallySetDayAfterScroll = YES;
            _pickedDate = date;
            [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * (timeDiff > 0 ? 2:0), 0) animated:YES];
        }
        else {
            _currentDayView.date = date;
        }
    }
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_scrollView.contentOffset.x < self.frame.size.width && _leftDayView.contentOffset.y !=  _currentDayView.contentOffset.y) {
        [_leftDayView setContentOffset:_currentDayView.contentOffset];
    }
    else if (_scrollView.contentOffset.x > self.frame.size.width && _rightDayView.contentOffset.y !=  _currentDayView.contentOffset.y) {
        [_rightDayView setContentOffset:_currentDayView.contentOffset];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_scrollView.contentOffset.x < _scrollView.frame.size.width ) {
        [scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:NO];
        _currentDayView.date = [_currentDayView.date addDay:-1];
        [_delegate dayViewContainer:self didChangeToDate:_currentDayView.date];
    }
    else if ( _scrollView.contentOffset.x >= 2 *  _scrollView.frame.size.width ) {
        [scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:NO];
        _currentDayView.date = [_currentDayView.date addDay:1];
        [_delegate dayViewContainer:self didChangeToDate:_currentDayView.date];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (_scrollView.contentOffset.x < _scrollView.frame.size.width ) {
        [scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:NO];
        if (_shouldManuallySetDayAfterScroll) {
            _currentDayView.date = _pickedDate;
            _shouldManuallySetDayAfterScroll = NO;
        }
    }
    else if ( _scrollView.contentOffset.x >= 2 *  _scrollView.frame.size.width  ) {
        [scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:NO];
        if (_shouldManuallySetDayAfterScroll) {
            _currentDayView.date = _pickedDate;
            _shouldManuallySetDayAfterScroll = NO;
        }
    }
}


@end
