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

@interface CalendarPickerController : UITableViewController
@property (unsafe_unretained) id<CalendarPickerDelegate> delegate;

- (instancetype)initWithSelectedCalendarIdentifier:(NSString *)calendarIdentifier;
- (instancetype)initWithSelectedCalendarIdentifier:(NSString *)calendarIdentifier withStyle:(UITableViewStyle)style NS_DESIGNATED_INITIALIZER;

@end
