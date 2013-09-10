//
//  BLStartupViewController.m
//  brilent-ios
//
//  Created by Yong Lin on 8/27/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import "BLStartupViewController.h"
#import <Foundation/NSNotificationQueue.h>

@implementation BLStartupViewController

- (IBAction)loginButtonTouched:(UIButton *)sender {
    self.oAuthLoginView = [self.storyboard instantiateViewControllerWithIdentifier:@"Linkedin login"];
    
    // register to be told when the login is finished
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginViewDidFinish:)
                                                 name:@"loginViewDidFinish"
                                               object:_oAuthLoginView];
    
    [self presentViewController:_oAuthLoginView animated:YES completion:nil];
}
-(void) loginViewDidFinish:(NSNotification*)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // We're going to do these calls serially just for easy code reading.
    // They can be done asynchronously
    // Get the profile, then the network updates
    [self profileApiCall];
	
}

- (void)profileApiCall
{
    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~"];
    OAMutableURLRequest *request =
    [[OAMutableURLRequest alloc] initWithURL:url
                                    consumer:self.oAuthLoginView.consumer
                                       token:self.oAuthLoginView.accessToken
                                    callback:nil
                           signatureProvider:nil];
    
    [request setValue:@"json" forHTTPHeaderField:@"x-li-format"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(profileApiCallResult:didFinish:)
                  didFailSelector:@selector(profileApiCallResult:didFail:)];
}

- (void)profileApiCallResult:(OAServiceTicket *)ticket didFinish:(NSData *)data
{
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    
    NSDictionary *profile = [responseBody objectFromJSONString];
    if ( profile )
    {
        BLLog(@"name : %@", [[NSString alloc] initWithFormat:@"%@ %@",
                     [profile objectForKey:@"firstName"], [profile objectForKey:@"lastName"]]);
        BLLog(@"headerline : %@", [profile objectForKey:@"headline"]);
    }
    
    // The next thing we want to do is call the network updates
}

- (void)profileApiCallResult:(OAServiceTicket *)ticket didFail:(NSData *)error
{
    NSLog(@"%@",[error description]);
}

- (void)networkApiCallResult:(OAServiceTicket *)ticket didFail:(NSData *)error
{
    NSLog(@"%@",[error description]);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

@end
