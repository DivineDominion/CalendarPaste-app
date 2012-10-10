//
//  ShiftTemplate.m
//  ShiftCal
//
//  Created by Christian Tietze on 29.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "ShiftTemplate.h"

@interface ShiftTemplate ()
{
    // private instance variables
    EKEventStore *_eventStore;
}

// private properties
@property (nonatomic, readonly) EKEventStore *eventStore;

// private methods
+ (NSString *)userDefaultCalendarIdentifier;
@end

@implementation ShiftTemplate

@dynamic displayOrder;
@dynamic title;
@dynamic location;
@dynamic durHours;
@dynamic durMinutes;
@dynamic calendarIdentifier;
@dynamic alarmFirstInterval;
@dynamic alarmSecondInterval;
@dynamic url;
@dynamic note;

@synthesize eventStore = _eventStore;

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    // Adopt default template values manually to invoke setPrimitiveValue:forKey:
    // instead of setValue:forKey:
    [[ShiftTemplate defaultAttributes] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setPrimitiveValue:obj forKey:key];
    }];
}

- (void)dealloc
{
    [_eventStore release];
    
    [super dealloc];
}

- (EKEventStore *)eventStore
{
    if (_eventStore)
    {
        return _eventStore;
    }
    
    _eventStore = [[EKEventStore alloc] init];
    
    return _eventStore;
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

- (NSTimeInterval)durationAsTimeInterval
{
    return 60 * ([self.durHours integerValue] * 60 + [self.durMinutes integerValue]);
}

- (void)setDurationHours:(NSUInteger)hours andMinutes:(NSUInteger)minutes
{
    self.durHours   = [NSNumber numberWithInteger:hours];
    self.durMinutes = [NSNumber numberWithInteger:minutes];
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
