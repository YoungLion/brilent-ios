//
//  BLEvent.h
//  brilent-ios
//
//  Created by Yong Lin on 9/3/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLEvent : NSObject
@property (nonatomic, strong) NSDate *start;
@property (nonatomic, strong) NSDate *end;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSNumber *isWeekly;
@end
