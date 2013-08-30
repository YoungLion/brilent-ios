//
//  BLAPI.h
//  brilent-ios
//
//  Created by Yong Lin on 8/29/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLHttpClient.h"

typedef enum {
    kApiSessionLogin,
    kApiSessionLogout,
    kApiUserCreate,
    kApiUserSet,
    kApiUserGet,
    kApiSettingsSet,
    kApiSettingsGet,
    kApiSendDeviceToken,
} BLApiTag;

@interface BLAPI : NSObject<BLHttpClientDelegate>
@property (nonatomic, strong, readonly) BLHttpClient *client;
@property (nonatomic, strong, readonly) NSDictionary *response;
@property (nonatomic, assign, readonly) int errorCode;
@property (nonatomic, strong, readonly) NSString *token;
@property (nonatomic, assign, readonly) BLApiTag tag;
@property (nonatomic, strong, readonly) NSDictionary *params;

- (id)initWithoutToken;
- (void)postApi:(BLApiTag)tag;
- (void)postApi:(BLApiTag)tag withParams:(NSDictionary*)params;

@end
