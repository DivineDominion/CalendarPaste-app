//
//  ShiftData.h
//  ShiftCal
//
//  Created by Christian Tietze on 02.03.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShiftData : NSObject
@property (nonatomic, strong) NSMutableDictionary *shiftAttributes;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *displayTitle;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, assign, getter = isAllDay) BOOL allDay;
@property (nonatomic, strong) NSNumber *alarmFirstInterval;
@property (nonatomic, strong) NSNumber *alarmSecondInterval;
@property (nonatomic, copy) NSString *calendarIdentifier;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *note;

@property (nonatomic, readonly) NSInteger durationHours;
@property (nonatomic, readonly) NSInteger durationMinutes;

@property (nonatomic, readonly, copy) NSString *calendarTitle;
@property (nonatomic, readonly) BOOL hasInvalidCalendar;
@property (nonatomic, readonly) BOOL hasFirstAlarm;

- (instancetype)initWithAttributes:(NSDictionary *)attributes NS_DESIGNATED_INITIALIZER;

- (void)setDurationHours:(NSInteger)hours andMinutes:(NSInteger)minutes;
@end
