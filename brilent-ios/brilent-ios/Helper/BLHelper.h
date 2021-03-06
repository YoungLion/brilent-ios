//
//  BLHelper.h
//  brilent-ios
//
//  Created by Yong Lin on 8/27/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface BLHelper : NSObject

@end

void setNetworkActivityIndicator(BOOL active);

@interface NSDictionary (BLHelper)
- (NSString *)stringForRequestBody;
@end

@interface NSObject (BLHelper)
- (NSString *)encodedStringForRequestBody;
@end

@interface NSString (BLHelper)
- (NSString *)encodedStringForRequestBody;
- (NSString*)signatureWithSecret:(NSString*)secret;
@end

@interface NSData (BLHelper)
- (NSString*)hexString;
@end

@interface NSDate (BLHelper)
- (int)year;
- (int)month;
- (int)day;
- (int)dayOfWeek;
- (NSDate *)addDay:(NSInteger)numberOfDays;
- (NSDate *)startOfMinuteWithCalendar:(NSCalendar *)calendar;
- (NSDate *)startOfHourWithCalendar:(NSCalendar *)calendar;
- (NSDate *)startOfDayWithCalendar:(NSCalendar *)calendar;
- (NSDate *)startDayOfWeekWithCalendar:(NSCalendar *)calendar;
- (NSDate *)endDayOfWeekWithCalendar:(NSCalendar *)calendar;
- (BOOL)isOnSameDayAsDate:(NSDate *)otherDate
             withCalendar:(NSCalendar *)calendar;
@end

@interface UIView (BLHelper)
- (void)drawString:(NSString *)string
              font:(UIFont *)font
             color:(UIColor *)color
        centeredAt:(CGPoint)center;
- (void)drawCircleWithRadius:(CGFloat)r
                       color:(UIColor *)color
                  centeredAt:(CGPoint)center;
- (void)pulseAnimationforKey:(NSString *)key repeatCount:(int)repeatCount withDuration:(CFTimeInterval)duration toValue:(float)toValue;
@end

@interface UIImage (BLHelper)
+ (UIImage *)circleImageWithDiameter:(CGFloat)diameter
                          edgeInsets:(UIEdgeInsets)edgeInsets
                               color:(UIColor *)color
                     backgroundColor:(UIColor *)backgroundColor;
@end

@interface UIColor (BLHelper)
+ (UIColor *)lightlightGrayColor;
@end
