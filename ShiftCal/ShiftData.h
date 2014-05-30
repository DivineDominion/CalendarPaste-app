//
//  ShiftData.h
//  ShiftCal
//
//  Created by Christian Tietze on 02.03.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShiftData : NSObject
{
    NSMutableDictionary *_shiftAttributes;
}

@property (nonatomic, retain) NSMutableDictionary *shiftAttributes;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *displayTitle;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, assign, getter = isAllDay) BOOL allDay;
@property (nonatomic, retain) NSNumber *alarmFirstInterval;
@property (nonatomic, retain) NSNumber *alarmSecondInterval;
@property (nonatomic, copy) NSString *calendarIdentifier;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *note;

- (id)initWithAttributes:(NSDictionary *)attributes;

- (NSInteger)durationHours;
- (NSInteger)durationMinutes;
- (void)setDurationHours:(NSInteger)hours andMinutes:(NSInteger)minutes;
- (NSString *)calendarTitle;
- (BOOL)hasInvalidCalendar;
- (BOOL)hasFirstAlarm;
@end
