//
//  DateIntervalTranslator.m
//  ShiftCal
//
//  Created by Christian Tietze on 18.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "DateIntervalTranslator.h"

@interface DateIntervalTranslator ()
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) NSDate *referenceDate;

//private methods
- (NSDateComponents *)dateComponentsForDays:(NSUInteger)days hours:(NSUInteger)hours minutes:(NSUInteger)mins;
@end

@implementation DateIntervalTranslator

@synthesize calendar = _calendar;
@synthesize referenceDate = _referenceDate;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.calendar = [NSCalendar currentCalendar];
        self.referenceDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:0.0];
    }
    
    return self;
}


# pragma mark - Private methods

- (NSDateComponents *)dateComponentsForDays:(NSUInteger)days hours:(NSUInteger)hours minutes:(NSUInteger)mins
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    [components setDay:days];
    [components setHour:hours];
    [components setMinute:mins];
    
    return components;
}

# pragma mark - Public methods

- (NSDateComponents *)dateComponentsForTimeInterval:(NSTimeInterval)interval
{
    static unsigned int kComponentFlags = NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;

    NSDateComponents *components = nil;
    NSDate *compDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:self.referenceDate];
    
    components = [self.calendar components:kComponentFlags fromDate:self.referenceDate toDate:compDate options:0];
    
    return components;
}

- (NSTimeInterval)timeIntervalForComponentDays:(NSUInteger)days hours:(NSUInteger)hours minutes:(NSUInteger)mins
{    
    NSTimeInterval interval;
    NSDateComponents *components = [self dateComponentsForDays:days hours:hours minutes:mins];
    
    NSDate *compDate = [self.calendar dateByAddingComponents:components
                                                      toDate:self.referenceDate
                                                     options:0];
    
    interval = [compDate timeIntervalSinceDate:self.referenceDate];
    
    return interval;
}

- (NSString *)humanReadableFormOf:(NSDateComponents *)dateComponents
{
    if ([dateComponents day] == 0 && [dateComponents hour] == 0 && [dateComponents minute] == 0)
    {
        return @"At time of event";
    }
    
    NSMutableArray *textParts = [[NSMutableArray alloc] initWithCapacity:3];
    NSString *text = nil;
    
    if ([dateComponents day] > 1 || [dateComponents day] < -1)
    {   
        [textParts addObject:[NSString stringWithFormat:@"%ld days", labs([dateComponents day])]];
    }
    else if ([dateComponents day])
    {
        [textParts addObject:@"1 day"];
    }
    
    if ([dateComponents hour] > 1 || [dateComponents hour] < -1)
    {
        [textParts addObject:[NSString stringWithFormat:@"%ld hours", labs([dateComponents hour])]];
    }
    else if ([dateComponents hour])
    {
        [textParts addObject:@"1 hour"];
    }
    
    if ([dateComponents minute] > 1 || [dateComponents minute] < -1)
    {
        [textParts addObject:[NSString stringWithFormat:@"%ld minutes", labs([dateComponents minute])]];
    }
    else if ([dateComponents minute])
    {
        [textParts addObject:@"1 minute"];
    }
    
    // Append suffix
    if ([dateComponents day] < 0 || [dateComponents hour] < 0 || [dateComponents minute] < 0)
    {
        [textParts addObject:@"before"];
    }
    
    text = [textParts componentsJoinedByString:@" "];
    
    return text;
}

- (NSString *)humanReadableFormOfInterval:(NSTimeInterval)interval
{
    return [self humanReadableFormOf:[self dateComponentsForTimeInterval:interval]];
}

- (NSString *)humanReadableFormOfHours:(NSUInteger)hours minutes:(NSUInteger)mins
{
    return [self humanReadableFormOfDays:0 hours:hours minutes:mins];
}

- (NSString *)humanReadableFormOfDays:(NSUInteger)days hours:(NSUInteger)hours minutes:(NSUInteger)mins
{
    return [self humanReadableFormOf:[self dateComponentsForDays:days hours:hours minutes:mins]];
}

@end
