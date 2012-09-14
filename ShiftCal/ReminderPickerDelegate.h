//
//  ReminderDelegate.h
//  ShiftCal
//
//  Created by Christian Tietze on 14.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ReminderPickerViewController;

@protocol ReminderPickerDelegate <NSObject>

@required
- (void)reminderPicker:(ReminderPickerViewController *)reminderPicker didSelectReminder:(id)reminder;
@end
