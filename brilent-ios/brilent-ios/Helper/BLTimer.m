//
//  BLTimer.m
//  brilent-ios
//
//  Created by Yong Lin on 9/6/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

// While LKTimer will run on the queue you specify (invoking the fireBlock at the specified times)
// it should be initialized, suspended, resumed, and deallocated from the main thread only.

#import "BLTimer.h"

@implementation BLTimer {
    dispatch_source_t _timer;
    NSUInteger _suspendCount;
    BOOL _applicationStateIsBackground;
    NSArray *_notificationObservers;
}

- (id)initWithInitialTimeInterval:(NSTimeInterval)initialTimeInterval
                   repeatInterval:(NSTimeInterval)repeatInterval
                            queue:(dispatch_queue_t)queue
                        fireBlock:(void (^)(void))fireBlock
{
    self = [super init];
    if ( self )
    {
        dispatch_time_t initialDispatchTime = dispatch_time(DISPATCH_TIME_NOW, initialTimeInterval * NSEC_PER_SEC);
        [self commonInitializationWithInitialDispatchTime:initialDispatchTime
                                           repeatInterval:repeatInterval
                                                    queue:queue
                                                fireBlock:fireBlock];
    }
    
    return self;
}

- (id)initWithInitialFireDate:(NSDate *)initialFireDate
               repeatInterval:(NSTimeInterval)repeatInterval
                        queue:(dispatch_queue_t)queue
                    fireBlock:(void (^)(void))fireBlock
{
    self = [super init];
    if ( self )
    {
        struct timespec initialFireTimespec;
        NSTimeInterval timeIntervalSince1970 = [initialFireDate timeIntervalSince1970];
        NSTimeInterval integralPart = 0.0;
        NSTimeInterval fractionalPart = modf(timeIntervalSince1970, &integralPart);
        initialFireTimespec.tv_sec = integralPart;
        initialFireTimespec.tv_nsec = fractionalPart * NSEC_PER_SEC;
        dispatch_time_t initialDispatchTime = dispatch_walltime(&initialFireTimespec, 0);
        [self commonInitializationWithInitialDispatchTime:initialDispatchTime
                                           repeatInterval:repeatInterval
                                                    queue:queue
                                                fireBlock:fireBlock];
    }
    
    return self;
}

- (void)commonInitializationWithInitialDispatchTime:(dispatch_time_t)initialDispatchTime
                                     repeatInterval:(NSTimeInterval)repeatInterval
                                              queue:(dispatch_queue_t)queue
                                          fireBlock:(void (^)(void))fireBlock
{
    _suspendCount = 1;
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer,
                              initialDispatchTime,
                              repeatInterval * NSEC_PER_SEC,
                              0);
    dispatch_source_set_event_handler(_timer, fireBlock);
    
    _applicationStateIsBackground = ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground);
    if ( _applicationStateIsBackground == NO )
    {
        [self resume];
    }
    
    __weak BLTimer *weakSelf = self;
    id notificationObserver1 = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                                                 object:nil
                                                                                  queue:[NSOperationQueue mainQueue]
                                                                             usingBlock: ^(NSNotification * notification) {
                                                                                 BLTimer *strongSelf = weakSelf;
                                                                                 if ( strongSelf )
                                                                                 {
                                                                                     if ( strongSelf->_applicationStateIsBackground )
                                                                                     {
                                                                                         [strongSelf resume];
                                                                                         strongSelf->_applicationStateIsBackground = NO;
                                                                                     }
                                                                                 }
                                                                             }
                                ];
    id notificationObserver2 = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                                                 object:nil
                                                                                  queue:[NSOperationQueue mainQueue]
                                                                             usingBlock: ^(NSNotification * notification) {
                                                                                 BLTimer *strongSelf = weakSelf;
                                                                                 if ( strongSelf )
                                                                                 {
                                                                                     if ( strongSelf->_applicationStateIsBackground == NO )
                                                                                     {
                                                                                         [strongSelf suspend];
                                                                                         strongSelf->_applicationStateIsBackground = YES;
                                                                                     }
                                                                                 }
                                                                             }
                                ];
    
    _notificationObservers = @[ notificationObserver1, notificationObserver2 ];
}

- (void)dealloc
{
    for ( id notificationObserver in _notificationObservers )
    {
        [[NSNotificationCenter defaultCenter] removeObserver:notificationObserver];
    }
    
    if ( _timer )
    {
        while ( _suspendCount > 0 )
        {
            [self resume];
        }
        
        dispatch_source_cancel(_timer);
    }
}

- (void)suspend
{
    if ( _timer )
    {
        dispatch_suspend(_timer);
        _suspendCount++;
    }
}

- (void)resume
{
    if ( _timer )
    {
        if ( _suspendCount == 0 )
        {
            [[NSException exceptionWithName:@"LKTimerResumeWhenNotSuspendedException"
                                     reason:@"resuming LKTimer that is not suspended"
                                   userInfo:nil] raise];
        }
        
        dispatch_resume(_timer);
        _suspendCount--;
    }
}

@end

