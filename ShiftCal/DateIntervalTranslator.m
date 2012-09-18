//
//  DateIntervalTranslator.m
//  ShiftCal
//
//  Created by Christian Tietze on 18.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "DateIntervalTranslator.h"

@interface DateIntervalTranslator ()
{
    // private instance variables
    NSCalendar *_calendar;
    NSDate *_referenceDate;
}

// private properties
@property (nonatomic, retain) NSCalendar *calendar;
@property (nonatomic, retain) NSDate *referenceDate;
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
        self.referenceDate = [[NSDate alloc] initWithTimeIntervalSince1970:0.0];
    }
    
    return self;
}

- (NSDateComponents *)dateComponentsForTimeInterval:(NSTimeInterval)interval
{
    NSDateComponents *components = nil;
    static unsigned int kComponentFlags = NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    
    NSDate *compDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:self.referenceDate];
    
    components = [self.calendar components:kComponentFlags fromDate:self.referenceDate toDate:compDate options:0];
    
    return components;
}

- (NSTimeInterval)timeIntervalForComponentDays:(NSUInteger)days hours:(NSUInteger)hours minutes:(NSUInteger)mins
{    
    NSTimeInterval interval;
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    [components setDay:days];
    [components setHour:hours];
    [components setMinute:mins];
    
    NSDate *compDate = [self.calendar dateByAddingComponents:components
                                                      toDate:self.referenceDate
                                                     options:0];
    
    interval = [compDate timeIntervalSinceDate:self.referenceDate];
    
    [components release];
    
    return interval;
}

- (NSString *)humanReadableFormOf:(NSDateComponents *)dateComponents
{
    NSMutableArray *textParts = [[NSMutableArray alloc] initWithCapacity:3];
    NSString *text = nil;
    
    if ([dateComponents day] > 1)
    {   
        [textParts addObject:[NSString stringWithFormat:@"%d days", [dateComponents day]]];
    }
    else if ([dateComponents day])
    {
        [textParts addObject:@"1 day "];
    }
    
    if ([dateComponents hour] > 1)
    {
        [textParts addObject:[NSString stringWithFormat:@"%d hours", [dateComponents hour]]];
    }
    else if ([dateComponents hour])
    {
        [textParts addObject:@"1 hour"];
    }
    
    if ([dateComponents minute] > 1)
    {
        [textParts addObject:[NSString stringWithFormat:@"%d minutes", [dateComponents minute]]];
    }
    else if ([dateComponents minute])
    {
        [textParts addObject:@"1 minute"];
    }
    
    text = [textParts componentsJoinedByString:@" "];
    
    [textParts release];
    
    return text;
}

@end
