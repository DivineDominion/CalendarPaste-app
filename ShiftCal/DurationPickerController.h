//
//  DurationSetViewController.h
//  ShiftCal
//
//  Created by Christian Tietze on 31.08.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DurationPickerController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate>
{
    UIView *_mainView;
    UITableView *_tableView;
    UIPickerView *_pickerView;
}

- (void)save:(id)sender;
- (void)cancel:(id)sender;

@end
