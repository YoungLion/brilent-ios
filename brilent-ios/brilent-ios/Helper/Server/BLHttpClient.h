//
//  BLHttpClient.h
//  brilent-ios
//
//  Created by Yong Lin on 8/27/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BLHttpClientDelegate;

@interface BLHttpClient : NSObject<NSURLConnectionDelegate>

@property (nonatomic, weak) id<BLHttpClientDelegate> delegate;
@property (nonatomic, strong, readonly) NSURLConnection *connection;
@property (nonatomic, strong, readonly) NSURLRequest *request;
@property (nonatomic, strong, readonly) NSHTTPURLResponse *response;
@property (nonatomic, strong, readonly) NSMutableData *receivedData;
@property (nonatomic, assign) BOOL synchronous;
@property (nonatomic, assign) int timeout;
@property (nonatomic, assign) int tag;

- (id)initWithDelegate:(id<BLHttpClientDelegate>)aDelegate;
- (void)sendRequest:(NSMutableURLRequest *)request;
- (void)cancel;

@end

@protocol BLHttpClientDelegate <NSObject>

- (void)BLHttpClient:(BLHttpClient *)client didReceiveData:(NSData *)data;
- (void)BLHttpClient:(BLHttpClient *)client didFailWithError:(NSError *)error;

@end
