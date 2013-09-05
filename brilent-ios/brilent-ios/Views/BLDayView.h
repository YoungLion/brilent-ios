//
//  BLDayView.h
//  brilent-ios
//
//  Created by Yong Lin on 9/3/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BLEvent;

@protocol BLDayViewDelegate;

@interface BLDayView : UIScrollView

@property (nonatomic, strong) NSMutableArray *events;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, weak) id<BLDayViewDelegate> blDelegate;
@end

@protocol BLDayViewDelegate <NSObject>

- (void)dayView:(BLDayView *)dayView tappedOnEvent:(BLEvent *)event;
@end