//
//  UserCalendarProvider.h
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

@class EventStoreWrapper;

@interface UserCalendarProvider : NSObject
@property (nonatomic, strong, readonly) EventStoreWrapper *eventStoreWrapper;
@property (nonatomic, strong, readonly) EKEventStore *eventStore;
@property (nonatomic, strong, readonly) EKCalendar *userDefaultCalendar;
@property (nonatomic, copy, readwrite) NSString *userDefaultCalendarIdentifier;

+ (instancetype)sharedInstance;
+ (void)setSharedInstance:(UserCalendarProvider *)instance;
+ (void)resetSharedInstance;

+ (instancetype)calendarProviderWithEventStoreWrapper:(EventStoreWrapper *)eventStoreWrapper;
- (instancetype)initWithEventStoreWrapper:(EventStoreWrapper *)eventStoreWrapper NS_DESIGNATED_INITIALIZER;

- (void)eventStoreChanged:(NSNotification *)notification;
- (void)registerPreferenceDefaults;
@end
