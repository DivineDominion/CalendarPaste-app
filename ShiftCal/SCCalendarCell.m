//
//  SCCalendarCell.m
//  ShiftCal
//
//  Created by Christian Tietze on 18/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import "SCCalendarCell.h"

NSString * const kCalendarCellId = @"calendarcell";

#define LABEL_TEXT_WIDTH 256.0f
#define LABEL_DETAIL_WIDTH 60.0f
#define CELL_WIDTH 320.0f
#define CELL_HEIGHT 44.0f

@implementation SCCalendarCell

+ (instancetype)dequeueReusableCellFromTableView:(UITableView *)tableView
{
    return [tableView dequeueReusableCellWithIdentifier:kCalendarCellId];
}

+ (double)cellHeight
{
    return CELL_HEIGHT;
}

+ (double)cellWidth
{
    return CELL_WIDTH;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [self init];
    self.frame = frame;
    
    return self;
}

- (instancetype)init
{
    return [self initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCalendarCellId];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.userInteractionEnabled = NO; // Prevents selection
    [button setTintColor:[UIColor colorWithRed:0 green:0.5 blue:1.0 alpha:1.0]];
    self.accessoryView = button;
    
    self.layer.masksToBounds = YES;
    self.detailTextLabel.textAlignment = NSTextAlignmentRight;
    
    return self;
}

- (void)setChecked:(BOOL)checked
{
    if (checked != _checked)
    {
        _checked = checked;
        
        UIImage *imageNormal    = nil;
        UIButton *button = (UIButton *)self.accessoryView;
        
        if (checked == YES)
        {
            imageNormal = [[UIImage imageNamed:@"Checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        
        [button setBackgroundImage:imageNormal forState:UIControlStateNormal];
    }
}

- (void)layoutSubviews {
    static double kCellVisualHeight = CELL_HEIGHT - 1.0f;
    static double kCheckmarkSize    = 14.0f;
    static double kCheckmarkX       = CELL_WIDTH - 10.0f - 14.0f; // - kCheckmarkSize
    static double kMargin           = 10.0f;
    
    [super layoutSubviews];
    
    // TODO replace with @"default" simulated width when drawn
    CGRect textFrame = CGRectMake(10.0f, 0.0f, LABEL_TEXT_WIDTH, kCellVisualHeight);
    
    if (![self.detailTextLabel.text isEqualToString:@" "])
    {
        textFrame.size.width = textFrame.size.width - LABEL_DETAIL_WIDTH - kMargin;
    }
    
    self.textLabel.frame = textFrame;
    self.detailTextLabel.frame = CGRectMake(kCheckmarkX - LABEL_DETAIL_WIDTH - 2 * kMargin, 0.0f, LABEL_DETAIL_WIDTH, kCellVisualHeight);
    
    self.accessoryView.frame = CGRectMake(kCheckmarkX, 15.0f, kCheckmarkSize, kCheckmarkSize);
}
@end