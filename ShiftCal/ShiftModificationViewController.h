//
//  ShiftAddController.h
//  ShiftCal
//
//  Created by Christian Tietze on 16.08.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import "ShiftTemplate.h"

#import "DurationPickerDelegate.h"
#import "CalendarPickerDelegate.h"
#import "AlarmPickerDelegate.h"

#import "ShiftModificationDelegate.h"

@interface ShiftModificationViewController : UITableViewController <UITextViewDelegate, UITextFieldDelegate, DurationPickerDelegate, CalendarPickerDelegate, AlarmPickerDelegate>
{
    id<ShiftModificationDelegate> _modificationDelegate;

    ShiftTemplate *_shift;
}

@property (nonatomic, weak) id<ShiftModificationDelegate> modificationDelegate;
@property (nonatomic, retain) ShiftTemplate *shift;

- (id)initWithShift:(ShiftTemplate *)shift;

- (void)save:(id)sender;
- (void)cancel:(id)sender;

@end
