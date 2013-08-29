//
//  BLHttpClient.m
//  brilent-ios
//
//  Created by Yong Lin on 8/27/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import "BLHttpClient.h"
#import "BLHelper.h"

#define SIMULATE_SERVER_DELAY 0
#define kHttpClientTimeout 60

@interface BLHttpClient()
{
    NSMutableData *_receivedData;
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

- (void)sendRequest:(NSMutableURLRequest *)request
{
    [self cancel];
    [self setNetworkActive:YES];
    
    _request = request;
    request.HTTPShouldHandleCookies = YES;
    request.timeoutInterval = _timeout;

    if (_synchronous)
    {
        NSHTTPURLResponse *res = nil;
        NSError *err = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
        
        [self setNetworkActive:NO];
        
        if (err)
        {
            [self dispatchError:err];
        }
        else
        {
            [self receiveResponse:res];
            [self dispatchSuccess:data];
        }
    }
    else
    {
#if SIMULATE_SERVER_DELAY
        double delayInSeconds = arc4random() % 3 * 5.0; // 0, 5, 10s delay
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            BLLog(@"Http Client: !!! artificial delay added: %.1fs !!!", delayInSeconds);
#endif
            _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [_connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [_connection start];
            
            //Just to be safe
            _timer = [NSTimer scheduledTimerWithTimeInterval:_timeout+10 target:self selector:@selector(timeoutTimerOnFire:) userInfo:nil repeats:NO];
#if SIMULATE_SERVER_DELAY
        });
#endif
        
    }
}

- (void)cancel
{
    [_connection cancel];
    [_timer invalidate];
    [self setNetworkActive:NO];
}

#pragma mark NSURLConnection Delegate

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

- (void)connection:(NSURLConnection*)sender didReceiveResponse:(NSHTTPURLResponse*)aResponse
{
    if (_connection == sender) {
        _response = aResponse;
        [self receiveResponse:aResponse];
    }
}

- (void)connection:(NSURLConnection*)sender didReceiveData:(NSData*)data
{
    if (_connection == sender) {
        [_receivedData appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection*)sender
{
    if (_connection == sender) {
        [self cancel];
        [self dispatchSuccess:_receivedData];
    }
}

- (void)connection:(NSURLConnection*)sender didFailWithError:(NSError*)error
{
    if (_connection == sender) {
        [self cancel];
        [self dispatchError:error];
    }
}

#pragma mark - Private
- (void)receiveResponse:(NSHTTPURLResponse *)res
{
    _receivedData = [NSMutableData new];
}

- (void)dispatchError:(NSError *)error
{
    if ([_delegate respondsToSelector:@selector(BLHttpClient:didFailWithError:)])
    {
        [_delegate BLHttpClient:self didFailWithError:error];
    } else {
        BLLog(@"HttpClient: %@ %@", _request.URL.absoluteString, error);
    }
}

- (void)dispatchSuccess:(NSData *)data
{
    if ([_delegate respondsToSelector:@selector(BLHttpClient:didReceiveData:)]) {
        [_delegate BLHttpClient:self didReceiveData:data];
    } else {
        BLLog(@"HttpClient: %@ %@", _request.URL.absoluteString, data);
    }
}

- (void)timeoutTimerOnFire:(id)sender
{
    [self cancel];
    
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:-1001 userInfo:NULL];
    [self dispatchError:error];
}

- (void)setNetworkActive:(BOOL)active
{
    if (_networkActive != active)
    {
        _networkActive = active;
        setNetworkActivityIndicator(active);
    }
}
@end
