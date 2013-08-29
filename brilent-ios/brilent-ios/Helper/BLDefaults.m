//
//  BLDefaults.m
//  brilent-ios
//
//  Created by Yong Lin on 8/28/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import "BLDefaults.h"
#import "BLSingleton.h"

@implementation BLDefaults

BL_SYNTHESIZE_SINGLETON(BLDefaults, defaults, ^(BLDefaults *instance){ return [instance init];});

@end
