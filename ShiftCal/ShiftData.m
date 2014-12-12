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

- (instancetype)init
{
    return [self initWithAttributes:nil];
}

- (instancetype)initWithAttributes:(NSDictionary *)attributes
{
    NSParameterAssert(attributes);
    
    self = [super init];
    if (self)
    {
        self.shiftAttributes = [attributes mutableCopy];
    }
    return self;
}

- (id)valueOrNilForKey:(NSString *)key
{
    id value = self.shiftAttributes[key];
    
    if ([value isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    
    return value;
}

- (id)copyOrNull:(id)original
{
    if (original == nil)
    {
        return [NSNull null];
    }
    
    return [original copy];
}


#pragma mark -

- (NSString *)title
{
    return [self valueOrNilForKey:@"title"];
}

- (void)setTitle:(NSString *)title
{
    id value = [self copyOrNull:title];
    [self.shiftAttributes setValue:value forKey:@"title"];
}

- (NSString *)displayTitle
{
    return [self valueOrNilForKey:@"displayTitle"];
}

- (void)setDisplayTitle:(NSString *)displayTitle
{
    id value = [self copyOrNull:displayTitle];
    [self.shiftAttributes setValue:value forKey:@"displayTitle"];
}

- (NSString *)location
{
    return [self valueOrNilForKey:@"location"];
}

- (void)setLocation:(NSString *)location
{
    id value = [self copyOrNull:location];
    [self.shiftAttributes setValue:value forKey:@"location"];
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
    return [self valueOrNilForKey:@"alarmFirstInterval"];
}

- (void)setAlarmFirstInterval:(NSNumber *)alarmFirstInterval
{
    id value = [self copyOrNull:alarmFirstInterval];
    [self.shiftAttributes setValue:value forKey:@"alarmFirstInterval"];
}

- (NSNumber *)alarmSecondInterval
{
    return [self valueOrNilForKey:@"alarmSecondInterval"];
}

- (void)setAlarmSecondInterval:(NSNumber *)alarmSecondInterval
{
    id value = [self copyOrNull:alarmSecondInterval];
    [self.shiftAttributes setValue:value forKey:@"alarmSecondInterval"];
}

- (BOOL)hasFirstAlarm
{
    return ([self alarmFirstInterval] != nil);
}

- (NSString *)calendarIdentifier
{
    return [self valueOrNilForKey:@"calendarIdentifier"];
}

- (void)setCalendarIdentifier:(NSString *)calendarIdentifier
{
    id value = [self copyOrNull:calendarIdentifier];
    [self.shiftAttributes setValue:value forKey:@"calendarIdentifier"];
}

- (BOOL)hasInvalidCalendar
{
    return ([self calendar] == nil);
}

- (EKEventStore *)eventStore
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
    return [self valueOrNilForKey:@"url"];
}

- (void)setUrl:(NSString *)url
{
    id value = [self copyOrNull:url];
    [self.shiftAttributes setValue:value forKey:@"url"];
}

- (NSString *)note
{
    return [self valueOrNilForKey:@"note"];
}

- (void)setNote:(NSString *)note
{
    id value = [self copyOrNull:note];
    [self.shiftAttributes setValue:value forKey:@"note"];
}

@end