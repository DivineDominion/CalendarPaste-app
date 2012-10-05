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
    
    // Assigns a displayOrder value to the new object
    ShiftTemplate *lastShift = [self shiftAtIndex:(index - 1)];
    NSUInteger oldMaxOrder   = [lastShift.displayOrder integerValue];
    shift.displayOrder       = [NSNumber numberWithInt:oldMaxOrder + 1];
    
    [self.shiftTemplateController saveManagedObjectContext];
    
    return index;
}

- (void)replaceShiftAtIndex:(NSUInteger)index withShift:(ShiftTemplate *)shift
{
    [self.shifts replaceObjectAtIndex:index withObject:shift];
}

- (void)removeShiftAtIndex:(NSUInteger)index
{
    ShiftTemplate *shift = [self shiftAtIndex:index];
    NSAssert(shift, @"Could retrieve shift before deletion");
    
    [self.shiftTemplateController deleteShift:shift];
    [self.shiftTemplateController saveManagedObjectContext];
    
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

- (void)persistOrder
{
    int i = 0;
    
    for (ShiftTemplate *shift in self.shifts)
    {
        shift.displayOrder = [NSNumber numberWithInt:i++];
    }
    
    [self.shiftTemplateController saveManagedObjectContext];
}


@end

