//
//  ShiftOverviewCell.h
//  ShiftCal
//
//  Created by Christian Tietze on 19.10.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShiftTemplate.h"

@class DurationLabel;

typedef NS_ENUM(NSInteger, SCCellLabelWidth) {
    SCCellLabelWidthSmall,
    SCCellLabelWidthWide
};

@interface ShiftOverviewCell : UITableViewCell
@property (nonatomic, strong, readwrite) ShiftTemplate *shift;

+ (float)cellHeight;
- (instancetype)initAndReuseIdentifier:(NSString *)reuseIdentifer;

- (void)compactLabels;
- (void)expandLabels;

+ (void)enableLayoutTwoDigits;
+ (void)disableLayoutTwoDigits;
@end