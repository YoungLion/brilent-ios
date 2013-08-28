//
//  BLHelper.m
//  brilent-ios
//
//  Created by Yong Lin on 8/27/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import "BLHelper.h"
#include <libkern/OSAtomic.h>  // OSAtomicAdd32

@implementation BLHelper

void setNetworkActivityIndicator(BOOL active)
{
    static volatile int32_t atomic_counter;
    if (active) {
        if (OSAtomicAdd32(1, &atomic_counter) >= 1) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        }
    }
    else {
        if (OSAtomicAdd32(-1, &atomic_counter) == 0) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    }
}

@end
