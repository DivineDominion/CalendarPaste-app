//
//  CalendarProvider.h
//  ShiftCal
//
//  Created by Christian Tietze on 15/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

extern NSString * const SCStoreChangedNotification;
extern NSString * const kKeyNotificationDefaultCalendar;
extern NSString * const kKeyPrefsDefaultCalendar;

@class EventStore;

@interface CalendarProvider : NSObject
@property (nonatomic, strong, readonly) EKEventStore *eventStore;
@property (nonatomic, strong, readonly) EKCalendar *defaultUserCalendar;

+ (instancetype)sharedInstance;
+ (void)setSharedInstance:(CalendarProvider *)instance;
+ (void)resetSharedInstance;

- (instancetype)initWithEventStore:(EventStore *)eventStore NS_DESIGNATED_INITIALIZER;

- (void)eventStoreChanged:(NSNotification *)notification;
- (void)registerPreferenceDefaults;
@end
