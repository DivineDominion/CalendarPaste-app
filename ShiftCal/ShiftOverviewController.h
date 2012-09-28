//
//  ShiftOverviewController.h
//  ShiftCal
//
//  Created by Christian Tietze on 26.07.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShiftTemplate.h"

@class ModificationCommand;

@interface ShiftOverviewController : UITableViewController

- (void)modificationCommandFinished:(ModificationCommand *)modificationCommand;

- (void)addShift:(ShiftTemplate *)shift;
- (void)replaceShiftAtRow:(NSInteger)row withShift:(ShiftTemplate *)shift;
@end
