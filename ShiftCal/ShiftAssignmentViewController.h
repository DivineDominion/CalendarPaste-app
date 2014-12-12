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
    __unsafe_unretained id<ShiftAssignmentViewDelegate> delegate;
}

@property (nonatomic, strong, readonly) ShiftTemplate *shift;
@property (nonatomic, unsafe_unretained) id<ShiftAssignmentViewDelegate> delegate;

- (instancetype)initWithShift:(ShiftTemplate *)shift shiftTemplateController:(ShiftTemplateController *)shiftTemplateController;
- (instancetype)initWithStyle:(UITableViewStyle)style shift:(ShiftTemplate *)shift shiftTemplateController:(ShiftTemplateController *)shiftTemplateController NS_DESIGNATED_INITIALIZER;

- (void)datePickerChanged:(id)sender;
@end
