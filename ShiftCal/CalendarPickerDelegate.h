//
//  CalendarPickerDelegate.h
//  ShiftCal
//
//  Created by Christian Tietze on 05.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CalendarPickerController;

@protocol CalendarPickerDelegate <NSObject>

@required
// calendar == nil on cancel
- (void)calendarPicker:(CalendarPickerController *)calendarPicker didSelectCalendarWithIdentifier:(NSString *)calendarIdentifier;
@end
