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
@property (nonatomic, strong, readonly) ShiftTemplate *shift;
@property (nonatomic, weak) id<ShiftAssignmentViewDelegate> delegate;

- (instancetype)initWithShift:(ShiftTemplate *)shift shiftTemplateController:(ShiftTemplateController *)shiftTemplateController;
- (instancetype)initWithStyle:(UITableViewStyle)style shift:(ShiftTemplate *)shift shiftTemplateController:(ShiftTemplateController *)shiftTemplateController NS_DESIGNATED_INITIALIZER;

- (void)datePickerChanged:(id)sender;
@end
