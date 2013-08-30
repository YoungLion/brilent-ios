//
//  BLDefaults.h
//  brilent-ios
//
//  Created by Yong Lin on 8/28/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLDefaults : NSUserDefaults

+ (BLDefaults *)defaults;

- (NSString*)secureObjectForKey:(NSString*)key;
- (void)setSecureObject:(id)value forKey:(NSString*)key;
- (void)removeSecureObjectForKey:(NSString*)key;

- (void)setupDefaultParameters;
- (void)removeAllSecureObjects;

@end

#define kDefaultsBuildNumber                @"bl.buildNumber"
#define kDefaultsUserInfo                   @"bl.user.info"

// Secure data
#define kDefaultsSecureUserId               @"bl.userid"
#define kDefaultsSecureEmail                @"bl.email"
#define kDefaultsSecurePassword             @"bl.password"
#define kDefaultsSecureName                 @"bl.name"
#define kDefaultsSecureSession              @"bl.sessionKey"

// Setting
#define kDefaultsSettingsReminder           @"bl.settings.reminder"
