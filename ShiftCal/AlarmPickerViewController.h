//
//  AlarmViewController.h
//  ShiftCal
//
//  Created by Christian Tietze on 14.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlarmPickerDelegate.h"

@interface AlarmPickerViewController : UITableViewController
{
    id<AlarmPickerDelegate> _delegate;
}

@property (nonatomic, weak) id<AlarmPickerDelegate> delegate;

- (id)initWithAlarmOffset:(NSNumber *)alarmOffset;
- (id)initWithStyle:(UITableViewStyle)style selectedAlarmOffset:(NSNumber *)alarmOffset;
@end
