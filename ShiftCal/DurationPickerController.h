//
//  DurationSetViewController.h
//  ShiftCal
//
//  Created by Christian Tietze on 31.08.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DurationPickerDelegate.h"

@interface DurationPickerController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate>
{
    UIPickerView *_pickerView;
    UIView *_pickerWrap;
    
    NSInteger _hours;
    NSInteger _minutes;
    
    id<DurationPickerDelegate> _delegate;
}

@property (nonatomic, assign) NSInteger hours;
@property (nonatomic, assign) NSInteger minutes;

@property (nonatomic, assign) id<DurationPickerDelegate> delegate;

- (id)initWithHours:(NSInteger)hours andMinutes:(NSInteger)minutes;

- (void)save:(id)sender;
- (void)cancel:(id)sender;

@end
