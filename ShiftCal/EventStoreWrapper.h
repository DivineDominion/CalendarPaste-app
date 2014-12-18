//
//  EventStoreWrapper.h
//  ShiftCal
//
//  Created by Christian Tietze on 15/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface EventStoreWrapper : NSObject
@property (nonatomic, strong, readonly) EKEventStore *eventStore;

- (instancetype)initWithEventStore:(EKEventStore *)eventStore NS_DESIGNATED_INITIALIZER;

- (void)requestEventAccessWithGrantedBlock:(void (^)())closure;
- (BOOL)isAuthorizedForCalendarAccess;

- (EKCalendar *)calendarWithIdentifier:(NSString *)identifier;
- (NSArray *)calendars;
- (EKCalendar *)defaultCalendar;
- (NSString *)defaultCalendarIdentifier;
@end
