//
//  DateIntervalTranslator.h
//  ShiftCal
//
//  Created by Christian Tietze on 18.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateIntervalTranslator : NSObject
- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (NSDateComponents *)dateComponentsForTimeInterval:(NSTimeInterval)interval;
- (NSTimeInterval)timeIntervalForComponentDays:(NSUInteger)days hours:(NSUInteger)hours minutes:(NSUInteger)mins;
- (NSString *)humanReadableFormOf:(NSDateComponents *)dateComponents;
- (NSString *)humanReadableFormOfInterval:(NSTimeInterval)interval;
- (NSString *)humanReadableFormOfHours:(NSUInteger)hours minutes:(NSUInteger)mins;
- (NSString *)humanReadableFormOfDays:(NSUInteger)days hours:(NSUInteger)hours minutes:(NSUInteger)mins;
@end
