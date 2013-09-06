//
//  BLTimer.h
//  brilent-ios
//
//  Created by Yong Lin on 9/6/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLTimer : NSObject

- (id)initWithInitialTimeInterval:(NSTimeInterval)initialTimeInterval
                   repeatInterval:(NSTimeInterval)repeatInterval
                            queue:(dispatch_queue_t)queue
                        fireBlock:(void (^)(void))fireBlock;

- (id)initWithInitialFireDate:(NSDate *)initialFireDate
               repeatInterval:(NSTimeInterval)repeatInterval
                        queue:(dispatch_queue_t)queue
                    fireBlock:(void (^)(void))fireBlock;

- (void)suspend;
- (void)resume;

@end