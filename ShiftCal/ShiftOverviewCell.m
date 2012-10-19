//
//  ShiftOverviewCell.m
//  ShiftCal
//
//  Created by Christian Tietze on 19.10.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "ShiftOverviewCell.h"

#define CELL_HEIGHT 52.0f

#define LABEL_WIDTH 40.0f
#define SECOND_LABEL_X LABEL_WIDTH
#define TIME_LABEL_Y 5.0f
#define TIME_LABEL_HEIGHT 30.0f
#define CAPTION_LABEL_Y (TIME_LABEL_Y + TIME_LABEL_HEIGHT - 5.0f)
#define CAPTION_LABEL_HEIGHT 20.0f

@interface DurationLabel : UIView
{
    UILabel *_hoursLabel;
    UILabel *_hoursCaptionLabel;
    UILabel *_minutesLabel;
    UILabel *_minutesCaptionLabel;
}

@property (nonatomic, retain) UILabel *hoursLabel;
@property (nonatomic, retain) UILabel *hoursCaptionLabel;
@property (nonatomic, retain) UILabel *minutesLabel;
@property (nonatomic, retain) UILabel *minutesCaptionLabel;

- (void)setDurationHours:(NSUInteger)hours andMinutes:(NSUInteger)minutes;
@end

@implementation DurationLabel
@synthesize hoursLabel = _hoursLabel;
@synthesize hoursCaptionLabel = _hoursCaptionLabel;
@synthesize minutesLabel = _minutesLabel;
@synthesize minutesCaptionLabel = _minutesCaptionlabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        float leftIndent = 0.0;
        BOOL oneDigitHoursOnly = YES; // TODO find out whether any value has 2 digits
        if (oneDigitHoursOnly)
        {
            leftIndent = 5.0f;
        }
        
        self.hoursLabel   = [self timeLabelWithLeftIndent:leftIndent];
        self.minutesLabel = [self timeLabelWithLeftIndent:SECOND_LABEL_X];
        
        self.hoursCaptionLabel   = [self captionLabel:@"hrs" leftIndent:leftIndent];
        self.minutesCaptionLabel = [self captionLabel:@"min" leftIndent:SECOND_LABEL_X];
        
        [self addSubview:self.hoursLabel];
        [self addSubview:self.hoursCaptionLabel];
        [self addSubview:self.minutesLabel];
        [self addSubview:self.minutesCaptionLabel];
    }
    
    return self;
}

- (UILabel *)timeLabelWithLeftIndent:(float)leftIndent
{
    UILabel *label         = [[UILabel alloc] initWithFrame:CGRectMake(leftIndent, TIME_LABEL_Y, LABEL_WIDTH, TIME_LABEL_HEIGHT)];
    UIFont *durationFont   = [UIFont boldSystemFontOfSize:32.0];
    UIColor *durationColor = [UIColor colorWithRed:128.0/256 green:151.0/256 blue:185.0/256 alpha:1.0];
    
    label.backgroundColor = [UIColor clearColor];
    label.font            = durationFont;
    label.textColor       = durationColor;
    label.textAlignment   = NSTextAlignmentCenter;
    
    return [label autorelease];
}

- (UILabel *)captionLabel:(NSString *)caption leftIndent:(float)leftIndent
{
    UILabel *label      = [[UILabel alloc] initWithFrame:CGRectMake(leftIndent, CAPTION_LABEL_Y, LABEL_WIDTH, CAPTION_LABEL_HEIGHT)];
    UIFont *labelFont   = [UIFont boldSystemFontOfSize:16.0];
    UIColor *labelColor = [UIColor grayColor];
    
    label.backgroundColor = [UIColor clearColor];
    label.font            = labelFont;
    label.textColor       = labelColor;
    label.textAlignment   = NSTextAlignmentCenter;
    
    label.text = caption;
    
    return [label autorelease];
}


- (void)setDurationHours:(NSUInteger)hours andMinutes:(NSUInteger)minutes
{
    self.hoursLabel.text   = [NSString stringWithFormat:@"%d", hours];
    self.minutesLabel.text = [NSString stringWithFormat:@"%02d", minutes];
    
    if (hours == 1)
    {
        self.hoursCaptionLabel.text = @"hr";
    }
    else
    {
        self.hoursCaptionLabel.text = @"hrs";
    }
    
    [self setNeedsLayout]; // TODO call only when 2-digit hours appear/disappear
}

@end

@interface ShiftOverviewCell ()
{
    DurationLabel *_durationLabel;
    UILabel *_calendarLabel;
}

@property (nonatomic, retain) DurationLabel *durationLabel;
@property (nonatomic, retain) UILabel *calendarLabel;

@end

@implementation ShiftOverviewCell

@synthesize shift = _shift;
@synthesize durationLabel = _durationLabel;
@synthesize calendarLabel = _calendarLabel;

- (id)initAndReuseIdentifier:(NSString *)reuseIdentifier
{
    return [self initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.durationLabel = [[[DurationLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0, 80.0f, CELL_HEIGHT)] autorelease];
        
        self.textLabel.font = [UIFont boldSystemFontOfSize:22.0];
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        self.calendarLabel = [[[UILabel alloc] initWithFrame:CGRectMake(215.0f, 0.0, 100.0f, 18.0f)] autorelease];
        self.calendarLabel.textAlignment = NSTextAlignmentRight;
        self.calendarLabel.font = [UIFont boldSystemFontOfSize:12.0];
        self.calendarLabel.textColor = [UIColor colorWithRed:120.0/256 green:120.0/256 blue:170.0/256 alpha:1.0];
        
        [self.contentView addSubview:self.durationLabel];
        [self.contentView addSubview:self.calendarLabel];
    }
    
    return self;
}

- (void)dealloc
{
    [_durationLabel release];
    [_calendarLabel release];
    
    [super dealloc];
}

- (void)setShift:(ShiftTemplate *)shift
{
    if (shift != _shift)
    {
        [_shift release];
        _shift = [shift retain];
        
        self.textLabel.text = shift.title;
        self.detailTextLabel.text = shift.location;
        self.calendarLabel.text = shift.calendarTitle;
        
        [self.durationLabel setDurationHours:[shift.durHours integerValue] andMinutes:[shift.durMinutes integerValue]];
    }
}

- (void)layoutSubviews {
    static double kTextWidth = 200.0f;
    
    [super layoutSubviews];
    
    CGRect textFrame = CGRectMake(100.0f, 8.0f, kTextWidth, 30.0f);
    self.textLabel.frame = textFrame;
    
    CGRect detailFrame = CGRectMake(100.0f, 32.0f, kTextWidth, 18.0f);
    self.detailTextLabel.frame = detailFrame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // TODO Configure the view for the selected state
}

+ (float)cellHeight
{
    return CELL_HEIGHT;
}

@end
