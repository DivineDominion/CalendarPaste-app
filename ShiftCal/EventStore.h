//
//  EventStore.h
//  ShiftCal
//
//  Created by Christian Tietze on 15/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface EventStore : NSObject
@property (nonatomic, strong, readonly) EKEventStore *eventStore;

- (instancetype)initWithEventStore:(EKEventStore *)eventStore NS_DESIGNATED_INITIALIZER;

- (BOOL)isAuthorizedForCalendarAccess;
- (EKCalendar *)defaultCalendar;
- (NSString *)defaultCalendarIdentifier;
@end
