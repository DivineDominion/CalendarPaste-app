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

@interface ShiftOverviewCell : UITableViewCell
{
    ShiftTemplate *_shift;
}

@property (nonatomic, retain) ShiftTemplate *shift;

+ (float)cellHeight;
- (id)initAndReuseIdentifier:(NSString *)reuseIdentifer;
@end