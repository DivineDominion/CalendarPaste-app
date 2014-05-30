//
//  ShiftTemplate.m
//  ShiftCal
//
//  Created by Christian Tietze on 29.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "ShiftTemplate.h"
#import "AppDelegate.h"

@interface ShiftTemplate ()

+ (NSString *)userDefaultCalendarIdentifier;

@end

@implementation ShiftTemplate

@dynamic displayOrder;
@dynamic title;
@dynamic displayTitle;
@dynamic location;
@dynamic durHours;
@dynamic durMinutes;
@dynamic allDay;
@dynamic lastPasteHours;
@dynamic lastPasteMins;
@dynamic calendarIdentifier;
@dynamic alarmFirstInterval;
@dynamic alarmSecondInterval;
@dynamic url;
@dynamic note;

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    ShiftTemplate *__unsafe_unretained weakSelf = self;
    // Adopt default template values manually to invoke setPrimitiveValue:forKey:
    // instead of setValue:forKey:
    [[ShiftTemplate defaultAttributes] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [weakSelf setPrimitiveValue:obj forKey:key];
    }];
}

- (void)dealloc
{
    [super dealloc];
}

- (EKEventStore *)eventStore
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.eventStore;
}

- (EKEvent *)event
{
    EKEvent* event = [EKEvent eventWithEventStore:self.eventStore];
    
    event.title = self.title;
    event.location = self.location;
    event.calendar = self.calendar;
    event.URL = [NSURL URLWithString:self.url];
    event.notes = self.note;
    
    if (self.alarmFirstInterval)
    {
        [event addAlarm:[EKAlarm alarmWithRelativeOffset:[self.alarmFirstInterval doubleValue]]];
        
        if (self.alarmSecondInterval)
        {
            [event addAlarm:[EKAlarm alarmWithRelativeOffset:[self.alarmSecondInterval doubleValue]]];
        }
    }
    
    return event;
}

- (EKCalendar *)calendar
{
    if (self.calendarIdentifier)
    {
        return [self.eventStore calendarWithIdentifier:self.calendarIdentifier];
    }
    
    return nil;
}

- (NSString *)calendarTitle
{
    return self.calendar.title;
}

- (BOOL)hasInvalidCalendar
{
    return ([self calendar] == nil);
}

- (NSTimeInterval)durationAsTimeInterval
{
    return 60 * ([self.durHours integerValue] * 60 + [self.durMinutes integerValue]);
}

- (void)setDurationHours:(NSUInteger)hours andMinutes:(NSUInteger)minutes
{
    self.durHours   = [NSNumber numberWithInteger:hours];
    self.durMinutes = [NSNumber numberWithInteger:minutes];
}

- (void)setLastPaste:(NSDate *)lastPaste
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:lastPaste];
    NSUInteger hour = [components hour];
    NSUInteger minute = [components minute];
    
    [self setLastPasteHour:hour andMinute:minute];
}
- (void)setLastPasteHour:(NSUInteger)hours andMinute:(NSUInteger)minutes
{
    self.lastPasteHours = [NSNumber numberWithInteger:hours];
    self.lastPasteMins  = [NSNumber numberWithInteger:minutes];
}

- (BOOL)wasAlreadyPasted
{
    return self.lastPasteHours != nil;
}

- (BOOL)isAllDay
{
    NSNumber *allDay = nil;
    
    [self willAccessValueForKey:@"allDay"];
    allDay = [self primitiveValueForKey:@"allDay"];
    [self didAccessValueForKey:@"allDay"];
    
    return (allDay != nil) ? [allDay boolValue] : NO;
}

- (NSString *)onScreenTitle
{
    NSString *displayTitle = self.displayTitle;
    
    if (displayTitle != nil && displayTitle.length > 0)
    {
        return displayTitle;
    }
    
    return self.title;
}

# pragma mark - Class-level utility methods

+ (NSString *)userDefaultCalendarIdentifier
{
    NSUserDefaults *prefs       = [NSUserDefaults standardUserDefaults];
    NSString *defaultCalendarId = [prefs objectForKey:PREFS_DEFAULT_CALENDAR_KEY];
    
    return defaultCalendarId;
}

+ (NSDictionary*)defaultAttributes
{
    return @{ @"calendarIdentifier" : [ShiftTemplate userDefaultCalendarIdentifier],
    @"durHours" : @1,
    @"durMinutes" : @0 };
}

@end
