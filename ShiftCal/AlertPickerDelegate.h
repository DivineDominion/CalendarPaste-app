//
//  ReminderDelegate.h
//  ShiftCal
//
//  Created by Christian Tietze on 14.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AlertPickerViewController;

@protocol AlertPickerDelegate <NSObject>

@required
- (void)alertPicker:(AlertPickerViewController *)alertPicker didSelectAlert:(id)alert;
@end
