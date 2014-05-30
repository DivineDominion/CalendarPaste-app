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

- (id)initWithAttributes:(NSDictionary *)attributes
{
    NSAssert(attributes, @"attributes required");
    
    self = [super init];
    if (self)
    {
        self.shiftAttributes = [[attributes mutableCopy] autorelease];
    }
    return self;
}

- (void)dealloc
{
    [_shiftAttributes release];
    
    [super dealloc];
}

- (NSString *)title
{
    NSString *title = [self.shiftAttributes objectForKey:@"title"];
    if ([title isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    return title;
}

- (void)setTitle:(NSString *)title
{
    [self.shiftAttributes setValue:[[title copy] autorelease] forKey:@"title"];
}

- (NSString *)displayTitle
{
    NSString *displayTitle = [self.shiftAttributes objectForKey:@"displayTitle"];
    if ([displayTitle isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    return displayTitle;
}

- (void)setDisplayTitle:(NSString *)displayTitle
{
    [self.shiftAttributes setValue:[[displayTitle copy] autorelease] forKey:@"displayTitle"];
}

- (NSString *)location
{
    NSString *location = [self.shiftAttributes objectForKey:@"location"];
    if ([location isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    return location;
}

- (void)setLocation:(NSString *)location
{
    [self.shiftAttributes setValue:[[location copy] autorelease] forKey:@"location"];
}

- (BOOL)isAllDay
{
    NSNumber *allDay = [self.shiftAttributes objectForKey:@"allDay"];
    if ([allDay isKindOfClass:[NSNull class]])
    {
        return NO;
    }
    return [allDay boolValue];
}

- (void)setAllDay:(BOOL)allDay
{
    [self.shiftAttributes setValue:[NSNumber numberWithBool:allDay] forKey:@"allDay"];
}

- (NSInteger)durationHours
{
    NSNumber *durHours = [self.shiftAttributes objectForKey:@"durHours"];
    if ([durHours isKindOfClass:[NSNull class]])
    {
        return 0;
    }
    return [durHours integerValue];
}

- (NSInteger)durationMinutes
{
    NSNumber *durMinutes = [self.shiftAttributes objectForKey:@"durMinutes"];
    if ([durMinutes isKindOfClass:[NSNull class]])
    {
        return 0;
    }
    return [durMinutes integerValue];
}

- (void)setDurationHours:(NSInteger)hours andMinutes:(NSInteger)minutes
{
    [self.shiftAttributes setValue:[NSNumber numberWithInteger:hours] forKey:@"durHours"];
    [self.shiftAttributes setValue:[NSNumber numberWithInteger:minutes] forKey:@"durMinutes"];
}

- (NSNumber *)alarmFirstInterval
{
    NSNumber *alarmFirstInterval = [self.shiftAttributes objectForKey:@"alarmFirstInterval"];
    if ([alarmFirstInterval isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    return alarmFirstInterval;
}

- (void)setAlarmFirstInterval:(NSNumber *)alarmFirstInterval
{
    [self.shiftAttributes setValue:[[alarmFirstInterval copy] autorelease] forKey:@"alarmFirstInterval"];
}

- (NSNumber *)alarmSecondInterval
{
    NSNumber *alarmSecondInterval = [self.shiftAttributes objectForKey:@"alarmSecondInterval"];
    if ([alarmSecondInterval isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    return alarmSecondInterval;
}

- (void)setAlarmSecondInterval:(NSNumber *)alarmSecondInterval
{
    [self.shiftAttributes setValue:[[alarmSecondInterval copy] autorelease] forKey:@"alarmSecondInterval"];
}

- (BOOL)hasFirstAlarm
{
    return ([self alarmFirstInterval] != nil);
}

- (NSString *)calendarIdentifier
{
    NSString *calendarIdentifier = [self.shiftAttributes objectForKey:@"calendarIdentifier"];
    
    if ([calendarIdentifier isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    
    return calendarIdentifier;
}

- (void)setCalendarIdentifier:(NSString *)calendarIdentifier
{
    [self.shiftAttributes setValue:[[calendarIdentifier copy] autorelease] forKey:@"calendarIdentifier"];
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
    NSString *url = [self.shiftAttributes objectForKey:@"url"];
    if ([url isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    return url;
}

- (void)setUrl:(NSString *)url
{
    [self.shiftAttributes setValue:[[url copy] autorelease] forKey:@"url"];
}

- (NSString *)note
{
    NSString *note = [self.shiftAttributes objectForKey:@"note"];
    if ([note isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    return note;
}

- (void)setNote:(NSString *)note
{
    [self.shiftAttributes setValue:[[note copy] autorelease] forKey:@"note"];
}

@end