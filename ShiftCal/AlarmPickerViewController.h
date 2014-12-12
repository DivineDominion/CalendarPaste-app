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

- (instancetype)initWithAlarmOffset:(NSNumber *)alarmOffset;
- (instancetype)initWithStyle:(UITableViewStyle)style selectedAlarmOffset:(NSNumber *)alarmOffset NS_DESIGNATED_INITIALIZER;
@end
