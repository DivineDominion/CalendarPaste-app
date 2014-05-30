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

@property (nonatomic, retain) NSNumber *displayOrder;

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *displayTitle;
@property (nonatomic, retain) NSString *location;

@property (nonatomic, retain) NSNumber *durHours;
@property (nonatomic, retain) NSNumber *durMinutes;

@property (nonatomic, retain) NSNumber *allDay;
@property (nonatomic, retain) NSNumber *lastPasteHours;
@property (nonatomic, retain) NSNumber *lastPasteMins;

@property (nonatomic, retain) NSString *calendarIdentifier;

@property (nonatomic, retain) NSNumber *alarmFirstInterval;
@property (nonatomic, retain) NSNumber *alarmSecondInterval;

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *note;

@property (nonatomic, readonly) EKEventStore *eventStore;
@property (nonatomic, readonly) EKCalendar *calendar;

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
