//
//  BLStopwatch.m
//  brilent-ios
//
//  Created by Yong Lin on 8/28/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import "BLStopwatch.h"

@interface BLStopwatch ()
{
    NSCache *_items;
}
@end

@implementation BLStopwatch

BL_SYNTHESIZE_SINGLETON(BLStopwatch, instance, ^(BLStopwatch *instance){ return [instance init];})

- (id)init
{
    self = [super init];
    if (self)
    {
        _items = [NSCache new];
    }
    return self;
}

- (void)start:(NSString *)name
{
    CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
    [_items setObject:@(now) forKey:name];
}

- (void)stop:(NSString *)name
{
    CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime start = [[_items objectForKey:name] doubleValue];
    if (start)
    {
        [_items removeObjectForKey:name];
        BLLog(@"STOPWATCH [%@]: %f", name, now - start);
    }
    else
    {
        BLLog(@"STOPWATCH [%@] NOT FOUND", name);
    }
}

@end
