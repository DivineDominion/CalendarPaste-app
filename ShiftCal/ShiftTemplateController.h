//
//  ShiftTemplateController.h
//  ShiftCal
//
//  Created by Christian Tietze on 03.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableArray+MoveArray.h"
#import "ShiftTemplate.h"

@interface ShiftTemplateController : NSObject
{
    NSMutableArray *_shifts;
}

@property (nonatomic, assign) NSMutableArray *shifts;

+ (NSString *)durationTextForHours:(NSInteger)hours andMinutes:(NSInteger)minutes;

- (NSUInteger)countOfShifts;
- (ShiftTemplate *)shiftAtIndex:(NSUInteger)index;
- (NSUInteger)addShift:(ShiftTemplate *)shift;
- (void)removeShiftAtIndex:(NSUInteger)index;
- (void)replaceShiftAtIndex:(NSUInteger)index withShift:(ShiftTemplate *)shift;
- (void)moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)to;
@end
