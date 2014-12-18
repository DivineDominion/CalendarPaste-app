//
//  SCCalendarCell.h
//  ShiftCal
//
//  Created by Christian Tietze on 18/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kCalendarCellId;

/// Custom Table Cell: prevents auto layout and uses custom checkmarks
@interface SCCalendarCell : UITableViewCell
@property (nonatomic, assign, getter = isChecked) BOOL checked;

+ (instancetype)dequeueReusableCellFromTableView:(UITableView *)tableView;
+ (double)cellHeight;
+ (double)cellWidth;
@end
