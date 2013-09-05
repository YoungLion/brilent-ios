//
//  BLWeekView.h
//  brilent-ios
//
//  Created by Yong Lin on 8/29/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BLWeekViewDelegate;

@interface BLWeekView : UIView

- (void)locateToday;
- (void)locateDay:(NSDate *)day;
@property (nonatomic, weak) id<BLWeekViewDelegate> delegate;
@end

@protocol BLWeekViewDelegate <NSObject>

- (void)weekView:(BLWeekView *)weekView didSelectDate:(NSDate *)date;

@end
