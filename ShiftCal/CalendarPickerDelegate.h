//
//  CalendarPickerDelegate.h
//  ShiftCal
//
//  Created by Christian Tietze on 05.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CalendarPickerController;
@class EKCalendar;

@protocol CalendarPickerDelegate <NSObject>

@required
// calendar == nil on cancel
- (void)calendarPicker:(CalendarPickerController *)calendarPicker didSelectCalendar:(EKCalendar *)calendar;
@end
