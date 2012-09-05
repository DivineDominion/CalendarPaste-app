//
//  ShiftTemplate.m
//  ShiftCal
//
//  Created by Christian Tietze on 25.07.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "ShiftTemplate.h"

@implementation ShiftTemplate

@synthesize title = _title;
@synthesize hours = _hours;
@synthesize minutes = _minutes;
@synthesize location = _location;
@synthesize url = _url;
@synthesize calendar = _calendar;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.title = nil;
        self.hours = 1;
        self.minutes = 0;
        
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        self.calendar = [eventStore defaultCalendarForNewEvents];
        [eventStore release];
        
        return self;
    }
    
    return nil;
}

- (void)setDurationHours:(NSInteger)hours andMinutes:(NSInteger)minutes
{
    self.hours = hours;
    self.minutes = minutes;
}

@end
