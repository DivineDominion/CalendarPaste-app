//
//  ShiftAssignmentViewController.h
//  ShiftCal
//
//  Created by Christian Tietze on 09.10.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ShiftTemplate.h"
#import "ShiftAssignmentViewDelegate.h"
#import "ShiftTemplateController.h"

@interface ShiftAssignmentViewController : UITableViewController
{
    ShiftTemplate *_shift;
    id<ShiftAssignmentViewDelegate> _delegate;
}

@property (nonatomic, retain, readonly) ShiftTemplate *shift;
@property (nonatomic, weak) id<ShiftAssignmentViewDelegate> delegate;

- (id)initWithShift:(ShiftTemplate *)shift shiftTemplateController:(ShiftTemplateController *)shiftTemplateController;
- (id)initWithStyle:(UITableViewStyle)style andShift:(ShiftTemplate *)shift shiftTemplateController:(ShiftTemplateController *)shiftTemplateController;

- (void)datePickerChanged:(id)sender;
@end
