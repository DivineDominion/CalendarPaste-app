//
//  ShiftData.m
//  ShiftCal
//
//  Created by Christian Tietze on 02.03.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import "ShiftData.h"
#import <EventKit/EventKit.h>
#import "AppDelegate.h"

@implementation ShiftData
@synthesize shiftAttributes = _shiftAttributes;

- (instancetype)initWithAttributes:(NSDictionary *)attributes
{
    NSAssert(attributes, @"attributes required");
    
    self = [super init];
    if (self)
    {
        self.shiftAttributes = [attributes mutableCopy];
    }
    return self;
}


- (NSString *)title
{
    NSString *title = self.shiftAttributes[@"title"];
    if ([title isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    return title;
}

- (void)setTitle:(NSString *)title
{
    [self.shiftAttributes setValue:[title copy] forKey:@"title"];
}

- (NSString *)displayTitle
{
    NSString *displayTitle = self.shiftAttributes[@"displayTitle"];
    if ([displayTitle isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    return displayTitle;
}

- (void)setDisplayTitle:(NSString *)displayTitle
{
    [self.shiftAttributes setValue:[displayTitle copy] forKey:@"displayTitle"];
}

- (NSString *)location
{
    NSString *location = self.shiftAttributes[@"location"];
    if ([location isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    return location;
}

- (void)setLocation:(NSString *)location
{
    [self.shiftAttributes setValue:[location copy] forKey:@"location"];
}

- (BOOL)isAllDay
{
    NSNumber *allDay = self.shiftAttributes[@"allDay"];
    if ([allDay isKindOfClass:[NSNull class]])
    {
        return NO;
    }
    return [allDay boolValue];
}

- (void)setAllDay:(BOOL)allDay
{
    [self.shiftAttributes setValue:@(allDay) forKey:@"allDay"];
}

- (NSInteger)durationHours
{
    NSNumber *durHours = self.shiftAttributes[@"durHours"];
    if ([durHours isKindOfClass:[NSNull class]])
    {
        return 0;
    }
    return [durHours integerValue];
}

- (NSInteger)durationMinutes
{
    NSNumber *durMinutes = self.shiftAttributes[@"durMinutes"];
    if ([durMinutes isKindOfClass:[NSNull class]])
    {
        return 0;
    }
    return [durMinutes integerValue];
}

- (void)setDurationHours:(NSInteger)hours andMinutes:(NSInteger)minutes
{
    [self.shiftAttributes setValue:@(hours) forKey:@"durHours"];
    [self.shiftAttributes setValue:@(minutes) forKey:@"durMinutes"];
}

- (NSNumber *)alarmFirstInterval
{
    NSNumber *alarmFirstInterval = self.shiftAttributes[@"alarmFirstInterval"];
    if ([alarmFirstInterval isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    return alarmFirstInterval;
}

- (void)setAlarmFirstInterval:(NSNumber *)alarmFirstInterval
{
    [self.shiftAttributes setValue:[alarmFirstInterval copy] forKey:@"alarmFirstInterval"];
}

- (NSNumber *)alarmSecondInterval
{
    NSNumber *alarmSecondInterval = self.shiftAttributes[@"alarmSecondInterval"];
    if ([alarmSecondInterval isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    return alarmSecondInterval;
}

- (void)setAlarmSecondInterval:(NSNumber *)alarmSecondInterval
{
    [self.shiftAttributes setValue:[alarmSecondInterval copy] forKey:@"alarmSecondInterval"];
}

- (BOOL)hasFirstAlarm
{
    return ([self alarmFirstInterval] != nil);
}

- (NSString *)calendarIdentifier
{
    NSString *calendarIdentifier = self.shiftAttributes[@"calendarIdentifier"];
    
    if ([calendarIdentifier isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    
    return calendarIdentifier;
}

- (void)setCalendarIdentifier:(NSString *)calendarIdentifier
{
    [self.shiftAttributes setValue:[calendarIdentifier copy] forKey:@"calendarIdentifier"];
}

- (BOOL)hasInvalidCalendar
{
    return ([self calendar] == nil);
}

- (EKEventStore *)eventStore
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.eventStore;
}

- (EKCalendar *)calendar
{
    NSString *calendarIdentifier = self.calendarIdentifier;
    
    if (calendarIdentifier)
    {
        return [self.eventStore calendarWithIdentifier:calendarIdentifier];
    }
    
    return nil;
}

- (NSString *)calendarTitle
{
    return self.calendar.title;
}

- (NSString *)url
{
    NSString *url = self.shiftAttributes[@"url"];
    if ([url isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    return url;
}

- (void)setUrl:(NSString *)url
{
    [self.shiftAttributes setValue:[url copy] forKey:@"url"];
}

- (NSString *)note
{
    NSString *note = self.shiftAttributes[@"note"];
    if ([note isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    return note;
}

- (void)setNote:(NSString *)note
{
    [self.shiftAttributes setValue:[note copy] forKey:@"note"];
}

@end