//
//  ShiftTemplate.m
//  ShiftCal
//
//  Created by Christian Tietze on 25.07.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "ShiftTemplate.h"

@interface ShiftTemplate ()

//private methods
- (EKCalendar *)userDefaultCalendar;

@end

@implementation ShiftTemplate

@synthesize title = _title;
@synthesize hours = _hours;
@synthesize minutes = _minutes;
@synthesize location = _location;
@synthesize url = _url;
@synthesize calendar = _calendar;
@synthesize alarm = _alarm;
@synthesize secondAlarm = _secondAlarm;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.title = nil;
        self.hours = 1;
        self.minutes = 0;
                
        self.calendar = [self userDefaultCalendar];
        
        return self;
    }
    
    return nil;
}

- (void)dealloc
{
    [self.calendar release];
    [self.alarm release];
    [self.secondAlarm release];
    
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    ShiftTemplate *copy = [[ShiftTemplate alloc] init];
    
    copy.title = [self.title copy];
    copy.hours = self.hours;
    copy.minutes = self.minutes;
    copy.location = [self.location copy];
    copy.url = [self.url copy];
    
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    copy.calendar = [eventStore calendarWithIdentifier:self.calendar.calendarIdentifier];
    [eventStore release];
    
    copy.alarm = [self.alarm copy];
    copy.secondAlarm = [self.secondAlarm copy];
    
    return copy;
}

- (EKCalendar *)userDefaultCalendar
{
    EKCalendar *defaultCalendar = nil;
    
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    NSUserDefaults *prefs    = [NSUserDefaults standardUserDefaults];
    
    NSString *defaultCalendarId = [prefs objectForKey:PREFS_DEFAULT_CALENDAR_KEY];
    defaultCalendar             = [eventStore calendarWithIdentifier:defaultCalendarId];
    
    [eventStore release];
    
    return defaultCalendar;
}

- (void)setDurationHours:(NSInteger)hours andMinutes:(NSInteger)minutes
{
    self.hours = hours;
    self.minutes = minutes;
}

@end
