//
//  BLAPI.m
//  brilent-ios
//
//  Created by Yong Lin on 8/29/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import "BLAPI.h"
#import "BLDefaults.h"
#import "BLHelper.h"

#define kApiSecret            @"===ILoveYOUGod===gdetjcxujskx%&g4==="
#define kServerUrlString      @"http://www.brilent.com/api/"
#define kApiCallTimeout       60

#define DEBUG_API 1

@interface BLAPI () {
    BOOL _retainedOnce;
    UIBackgroundTaskIdentifier _taskId;
}
@end

@implementation BLAPI

- (id)init
{
    self = [super init];
    if (self)
    {
        NSString* token = [[BLDefaults defaults] objectForKey:kDefaultsSecureSession];
        if (!token) return nil;
    }
    return self;
}

#pragma mark - Public

- (id)initWithoutToken
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (void)postApi:(BLApiTag)tag
{
    [self postApi:tag withParams:@{}];
}

- (void)postApi:(BLApiTag)tag withParams:(NSDictionary*)params
{
    NSAssert(params, @"Invalid parameter given");
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:params];
    dict[@"timestamp"] = @([[NSDate date] timeIntervalSince1970]);
    dict[@"nonce"] = [[NSUUID UUID] UUIDString];
    _params = dict;
    
    NSString *body = [dict stringForRequestBody];
    NSString *signature = [body signatureWithSecret:kApiSecret];
    NSString *url = [self urlWithTag:tag];
    
    NSMutableURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:kApiCallTimeout];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:signature forHTTPHeaderField:@"X-brlient-sig"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    _client = [[BLHttpClient alloc] initWithDelegate:self];
    _client.tag = tag;
    [_client sendRequest:request];
    
    _tag = tag;
    
#if DEBUG_API
    BLLog(@"API call: %@", url);
    BLLog(@"API call: body: %@", body);
#endif
    
    [self retainOnce];
}

#pragma mark - BLHttpClient Delegate

- (void)BLHttpClient:(BLHttpClient *)client didReceiveData:(NSData *)data
{
    NSError *error = nil;
    _response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    BLLog(@"api response: %d %@", client.response.statusCode, client.request.URL.absoluteString);
    
    switch (client.response.statusCode / 100) {
        case 2: {
            _errorCode = [[_response valueForKeyPath:@"brilent.response.error.id"] integerValue];
            if (_errorCode == 0) {
                if ([self handleApi:client.tag withResponse:_response] == NO) {
                    BLLog(@"BLAPI: Don't know what to do with API tag(%d) %@", client.tag, _response);
                }
            } else {
                NSString* errorDescription = [_response valueForKeyPath:@"brilent.response.error.description"];
                NSError* error = [NSError errorWithDomain:client.request.URL.absoluteString
                                                     code:_errorCode
                                                 userInfo:@{ NSLocalizedDescriptionKey : errorDescription }];
                [self BLHttpClient:client didFailWithError:error];
            }
            break;
        }
        case 3:
        case 4:
        case 5:
        default:
            BLLog(@"BL API: request body: %@", [[NSString alloc] initWithData:client.request.HTTPBody encoding:NSUTF8StringEncoding]);
            break;
    }
    [self releaseOnce];
}

- (void)BLHttpClient:(BLHttpClient *)client didFailWithError:(NSError *)error
{
    [self releaseOnce];
}

#pragma mark - Private

- (BOOL)handleApi:(BLApiTag)tag withResponse:(NSDictionary *)response
{
    return NO;
}

- (BOOL)handleApi:(BLApiTag)tag withError:(NSError *)error
{
    return NO;
}

- (NSString *)urlWithTag:(BLApiTag)tag
{
    NSString *path;
    switch (tag) {
        case kApiSessionLogin: path = @"login"; break;
        case kApiSessionLogout: path = @"logout"; break;
        case kApiSendDeviceToken: path = @"sendDeviceToken"; break;
        case kApiSettingsGet: path = @"getSettings"; break;
        case kApiSettingsSet: path = @"setSettings"; break;
        default:
            break;
    }
    return [NSString stringWithFormat:kServerUrlString @"%@?%f", path, fmod([[NSDate date] timeIntervalSinceReferenceDate], 1.0)];
}

- (void)retainOnce
{
    if (!_retainedOnce)
    {
        [self beginBackgroundTask];
        _retainedOnce = YES;
        CFRetain((__bridge CFTypeRef)self);
    }
}

- (void)releaseOnce
{
    if (_retainedOnce)
    {
        _retainedOnce = NO;
        CFRelease((__bridge CFTypeRef)self);
        [self endBackgroundTask];
    }
}

- (void)beginBackgroundTask
{
    UIApplication *app = [UIApplication sharedApplication];
    _taskId = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:_taskId];
    }];
}

- (void)endBackgroundTask
{
    if (_taskId != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:_taskId];
        _taskId = UIBackgroundTaskInvalid;
    }
}

@end
