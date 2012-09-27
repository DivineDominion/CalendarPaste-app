//
//  NSMutableArray+MoveArray.h
//  ShiftCal
//
//  Created by Christian Tietze on 27.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>

// via http://www.icab.de/blog/2009/11/15/moving-objects-within-an-nsmutablearray/
@interface NSMutableArray (MoveArray)
- (void)moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)to;
@end
