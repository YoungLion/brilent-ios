//
//  BLWeekView.h
//  brilent-ios
//
//  Created by Yong Lin on 8/29/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLWeekView : UIView

- (void)locateToday;
- (void)locateDay:(NSDate *)day;
@end
