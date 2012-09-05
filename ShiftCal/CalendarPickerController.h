//
//  CalendarPickerController.h
//  ShiftCal
//
//  Created by Christian Tietze on 04.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKitUI/EventKitUI.h>
#import "CalendarPickerDelegate.h"

@interface CalendarPickerController : UITableViewController
{
    EKEventStore *_eventStore;
    NSIndexPath *_selectedCellIndexPath;
    
    id<CalendarPickerDelegate> _delegate;
}

@property (nonatomic, retain) EKEventStore *eventStore;
@property (nonatomic, retain) NSIndexPath *selectedCellIndexPath;
@property (weak) id<CalendarPickerDelegate> delegate;

- (id)initWithSelectedCalendar:(EKCalendar *)calendar;
- (id)initWithSelectedCalendar:(EKCalendar *)calendar withStyle:(UITableViewStyle)style;

@end
