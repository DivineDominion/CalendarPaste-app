//
//  ShiftAddDelegate.h
//  ShiftCal
//
//  Created by Christian Tietze on 16.08.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ShiftAddViewController;

@protocol ShiftAddDelegate <NSObject>

@required
/// shift == nil on cancel
- (void)shiftAddViewController:(ShiftAddViewController*)shiftAddViewController didAddShift:(id)shift;

@end
