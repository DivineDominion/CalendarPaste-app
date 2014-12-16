//
//  EventStoreWrapper.m
//  ShiftCal
//
//  Created by Christian Tietze on 15/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import "EventStoreWrapper.h"

@interface EventStoreWrapper ()
@end

@implementation EventStoreWrapper
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


#pragma mark -

- (void)requestEventAccessWithGrantedBlock:(void (^)())closure
{
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted)
        {
            closure();
        }
    }];
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
