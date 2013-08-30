//
//  BLHelper.m
//  brilent-ios
//
//  Created by Yong Lin on 8/27/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import "BLHelper.h"
#include <libkern/OSAtomic.h>  // OSAtomicAdd32
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation BLHelper
@end

void setNetworkActivityIndicator(BOOL active)
{
    static volatile int32_t atomic_counter;
    if (active) {
        if (OSAtomicAdd32(1, &atomic_counter) >= 1) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        }
    }
    else {
        if (OSAtomicAdd32(-1, &atomic_counter) == 0) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    }
}

#pragma mark - NSDictionary

@implementation NSDictionary (BLHelper)

- (NSString *)stringForRequestBody
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *key in self.allKeys)
    {
        NSString *param = [self[key] encodedStringForRequestBody];
        [array addObject:[NSString stringWithFormat:@"%@=%@", key, param]];
    }
    return [[array sortedArrayUsingSelector:@selector(compare:)] componentsJoinedByString:@"&"];
}

@end

@implementation NSObject (BLHelper)

- (NSString *)encodedStringForRequestBody
{
    return [self description];
}

@end

@implementation NSString (BLHelper)

- (NSString *)encodedStringForRequestBody
{
    CFStringRef newString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR("!*'();:@&=+@,/?#[]"), kCFStringEncodingUTF8);
    return (NSString*)CFBridgingRelease(newString);
}

- (NSString*)signatureWithSecret:(NSString*)secret
{
    NSString* s = [self stringByAppendingString:secret];
    
    uint8_t* hashBytes = malloc(CC_SHA1_DIGEST_LENGTH * sizeof(uint8_t));
    memset((void *)hashBytes, 0x0, CC_SHA1_DIGEST_LENGTH);
    CC_SHA1_CTX ctx;
    CC_SHA1_Init(&ctx);
    CC_SHA1_Update(&ctx, (void*)[s UTF8String], strlen([s UTF8String]));
    CC_SHA1_Final(hashBytes, &ctx);
    NSData *hash = [NSData dataWithBytes:(const void *)hashBytes length:(NSUInteger)CC_SHA1_DIGEST_LENGTH];
    if (hashBytes) free(hashBytes);
    
    return [hash hexString];
}
@end

#pragma mark - NSData

@implementation NSData (BLHelper)

- (NSString*)hexString
{
    NSMutableString* s = [NSMutableString stringWithCapacity:[self length]];
    uint8_t* p = (uint8_t*)[self bytes];
    for (int i=0; i<[self length]; i++) {
        [s appendFormat:@"%02x", *p++];
    }
    return s;
}
@end

@implementation NSDate (BLHelper)

-(int)year {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSYearCalendarUnit fromDate:self];
    return [components year];
}


-(int)month {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSMonthCalendarUnit fromDate:self];
    return [components month];
}

-(int)day {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSDayCalendarUnit fromDate:self];
    return [components day];
}

- (NSDate *)addDay:(NSInteger)numberOfDays
{
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    
    [comp setDay:numberOfDays];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    return [calendar dateByAddingComponents:comp toDate:self options:0];
}

- (NSDate *)dateStartOfWeek {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setFirstWeekday:1]; //monday is first day
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:self];
    
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay: - ((([components weekday] - [gregorian firstWeekday])
                                      + 7 ) % 7)];
    NSDate *beginningOfWeek = [gregorian dateByAddingComponents:componentsToSubtract toDate:[NSDate date] options:0];
    
    NSDateComponents *componentsStripped = [gregorian components: (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                        fromDate: beginningOfWeek];
    
    //gestript
    beginningOfWeek = [gregorian dateFromComponents: componentsStripped];
    
    return beginningOfWeek;
}

- (NSDate *)dateEndOfWeek {
    return [[self dateStartOfWeek] addDay:6];
}

- (BOOL)isOnSameDayAsDate:(NSDate *)otherDate
                 withCalendar:(NSCalendar *)calendar
{
    NSCalendar *cal = calendar ? calendar : [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *selfFloored = [self floorDayWithCalendar:cal];
    NSDate *otherDateFloored = [otherDate floorDayWithCalendar:cal];
    
    NSDateComponents *separatingComponents = [cal components:(NSDayCalendarUnit
                                                              )
                                                    fromDate:otherDateFloored
                                                      toDate:selfFloored
                                                     options:0
                                              ];
    return (separatingComponents.day == 0);
    
}

- (NSDate *)floorDayWithCalendar:(NSCalendar *)calendar
{
    NSCalendar *cal = calendar ? calendar : [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [cal components:(NSEraCalendarUnit
                                               | NSYearCalendarUnit
                                               | NSMonthCalendarUnit
                                               | NSDayCalendarUnit
                                               )
                                     fromDate:self];
    
    NSDate *result = [cal dateFromComponents:comps];
    return result;
}

@end