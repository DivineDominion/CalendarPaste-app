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
#import "AlertPickerDelegate.h"

#import "ShiftAddDelegate.h"

@interface ShiftAddViewController : UITableViewController <UITextViewDelegate, UITextFieldDelegate, DurationPickerDelegate, CalendarPickerDelegate, AlertPickerDelegate>
{
    id <ShiftAddDelegate> _additionDelegate;

    ShiftTemplate *_shift;
}

@property (nonatomic, assign) id <ShiftAddDelegate> additionDelegate;
@property (nonatomic, retain) ShiftTemplate *shift;

- (void)save:(id)sender;
- (void)cancel:(id)sender;

@end
