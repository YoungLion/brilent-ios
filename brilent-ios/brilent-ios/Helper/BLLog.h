//
//  BLLog.h
//  brilent-ios
//
//  Created by Yong Lin on 8/28/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BLLog( s, ...) BLLogHelper(__FILE__, __LINE__, [NSString stringWithFormat:(s), ## __VA_ARGS__])

void BLLogHelper(const char *filepath, int line, NSString *message);
