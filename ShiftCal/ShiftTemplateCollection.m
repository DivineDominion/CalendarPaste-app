//
//  ShiftTemplateCollection.m
//  ShiftCal
//
//  Created by Christian Tietze on 03.10.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "ShiftTemplateCollection.h"

@implementation ShiftTemplateCollection
@synthesize shiftTemplateController = _shiftTemplateController;
@synthesize shifts = _shifts;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.shiftTemplateController = [[ShiftTemplateController alloc] init];
        
        NSMutableArray *mutableShifts = [[self.shiftTemplateController shifts] mutableCopy];
        self.shifts = mutableShifts;
        [mutableShifts release];
    }
    
    return self;
}

- (void)dealloc
{
    [_shifts release];
    [_shiftTemplateController release];
    
    [super dealloc];
}

# pragma mark - Collection alteration

- (NSUInteger)countOfShifts
{
    return [self.shifts count];
}

- (NSUInteger)importShift:(ShiftTemplate *)tempShift
{
    ShiftTemplate *shift = [self.shiftTemplateController importShift:tempShift];
    
    NSUInteger index = [self countOfShifts];
    
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


@end

