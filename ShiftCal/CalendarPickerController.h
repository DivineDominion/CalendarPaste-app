//
//  CalendarPickerController.h
//  ShiftCal
//
//  Created by Christian Tietze on 04.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import "UITableViewController+CalloutCell.h"
#import "CalendarPickerDelegate.h"

typedef struct _SCCellSelection {
    NSIndexPath *indexPath;
    NSString    *calendarIdentifier;
} SCCellSelection;

@interface CalendarPickerController : UITableViewController
{
    id<CalendarPickerDelegate> _delegate;
}

@property (weak) id<CalendarPickerDelegate> delegate;

- (id)initWithSelectedCalendarIdentifier:(NSString *)calendarIdentifier;
- (id)initWithSelectedCalendarIdentifier:(NSString *)calendarIdentifier withStyle:(UITableViewStyle)style;

@end
