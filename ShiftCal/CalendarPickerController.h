//
//  CalendarPickerController.h
//  ShiftCal
//
//  Created by Christian Tietze on 04.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import "CalendarPickerDelegate.h"

@interface CalendarPickerController : UITableViewController
{
    id<CalendarPickerDelegate> _delegate;
}

@property (weak) id<CalendarPickerDelegate> delegate;

- (id)initWithSelectedCalendarIdentifier:(NSString *)calendarIdentifier;
- (id)initWithSelectedCalendarIdentifier:(NSString *)calendarIdentifier withStyle:(UITableViewStyle)style;

@end
