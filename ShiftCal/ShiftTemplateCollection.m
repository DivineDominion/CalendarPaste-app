//
//  ShiftTemplateCollection.m
//  ShiftCal
//
//  Created by Christian Tietze on 03.10.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "ShiftTemplateCollection.h"

@implementation ShiftTemplateCollection

- (instancetype)init
{
    return [self initWithFallbackCalendarIdentifier:nil shiftTemplateController:nil];
}

- (instancetype)initWithShiftTemplateController:(ShiftTemplateController *)shiftTemplateController
{
    return [self initWithFallbackCalendarIdentifier:nil shiftTemplateController:shiftTemplateController];
}

- (instancetype)initWithFallbackCalendarIdentifier:(NSString *)fallbackCalendarIdentifier shiftTemplateController:(ShiftTemplateController *)shiftTemplateController
{
    NSAssert(shiftTemplateController, @"shiftTemplateController required");
    
    self = [super init];
    
    if (self)
    {
        self.shiftTemplateController = shiftTemplateController;
        
        NSMutableArray *mutableShifts = [[self.shiftTemplateController shifts] mutableCopy];
        self.shifts = mutableShifts;
        
        if (fallbackCalendarIdentifier)
        {
            [self resetInvalidCalendarsTo:fallbackCalendarIdentifier];
        }
    }
    
    return self;
}

# pragma mark - Collection alteration

- (NSUInteger)countOfShifts
{
    return [self.shifts count];
}

- (BOOL)isEmpty
{
    return [self countOfShifts] == 0;
}

- (NSInteger)addShiftWithAttributes:(NSDictionary *)shiftAttributes
{
    ShiftTemplate *shift = [self.shiftTemplateController importShiftByAttributeDictionary:shiftAttributes];
    
    NSUInteger index = [self countOfShifts];
    
    // TODO is display Order out of sync with index possible?
    if (index == 0)
    {
        [self.shifts addObject:shift];
        shift.displayOrder = @0;
    }
    else
    {
        [self.shifts insertObject:shift atIndex:index];
        
        // Assigns a displayOrder value to the new object
        ShiftTemplate *lastShift = [self.shifts lastObject];
        NSUInteger oldMaxOrder   = [lastShift.displayOrder integerValue];
        shift.displayOrder       = @(oldMaxOrder + 1);
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
    return self.shifts[index];
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
        shift.displayOrder = @(i++);
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

