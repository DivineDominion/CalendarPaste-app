//
//  DurationPickerDelegate.h
//  ShiftCal
//
//  Created by Christian Tietze on 02.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DurationPickerController;

@protocol DurationPickerDelegate <NSObject>

@required
// (hours == 0 && minutes == 0 && text == nil) on cancel
- (void)durationPicker:(DurationPickerController *)durationPicker didSelectHours:(NSInteger)hours andMinutes:(NSInteger)minutes renderedAs:(NSString *)text;
@end
