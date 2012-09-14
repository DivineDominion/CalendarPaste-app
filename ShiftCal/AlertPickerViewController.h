//
//  ReminderViewController.h
//  ShiftCal
//
//  Created by Christian Tietze on 14.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlertPickerDelegate.h"

@interface AlertPickerViewController : UITableViewController
{
    id<AlertPickerDelegate> _delegate;
}

@property (weak) id<AlertPickerDelegate> delegate;

- (id)initWithAlert:(id)reminder;
- (id)initWithStyle:(UITableViewStyle)style selectedAlert:(id)alert;
@end
