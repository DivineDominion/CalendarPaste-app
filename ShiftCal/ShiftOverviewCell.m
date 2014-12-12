//
//  ShiftOverviewCell.m
//  ShiftCal
//
//  Created by Christian Tietze on 19.10.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "ShiftOverviewCell.h"

#define LABEL_WIDTH 40.0f
#define SECOND_LABEL_X LABEL_WIDTH
#define STD_LEFT_INDENT 5.0f
#define TIME_LABEL_Y 3.0f
#define TIME_LABEL_HEIGHT 30.0f
#define CAPTION_LABEL_Y (TIME_LABEL_Y + TIME_LABEL_HEIGHT - 4.0f)
#define CAPTION_LABEL_HEIGHT 20.0f

#define CALENDAR_TOP_MARGIN_4INCH 2.0f
#define SUBTITLE_TOP_MARGIN_4INCH 7.0f
#define BASELINE_TOP_MARGIN_4INCH 5.0f

BOOL _enableTwoDigits = NO;

@interface DurationLabel : UIView
{
    UILabel *_hoursLabel;
    UILabel *_hoursCaptionLabel;
    UILabel *_minutesLabel;
    UILabel *_minutesCaptionLabel;
    
    BOOL _allDay;
    UILabel *_allDayLabel;
}

@property (nonatomic, strong) UILabel *hoursLabel;
@property (nonatomic, strong) UILabel *hoursCaptionLabel;
@property (nonatomic, strong) UILabel *minutesLabel;
@property (nonatomic, strong) UILabel *minutesCaptionLabel;
@property (nonatomic, assign) BOOL allDay;
@property (nonatomic, strong) UILabel *allDayLabel;

- (void)setDurationHours:(NSUInteger)hours andMinutes:(NSUInteger)minutes;

+ (UILabel *)timeLabelWithLeftIndent:(float)leftIndent;
+ (UILabel *)captionLabel:(NSString *)caption leftIndent:(float)leftIndent;
+ (UILabel *)allDayLabel;

- (void)compact;
- (void)expand;

+ (void)setEnableLayoutTwoDigits:(BOOL)enable;
+ (BOOL)hasTwoDigits;
@end

@implementation DurationLabel
@synthesize hoursLabel = _hoursLabel;
@synthesize hoursCaptionLabel = _hoursCaptionLabel;
@synthesize minutesLabel = _minutesLabel;
@synthesize minutesCaptionLabel = _minutesCaptionlabel;
@synthesize allDay = _allDay;
@synthesize allDayLabel = _allDayLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.allDayLabel = [DurationLabel allDayLabel];
        self.allDayLabel.hidden = YES;
        
        self.hoursLabel   = [DurationLabel timeLabelWithLeftIndent:STD_LEFT_INDENT];
        self.minutesLabel = [DurationLabel timeLabelWithLeftIndent:SECOND_LABEL_X];
        
        self.hoursCaptionLabel   = [DurationLabel captionLabel:@"hrs" leftIndent:STD_LEFT_INDENT];
        self.minutesCaptionLabel = [DurationLabel captionLabel:@"min" leftIndent:SECOND_LABEL_X];
        
        [self addSubview:self.allDayLabel];
        [self addSubview:self.hoursLabel];
        [self addSubview:self.hoursCaptionLabel];
        [self addSubview:self.minutesLabel];
        [self addSubview:self.minutesCaptionLabel];
    }
    
    return self;
}

- (void)setAllDay:(BOOL)allDay
{
    if (_allDay == allDay)
    {
        return;
    }
    
    self.hoursLabel.hidden = allDay;
    self.minutesLabel.hidden = allDay;
    self.hoursCaptionLabel.hidden = allDay;
    self.minutesCaptionLabel.hidden = allDay;
    
    self.allDayLabel.hidden = !allDay;
    
    _allDay = allDay;
}

- (void)setDurationHours:(NSUInteger)hours andMinutes:(NSUInteger)minutes
{
    self.hoursLabel.text   = [NSString stringWithFormat:@"%lu", (unsigned long)hours];
    self.minutesLabel.text = [NSString stringWithFormat:@"%02lu", (unsigned long)minutes];
    
    if (hours == 1)
    {
        self.hoursCaptionLabel.text = @"hr";
    }
    else
    {
        self.hoursCaptionLabel.text = @"hrs";
    }
}

+ (UILabel *)timeLabelWithLeftIndent:(float)leftIndent
{
    float timeLabelY = TIME_LABEL_Y;
    if (IS_4INCH_DISPLAY)
    {
        timeLabelY += BASELINE_TOP_MARGIN_4INCH;
    }
    
    UILabel *label         = [[UILabel alloc] initWithFrame:CGRectMake(leftIndent, timeLabelY, LABEL_WIDTH, TIME_LABEL_HEIGHT)];
    UIFont *durationFont   = [UIFont fontWithName:@"HelveticaNeue-Light" size:32.0];
    UIColor *durationColor = [UIColor colorWithRed:128.0/256 green:151.0/256 blue:185.0/256 alpha:1.0];
    
    label.backgroundColor = [UIColor clearColor];
    label.font            = durationFont;
    label.textColor       = durationColor;
    label.textAlignment   = NSTextAlignmentCenter;
    
    return label;
}

+ (UILabel *)captionLabel:(NSString *)caption leftIndent:(float)leftIndent
{
    float captionLabelY = CAPTION_LABEL_Y;
    if (IS_4INCH_DISPLAY)
    {
        captionLabelY += SUBTITLE_TOP_MARGIN_4INCH;
    }
    
    UILabel *label      = [[UILabel alloc] initWithFrame:CGRectMake(leftIndent, captionLabelY, LABEL_WIDTH, CAPTION_LABEL_HEIGHT)];
    UIFont *labelFont   = [UIFont systemFontOfSize:16.0];
    UIColor *labelColor = [UIColor grayColor];
    
    label.backgroundColor = [UIColor clearColor];
    label.font            = labelFont;
    label.textColor       = labelColor;
    label.textAlignment   = NSTextAlignmentCenter;
    
    label.text = caption;
    
    return label;
}

+ (UILabel *)allDayLabel
{
    CGRect frame = CGRectMake(0, 0, (STD_LEFT_INDENT + 2 * LABEL_WIDTH), (CAPTION_LABEL_Y + CAPTION_LABEL_HEIGHT));
    
    if (IS_4INCH_DISPLAY)
    {
        frame.size.height += SUBTITLE_TOP_MARGIN_4INCH;
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];

    UILabel *timeLabel = [DurationLabel timeLabelWithLeftIndent:STD_LEFT_INDENT];
    frame = timeLabel.frame;
    frame.size.width = (2 * LABEL_WIDTH);
    frame.size.height = frame.size.height + 3.0f;
    timeLabel.frame = frame;
    
    UIFont *labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:32.0];
    timeLabel.font = labelFont;
    
    timeLabel.text = @"all";
    
    UILabel *captionLabel = [DurationLabel captionLabel:@"day" leftIndent:STD_LEFT_INDENT];
    frame = captionLabel.frame;
    frame.size.width = (2 * LABEL_WIDTH);
    captionLabel.frame = frame;
    
    [label addSubview:timeLabel];
    [label addSubview:captionLabel];
    
    return label;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    float leftOffset = 0.0;
    if ([DurationLabel hasTwoDigits])
    {
        leftOffset = 5.0f;
    }

    [self reframeMinuteLabelsUsingOffset:leftOffset];
}

- (void)compact
{
    // Nudge second label to the left again
    [UIView animateWithDuration:0.5f animations:^{
        [self reframeMinuteLabelsUsingOffset:0.0f];
    }];
}

- (void)expand
{
    // Nudge second label to the right when hours become wider
    [UIView animateWithDuration:0.5f animations:^{
        [self reframeMinuteLabelsUsingOffset:5.0f];
    }];
}

- (void)reframeMinuteLabelsUsingOffset:(float)leftOffset
{
    CGRect minutesLabelFrame = self.minutesLabel.frame;
    minutesLabelFrame.origin.x = SECOND_LABEL_X + leftOffset;
    self.minutesLabel.frame = minutesLabelFrame;
    
    CGRect minutesCaptionLabelFrame = self.minutesCaptionLabel.frame;
    minutesCaptionLabelFrame.origin.x = SECOND_LABEL_X + leftOffset;
    self.minutesCaptionLabel.frame = minutesCaptionLabelFrame;
}

+ (BOOL)hasTwoDigits
{
    return _enableTwoDigits;
}

+ (void)setEnableLayoutTwoDigits:(BOOL)enable
{
    _enableTwoDigits = enable;
}

@end

@interface ShiftOverviewCell ()
{
    DurationLabel *_durationLabel;
    UILabel *_calendarLabel;
}

@property (nonatomic, strong) DurationLabel *durationLabel;
@property (nonatomic, strong) UILabel *calendarLabel;

@end

@implementation ShiftOverviewCell

@synthesize shift = _shift;
@synthesize durationLabel = _durationLabel;
@synthesize calendarLabel = _calendarLabel;

+ (void)enableLayoutTwoDigits
{
    [DurationLabel setEnableLayoutTwoDigits:YES];
}

+ (void)disableLayoutTwoDigits
{
    [DurationLabel setEnableLayoutTwoDigits:NO];
}

- (void)compactLabels
{
    [self.durationLabel compact];
}

- (void)expandLabels
{
    [self.durationLabel expand];
}

- (id)initAndReuseIdentifier:(NSString *)reuseIdentifier
{
    return [self initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {      
        self.durationLabel = [[DurationLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 80.0f, [ShiftOverviewCell cellHeight])];
        
        UIView *highlightView = [[UIView alloc] init];
        highlightView.backgroundColor = [UIColor colorWithRed:245.0/255 green:251.0/255 blue:190.0/255 alpha:1.0];
        self.selectedBackgroundView = highlightView;
        
        self.textLabel.font = [UIFont systemFontOfSize:22.0];
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        if (IS_4INCH_DISPLAY)
        {
            self.detailTextLabel.font = [UIFont systemFontOfSize:16.0];
        }
        self.detailTextLabel.textColor = [UIColor grayColor];
        
        self.calendarLabel = [[UILabel alloc] initWithFrame:CGRectMake(215.0f, 0.0f, 100.0f, 18.0f)];
        self.calendarLabel.backgroundColor = [UIColor clearColor];
        self.calendarLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.calendarLabel.textAlignment = NSTextAlignmentRight;
        self.calendarLabel.font = [UIFont boldSystemFontOfSize:12.0];
        self.calendarLabel.textColor = [UIColor colorWithRed:120.0/256 green:120.0/256 blue:170.0/256 alpha:1.0];
        
        [self.contentView addSubview:self.durationLabel];
        [self.contentView addSubview:self.calendarLabel];
    }
    
    return self;
}

- (void)setShift:(ShiftTemplate *)shift
{
    _shift = shift;
    
    self.textLabel.text = [shift onScreenTitle];
    self.detailTextLabel.text = shift.location;
    self.calendarLabel.text = shift.calendarTitle;
    
    self.durationLabel.allDay = [shift isAllDay];
    [self.durationLabel setDurationHours:[shift.durHours integerValue] andMinutes:[shift.durMinutes integerValue]];
}

- (void)layoutSubviews {
    static double kTextWidth = 210.0f;
    static double kTextWidthShort = 150.0f;
    
    double currentTextWidth = kTextWidth;
    
    [super layoutSubviews];
    
    if (self.editing)
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.calendarLabel.alpha = 0.0;
            self.detailTextLabel.alpha = 0.0;
        }];
        
        currentTextWidth = kTextWidthShort;
    }
    else
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.calendarLabel.alpha = 1.0;
            self.detailTextLabel.alpha = 1.0;
        }];
    }
    
    // Override default frame
    float textLabelYOffset   = -1.0f;
    float detailLabelYOffset = -2.0f;
    if (IS_4INCH_DISPLAY)
    {
        textLabelYOffset   += BASELINE_TOP_MARGIN_4INCH;
        detailLabelYOffset += SUBTITLE_TOP_MARGIN_4INCH;
        
        CGRect frame = self.calendarLabel.frame;
        frame.origin.y = CALENDAR_TOP_MARGIN_4INCH;
        self.calendarLabel.frame = frame;
    }
    
    self.textLabel.frame       = CGRectMake(100.0f,  8.0f + textLabelYOffset,   currentTextWidth, 30.0f);
    self.detailTextLabel.frame = CGRectMake(100.0f, 32.0f + detailLabelYOffset, currentTextWidth, 18.0f);
}

+ (float)cellHeight
{
    return ([[UIScreen mainScreen] bounds].size.height - 64.0f) / 8;
}

@end
