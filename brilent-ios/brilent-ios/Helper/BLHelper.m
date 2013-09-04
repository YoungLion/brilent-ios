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

- (int)dayOfWeek
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"e"];
	return [[formatter stringFromDate:self] integerValue];
}

- (NSDate *)addDay:(NSInteger)numberOfDays
{
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    
    [comp setDay:numberOfDays];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    return [calendar dateByAddingComponents:comp toDate:self options:0];
}

- (NSDate *)startOfDayWithCalendar:(NSCalendar *)calendar
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

- (NSDate *)startDayOfWeekWithCalendar:(NSCalendar *)calendar
{
    NSCalendar *cal = calendar ? calendar : [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *result = [self startOfDayWithCalendar:cal];
    
    // if this is not a Sunday, go back one day
    NSDateComponents *negativeOneDay = [[NSDateComponents alloc] init];
    [negativeOneDay setDay:-1];
    
    NSDateComponents *comps = [cal components:NSWeekdayCalendarUnit fromDate:result];
    while ( comps.weekday > 1 )
    {
        result = [cal dateByAddingComponents:negativeOneDay
                                      toDate:result
                                     options:0];
        comps = [cal components:NSWeekdayCalendarUnit fromDate:result];
    }
    
    return result;
}

- (NSDate *)endDayOfWeekWithCalendar:(NSCalendar *)calendar
{
    return [[self startDayOfWeekWithCalendar:calendar] addDay:6];
}

- (BOOL)isOnSameDayAsDate:(NSDate *)otherDate
                 withCalendar:(NSCalendar *)calendar
{
    NSCalendar *cal = calendar ? calendar : [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *selfFloored = [self startOfDayWithCalendar:cal];
    NSDate *otherDateFloored = [otherDate startOfDayWithCalendar:cal];
    
    NSDateComponents *separatingComponents = [cal components:(NSDayCalendarUnit
                                                              )
                                                    fromDate:otherDateFloored
                                                      toDate:selfFloored
                                                     options:0
                                              ];
    return (separatingComponents.day == 0);
    
}

@end

@implementation UIView (BLHelper)

- (void)drawString:(NSString *)string
              font:(UIFont *)font
             color:(UIColor *)color
        centeredAt:(CGPoint)center
{
    UILabel *label = [UILabel new];
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:string];
    NSRange range = NSMakeRange(0, [string length]);
    
    [attrString addAttribute:NSFontAttributeName value:font range:range];
    [attrString addAttribute:NSForegroundColorAttributeName value:color range:range];
    
    label.attributedText = attrString;
    [label sizeToFit];
    label.center = center;
    [self addSubview:label];
}

- (void)drawCircleWithRadius:(CGFloat)r
                       color:(UIColor *)color
                  centeredAt:(CGPoint)center
{
    CGRect rect = CGRectMake(center.x - r, center.y - r, 2*r, 2*r);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetFillColorWithColor(ctx, [color CGColor]);
    CGContextFillPath(ctx);
}

@end

@implementation UIImage (BLHelper)

+ (UIImage *)circleImageWithDiameter:(CGFloat)diameter
                          edgeInsets:(UIEdgeInsets)edgeInsets
                               color:(UIColor *)color
                     backgroundColor:(UIColor *)backgroundColor
{
    CGRect imageRect = CGRectMake(0.0f, 0.0f, diameter + edgeInsets.left + edgeInsets.right, diameter + edgeInsets.top + edgeInsets.bottom);
    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, 0.0f);
    
    if ( backgroundColor )
    {
        [backgroundColor setFill];
        UIRectFill(imageRect);
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if ( color )
    {
        [color setFill];
        CGRect circleRect = CGRectMake(edgeInsets.left, edgeInsets.top, diameter, diameter);
        CGContextFillEllipseInRect(ctx, circleRect);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
@end

@implementation UIColor (BLHelper)
+ (UIColor *)lightlightGrayColor
{
    return [UIColor colorWithRed:227.f/255.f green:227.f/255.f blue:227.f/255.f alpha:1];
}
@end