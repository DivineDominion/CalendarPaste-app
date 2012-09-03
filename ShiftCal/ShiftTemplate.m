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

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.title = nil;
        self.hours = 1;
        self.minutes = 0;
        
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
