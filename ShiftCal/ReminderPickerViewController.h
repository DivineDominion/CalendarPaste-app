//
//  ReminderViewController.h
//  ShiftCal
//
//  Created by Christian Tietze on 14.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReminderPickerDelegate.h"

@interface ReminderPickerViewController : UITableViewController
{
    id<ReminderPickerDelegate> _delegate;
}

@property (weak) id<ReminderPickerDelegate> delegate;

- (id)initWithReminder:(id)reminder;
- (id)initWithStyle:(UITableViewStyle)style selectedReminder:(id)reminder;
@end
