//
//  ShiftTemplateController.m
//  ShiftCal
//
//  Created by Christian Tietze on 03.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "ShiftTemplateController.h"

@implementation ShiftTemplateController

@synthesize shifts = _shifts;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.shifts = [[NSMutableArray alloc] init];
        
        [self loadModel];
    }
    
    return self;
}

- (void)dealloc
{
    [self.shifts release];
    
    [super dealloc];
}

- (void)loadModel
{
    ShiftTemplate *shift = nil;
    
    for (NSInteger i = 0; i < 5; i++)
    {
        shift = [[ShiftTemplate alloc] init];
        shift.title = [NSString stringWithFormat:@"Test %d", i];
        
        [self.shifts addObject:shift];
        
        [shift release];
    }
}

- (NSUInteger)countOfShifts
{
    return [self.shifts count];
}


- (NSUInteger)addShift:(ShiftTemplate *)shift
{
    NSUInteger index = [self countOfShifts]; // TODO find appropriate position
    
    [self.shifts insertObject:shift atIndex:index];
    
    return index;
}

- (void)replaceShiftAtIndex:(NSUInteger)index withShift:(ShiftTemplate *)shift
{
    [self.shifts replaceObjectAtIndex:index withObject:shift];
}

- (void)removeShiftAtIndex:(NSUInteger)index
{
    [self.shifts removeObjectAtIndex:index];
}

- (ShiftTemplate *)shiftAtIndex:(NSUInteger)index
{
    return [self.shifts objectAtIndex:index];
}

- (void)moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)to
{
    [self.shifts moveObjectFromIndex:from toIndex:to];
}

# pragma mark - class methods

+ (NSString *)durationTextForHours:(NSInteger)hours andMinutes:(NSInteger)minutes
{
    NSString *minutesString = @"";
    NSString *hoursString   = [NSString stringWithFormat:@"%dh", hours];
    
    if (minutes > 0) {
        minutesString = [NSString stringWithFormat:@" %dmin", minutes];
        
        if (hours == 0) {
            hoursString = @"";
        }
    }
    
    return [NSString stringWithFormat:@"%@%@", hoursString, minutesString];
}

@end
