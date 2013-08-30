//
//  BLDefaults.m
//  brilent-ios
//
//  Created by Yong Lin on 8/28/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import "BLDefaults.h"

@interface BLDefaults () {
    NSInteger _previousBuildNumber;
    NSInteger _currentBuildNumber;
    NSString* _keychainServiceName;
}
@end

@implementation BLDefaults

BL_SYNTHESIZE_SINGLETON(BLDefaults, defaults, ^(BLDefaults *instance){ return [instance init];});

- (id)init
{
    self = [super init];
    if (self)
    {
        _keychainServiceName = [[NSBundle mainBundle] bundleIdentifier];
        _currentBuildNumber = [[[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"] integerValue];
        _previousBuildNumber = [[BLDefaults defaults] integerForKey:kDefaultsBuildNumber];
        if (!_previousBuildNumber)
        {
            // When this app has been reinstalled and the previous keychain exists, discard it.
            [self removeAllSecureObjects];
        }
        if (_previousBuildNumber != _currentBuildNumber)
        {
            [self setupDefaultParameters];
            [[BLDefaults defaults] setInteger:_currentBuildNumber forKey:kDefaultsBuildNumber];
            [[BLDefaults defaults] synchronize];
        }
    }
    return self;
}

#pragma mark 

- (NSString*)secureObjectForKey:(NSString*)key
{
    NSData* data = [self searchKeychainCopyMatching:key];
    if (data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (void)setSecureObject:(id)value forKey:(NSString*)key
{
    if ([self secureObjectForKey:key]) {
        [self updateKeychainValue:value forIdentifier:key];
    } else {
        [self createKeychainValue:value forIdentifier:key];
    }
    [self setObject:@"placeholder" forKey:key];  // This makes NSUserDefaultsDidChangeNotification.
}

- (void)removeSecureObjectForKey:(NSString*)key
{
    [self deleteKeychainValue:key];
    [self removeObjectForKey:key];  // This makes NSUserDefaultsDidChangeNotification.
}

#pragma mark

- (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier
{
    NSMutableDictionary *searchDictionary = [NSMutableDictionary new];
    [searchDictionary setObject:(__bridge_transfer id)kSecClassGenericPassword forKey:(__bridge_transfer id)kSecClass];
    
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge_transfer id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge_transfer id)kSecAttrAccount];
    [searchDictionary setObject:_keychainServiceName forKey:(__bridge_transfer id)kSecAttrService];
    
    return searchDictionary;
}

- (NSData *)searchKeychainCopyMatching:(NSString *)identifier
{
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    
    // Add search attributes
    [searchDictionary setObject:(__bridge_transfer id)kSecMatchLimitOne forKey:(__bridge_transfer id)kSecMatchLimit];
    
    // Add search return types
    [searchDictionary setObject:(__bridge_transfer id)kCFBooleanTrue forKey:(__bridge_transfer id)kSecReturnData];
    
    CFTypeRef result;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, &result);
    
    return status == errSecSuccess ? objc_retainedObject(result) : nil;
}

- (BOOL)createKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier
{
    NSMutableDictionary *dictionary = [self newSearchDictionary:identifier];
    
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    [dictionary setObject:passwordData forKey:(__bridge_transfer id)kSecValueData];
    
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)dictionary, NULL);
    
    return status == errSecSuccess ? YES : NO;
}

- (BOOL)updateKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier
{
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    [updateDictionary setObject:passwordData forKey:(__bridge_transfer id)kSecValueData];
    
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)searchDictionary,
                                    (__bridge CFDictionaryRef)updateDictionary);
    
    return status == errSecSuccess ? YES : NO;
}

- (void)deleteKeychainValue:(NSString *)identifier
{
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    SecItemDelete((__bridge CFDictionaryRef)searchDictionary);
}

#pragma mark

- (void)removeAllSecureObjects
{
    [self removeSecureObjectForKey:kDefaultsSecureUserId];
    [self removeSecureObjectForKey:kDefaultsSecureSession];
    [self removeSecureObjectForKey:kDefaultsSecureEmail];
    [self removeSecureObjectForKey:kDefaultsSecureName];
    [self removeSecureObjectForKey:kDefaultsSecurePassword];
}

- (void)setupDefaultParameters
{
    if (![self objectForKey:kDefaultsSettingsReminder]) {
        [self setBool:YES forKey:kDefaultsSettingsReminder];
    }
}

- (void)cleanUp
{
    NSString* appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [self removePersistentDomainForName:appDomain];
}
@end
