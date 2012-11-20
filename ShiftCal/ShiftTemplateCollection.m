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
    return [self initWithFallbackCalendarIdentifier:nil];
}

- (id)initWithFallbackCalendarIdentifier:(NSString *)fallbackCalendarIdentifier
{
    self = [super init];
    
    if (self)
    {
        self.shiftTemplateController = [[[ShiftTemplateController alloc] init] autorelease];
        
        NSMutableArray *mutableShifts = [[self.shiftTemplateController shifts] mutableCopy];
        self.shifts = mutableShifts;
        [mutableShifts release];
        
        if (fallbackCalendarIdentifier)
        {
            [self resetInvalidCalendarsTo:fallbackCalendarIdentifier];
        }
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

- (NSInteger)addShiftWithAttributes:(NSDictionary *)shiftAttributes
{
    ShiftTemplate *shift = [self.shiftTemplateController importShiftByAttributeDictionary:shiftAttributes];
    
    NSUInteger index = [self countOfShifts];
    
    // TODO is display Order out of sync with index possible?
    if (index == 0)
    {
        [self.shifts addObject:shift];
        shift.displayOrder = [NSNumber numberWithInt:0];
    }
    else
    {
        [self.shifts insertObject:shift atIndex:index];
        
        // Assigns a displayOrder value to the new object
        ShiftTemplate *lastShift = [self.shifts lastObject];
        NSUInteger oldMaxOrder   = [lastShift.displayOrder integerValue];
        shift.displayOrder       = [NSNumber numberWithInt:oldMaxOrder + 1];
    }
    
    
    [self.shiftTemplateController saveManagedObjectContext];
    
    return index;
}

- (void)updateShiftAtIndex:(NSUInteger)index withAttributes:(NSDictionary *)shiftAttributes
{
    ShiftTemplate *shift = [self shiftAtIndex:index];
    
    [shift setValuesForKeysWithDictionary:shiftAttributes];
    
    [self.shiftTemplateController saveManagedObjectContext];
}

- (void)removeShiftAtIndex:(NSUInteger)index
{
    ShiftTemplate *shift = [self shiftAtIndex:index];
    
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

#pragma mark Collection validation

- (void)resetInvalidCalendarsTo:(NSString *)defaultCalendarIdentifier
{
    [self resetInvalidCalendarsTo:defaultCalendarIdentifier onChanges:nil];
}

- (void)resetInvalidCalendarsTo:(NSString *)defaultCalendarIdentifier onChanges:(void (^)(void))changeBlock
{
    __block BOOL changesMade = NO;
    
    [self.shifts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ShiftTemplate *shift = (ShiftTemplate *)obj;
        
        if ([shift hasInvalidCalendar])
        {
            shift.calendarIdentifier = defaultCalendarIdentifier;
            
            changesMade = YES;
        }
    }];
    
    if (changesMade && changeBlock != nil)
    {
        changeBlock();
    }
}

@end

