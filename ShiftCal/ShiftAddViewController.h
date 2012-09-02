//
//  ShiftAddController.h
//  ShiftCal
//
//  Created by Christian Tietze on 16.08.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShiftTemplate.h"

#import "DurationPickerDelegate.h"

#import "ShiftAddDelegate.h"

@interface ShiftAddViewController : UITableViewController <UITextViewDelegate, DurationPickerDelegate>
{
    id <ShiftAddDelegate> _additionDelegate;

    ShiftTemplate *_shift;
    UITableView *_tableView;
}

@property (nonatomic, assign) id <ShiftAddDelegate> additionDelegate;
@property (nonatomic, retain) ShiftTemplate *shift;

- (void)save:(id)sender;
- (void)cancel:(id)sender;

@end
