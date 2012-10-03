//
//  ShiftTemplateCollection.h
//  ShiftCal
//
//  Created by Christian Tietze on 03.10.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShiftTemplateController.h"

@interface ShiftTemplateCollection : NSObject
{
    ShiftTemplateController *_shiftTemplateController;
    
    NSMutableArray *_shifts;
}

@property (nonatomic, retain) ShiftTemplateController *shiftTemplateController;
@property (nonatomic, retain) NSMutableArray *shifts;

- (NSUInteger)countOfShifts;
- (ShiftTemplate *)shiftAtIndex:(NSUInteger)index;
- (NSUInteger)importShift:(ShiftTemplate *)tempShift;
- (void)removeShiftAtIndex:(NSUInteger)index;
- (void)replaceShiftAtIndex:(NSUInteger)index withShift:(ShiftTemplate *)shift;
- (void)moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)to;
@end

