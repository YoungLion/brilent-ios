//
//  BLHttpClient.m
//  brilent-ios
//
//  Created by Yong Lin on 8/27/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import "BLHttpClient.h"
#import "BLHelper.h"

#define kHttpClientTimeout 60

@interface BLHttpClient()
{
    NSData *_receivedData;
    NSTimer *_timer;
    BOOL _networkActive;
}
@end

@implementation BLHttpClient

- (id)init
{
    self = [super init];
    if (self)
    {
        _timeout = kHttpClientTimeout;
    }
    return self;
}

- (void)dealloc
{
    [self cancel];
}
#pragma mark - Public
- (id)initWithDelegate:(id<BLHttpClientDelegate>)aDelegate
{
    self = [super init];
    if (self)
    {
        _delegate = aDelegate;
    }
    return self;
}

- (void)sendRequest:(NSURLRequest *)request
{
    if (_synchronous)
    {
        
    }
    else
    {
        _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

- (void)cancel
{
    [_connection cancel];
    [_timer invalidate];
    [self setNetworkActive:NO];
}

#pragma mark - Private

- (void)setNetworkActive:(BOOL)active
{
    if (_networkActive != active)
    {
        _networkActive = active;
        setNetworkActivityIndicator(active);
    }
}
@end
