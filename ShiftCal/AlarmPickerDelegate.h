//
//  AlarmPickerDelegate.h
//  ShiftCal
//
//  Created by Christian Tietze on 14.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AlarmPickerViewController;

@protocol AlarmPickerDelegate <NSObject>

@required
- (void)alarmPicker:(AlarmPickerViewController *)alarmPicker didSelectAlarm:(id)alarm;
@end
