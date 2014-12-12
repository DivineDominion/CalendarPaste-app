//
//  ShiftTemplate.h
//  ShiftCal
//
//  Created by Christian Tietze on 29.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <EventKit/EventKit.h>

@interface ShiftTemplate : NSManagedObject

@property (nonatomic, strong) NSNumber *displayOrder;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *displayTitle;
@property (nonatomic, strong) NSString *location;

@property (nonatomic, strong) NSNumber *durHours;
@property (nonatomic, strong) NSNumber *durMinutes;

@property (nonatomic, strong) NSNumber *allDay;
@property (nonatomic, strong) NSNumber *lastPasteHours;
@property (nonatomic, strong) NSNumber *lastPasteMins;

@property (nonatomic, strong) NSString *calendarIdentifier;

@property (nonatomic, strong) NSNumber *alarmFirstInterval;
@property (nonatomic, strong) NSNumber *alarmSecondInterval;

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *note;

@property (weak, nonatomic, readonly) EKEventStore *eventStore;
@property (weak, nonatomic, readonly) EKCalendar *calendar;

- (void)setDurationHours:(NSUInteger)hours andMinutes:(NSUInteger)minutes;
- (void)setLastPaste:(NSDate *)lastPaste;
- (void)setLastPasteHour:(NSUInteger)hours andMinute:(NSUInteger)minutes;
- (BOOL)wasAlreadyPasted;
- (BOOL)isAllDay;
- (NSString *)onScreenTitle;

- (EKEvent *)event;
- (NSString *)calendarTitle;
- (BOOL)hasInvalidCalendar;
- (NSTimeInterval)durationAsTimeInterval;

+ (NSDictionary*)defaultAttributes;

@end
