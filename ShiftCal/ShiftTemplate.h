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
@property (nonatomic, retain) NSString *location;

@property (nonatomic, retain) NSNumber *durHours;
@property (nonatomic, retain) NSNumber *durMinutes;

@property (nonatomic, retain) NSString *calendarIdentifier;

@property (nonatomic, retain) NSNumber *alarmFirstInterval;
@property (nonatomic, retain) NSNumber *alarmSecondInterval;

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *note;

@property (nonatomic, readonly) EKCalendar *calendar;

- (void)setDurationHours:(NSUInteger)hours andMinutes:(NSUInteger)minutes;
- (NSString *)calendarTitle;

@end
