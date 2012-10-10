//
//  ShiftAssignmentViewController.h
//  ShiftCal
//
//  Created by Christian Tietze on 09.10.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ShiftTemplate.h"

@interface ShiftAssignmentViewController : UITableViewController
{
    ShiftTemplate *_shift;
}

@property (nonatomic, retain, readonly) ShiftTemplate *shift;

- (id)initWithShift:(ShiftTemplate *)shift;
- (id)initWithStyle:(UITableViewStyle)style andShift:(ShiftTemplate *)shift;
@end
