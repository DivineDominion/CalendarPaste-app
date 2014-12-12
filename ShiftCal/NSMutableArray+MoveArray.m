//
//  NSMutableArray+MoveArray.m
//  ShiftCal
//
//  Created by Christian Tietze on 27.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "NSMutableArray+MoveArray.h"

@implementation NSMutableArray (MoveArray)
- (void)moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)to
{
    if (to != from) {
        id obj = [self objectAtIndex:from];
        [self removeObjectAtIndex:from];
        if (to >= [self count]) {
            [self addObject:obj];
        } else {
            [self insertObject:obj atIndex:to];
        }
    }
}
@end