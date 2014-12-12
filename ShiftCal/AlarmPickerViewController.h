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
    __unsafe_unretained id<AlarmPickerDelegate> delegate;
}

@property (nonatomic, unsafe_unretained) id<AlarmPickerDelegate> delegate;

- (id)initWithAlarmOffset:(NSNumber *)alarmOffset;
- (id)initWithStyle:(UITableViewStyle)style selectedAlarmOffset:(NSNumber *)alarmOffset;
@end
