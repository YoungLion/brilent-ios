//
//  BLLog.m
//  brilent-ios
//
//  Created by Yong Lin on 8/28/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import "BLLog.h"

void BLLogHelper(const char *filepath, int line, NSString *message)
{
    NSLog(@"%@ %4d: %@", [[NSString stringWithUTF8String:filepath] lastPathComponent], line, message);
}