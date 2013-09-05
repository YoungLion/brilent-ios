//
//  BLDayViewContainer.h
//  brilent-ios
//
//  Created by Yong Lin on 9/5/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLDayView.h"

@protocol BLDayViewContainerDelegate;

@interface BLDayViewContainer : UIView
@property (nonatomic, readonly) BLDayView *currentDayView;
@property (nonatomic, weak) id<BLDayViewContainerDelegate> delegate;
- (void)setDate:(NSDate *)date animated:(BOOL)animated;
@end

@protocol BLDayViewContainerDelegate <NSObject>

- (void)dayViewContainer:(BLDayViewContainer *)dayViewContainer didChangeToDate:(NSDate *)date;
@end