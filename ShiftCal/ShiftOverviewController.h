//
//  ShiftOverviewController.h
//  ShiftCal
//
//  Created by Christian Tietze on 26.07.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShiftTemplate.h"
#import "../MBProgressHUD/MBProgressHUD.h"
#import "ShiftAssignmentViewDelegate.h"

@class ModificationCommand;

@interface ShiftOverviewController : UITableViewController <ShiftAssignmentViewDelegate, MBProgressHUDDelegate>

- (void)modificationCommandFinished:(ModificationCommand *)modificationCommand;

- (void)addShiftWithAttributes:(NSDictionary *)shiftAttributes;
- (void)deleteShiftAtRow:(NSInteger)row;
- (void)replaceShiftAtRow:(NSInteger)row withShiftWithAttributes:(NSDictionary *)shiftAttributes;
@end
