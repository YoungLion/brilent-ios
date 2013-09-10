//
//  BLStartupViewController.h
//  brilent-ios
//
//  Created by Yong Lin on 8/27/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLViewController.h"
#import "OAuthLoginView.h"
#import "JSONKit.h"
#import "OAConsumer.h"
#import "OAMutableURLRequest.h"
#import "OADataFetcher.h"
#import "OATokenManager.h"

@interface BLStartupViewController : BLViewController

@property (nonatomic, retain) OAuthLoginView *oAuthLoginView;

@end
