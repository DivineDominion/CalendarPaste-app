//
//  EventStore.m
//  ShiftCal
//
//  Created by Christian Tietze on 15/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import "EventStore.h"

@interface EventStore ()
@end

@implementation EventStore
- (instancetype)init
{
    return [self initWithEventStore:nil];
}

- (instancetype)initWithEventStore:(EKEventStore *)eventStore
{
    NSParameterAssert(eventStore);
    
    self = [super init];
    if (self)
    {
        _eventStore = eventStore;
    }
    
    return self;
}

- (BOOL)isAuthorizedForCalendarAccess
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    return status == EKAuthorizationStatusAuthorized;
}

- (NSString *)defaultCalendarIdentifier
{
    return self.defaultCalendar.calendarIdentifier;
}

- (EKCalendar *)defaultCalendar
{
    return [self.eventStore defaultCalendarForNewEvents];
}
@end
