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
    NSInteger _hours;
    NSInteger _minutes;
    
    id<DurationPickerDelegate> _delegate;
}

@property (nonatomic, assign) NSInteger hours;
@property (nonatomic, assign) NSInteger minutes;

@property (nonatomic, weak) id<DurationPickerDelegate> delegate;

- (id)initWithHours:(NSInteger)hours andMinutes:(NSInteger)minutes;
- (id)initWithHours:(NSInteger)hours andMinutes:(NSInteger)minutes withStyle:(UITableViewStyle)style;

- (void)save:(id)sender;
- (void)cancel:(id)sender;

@end
