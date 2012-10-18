//
//  ShiftOverviewController.m
//  ShiftCal
//
//  Created by Christian Tietze on 26.07.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "ShiftOverviewController.h"

#import "ShiftModificationViewController.h"
#import "ShiftModificationDelegate.h"

#import "ShiftAssignmentViewController.h"

#import "ShiftTemplateCollection.h"
#import "ShiftTemplate.h"

@interface ModificationCommand : NSObject <ShiftModificationDelegate>
{
    ShiftOverviewController *_target;
    NSDictionary *_shiftAttributes;
}

@property (nonatomic, weak) ShiftOverviewController *target;
@property (nonatomic, retain) NSDictionary *shiftAttributes;

- (id)initWithTarget:(ShiftOverviewController *)target;
- (void)execute;
@end


@implementation ModificationCommand

@synthesize shiftAttributes = _shiftAttributes;
@synthesize target = _target;

- (id)initWithTarget:(ShiftOverviewController *)target;
{
    self = [super init];
    
    if (self)
    {
        self.target = target;
    }
    
    return self;
}

- (void)shiftModificationViewController:(ShiftModificationViewController *)shiftAddViewController modifiedShiftAttributes:(NSDictionary *)shiftAttributes
{
    [self.target dismissViewControllerAnimated:YES completion:nil]; // TODO refactor high coupling
    
    if (shiftAttributes)
    {
        self.shiftAttributes = shiftAttributes;
        [self execute];
    }
}

- (void)execute
{
    // Do nothing;  override in implementation
}
@end

@interface EditCommand : ModificationCommand
{
    NSUInteger _row;
}

@property (nonatomic, assign) NSUInteger row;

-(id)initWithTarget:(ShiftOverviewController *)target forRow:(NSUInteger)row;
@end

@implementation EditCommand
@synthesize row = _row;

- (id)initWithTarget:(ShiftOverviewController *)target forRow:(NSUInteger)row
{
    self = [super initWithTarget:target];
    
    if (self)
    {
        self.row = row;
    }
    
    return self;
}

- (void)execute
{
    [self.target replaceShiftAtRow:self.row withShiftWithAttributes:self.shiftAttributes];
    [self.target modificationCommandFinished:self];
}
@end

@interface AddCommand : ModificationCommand
@end

@implementation AddCommand
- (void)execute
{
    [self.target addShiftWithAttributs:self.shiftAttributes];
    [self.target modificationCommandFinished:self];
}
@end

#pragma mark - ShiftOverviewCell

#define CELL_HEIGHT 52.0f

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
        float bottomMargin = frame.size.height - 2.0f;
        
        UIFont *durationFont   = [UIFont boldSystemFontOfSize:30.0];
        UIColor *durationColor = [UIColor colorWithRed:128.0/256 green:151.0/256 blue:185.0/256 alpha:1.0];
        
        UIFont *labelFont   = [UIFont boldSystemFontOfSize:16.0];
        UIColor *labelColor = [UIColor darkGrayColor];
        
        self.hoursLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 5.0, 40.0, 30.0)] autorelease];
        self.hoursLabel.backgroundColor = [UIColor clearColor];
        self.hoursLabel.font = durationFont;
        self.hoursLabel.textColor = durationColor;
        self.hoursLabel.textAlignment = NSTextAlignmentCenter;
        
        self.hoursCaptionLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.hoursCaptionLabel.backgroundColor = [UIColor clearColor];
        self.hoursCaptionLabel.font = labelFont;
        self.hoursCaptionLabel.textColor = labelColor;
        self.hoursCaptionLabel.textAlignment = NSTextAlignmentCenter;
        self.hoursCaptionLabel.text = @"hrs";
        [self.hoursCaptionLabel sizeToFit];
        CGRect hoursCaptionFrame = CGRectMake(0.0, 0.0, 40.0, 0.0);
        hoursCaptionFrame.size.height = self.hoursCaptionLabel.bounds.size.height;
        hoursCaptionFrame.origin.y = bottomMargin - self.hoursCaptionLabel.bounds.size.height;
        self.hoursCaptionLabel.frame = hoursCaptionFrame;
        
        self.minutesLabel = [[[UILabel alloc] initWithFrame:CGRectMake(40.0, 5.0, 40.0, 30.0)] autorelease];
        self.minutesLabel.backgroundColor = [UIColor clearColor];
        self.minutesLabel.font = durationFont;
        self.minutesLabel.textColor = durationColor;
        self.minutesLabel.textAlignment = NSTextAlignmentCenter;
        
        self.minutesCaptionLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.minutesCaptionLabel.backgroundColor = [UIColor clearColor];
        self.minutesCaptionLabel.font = labelFont;
        self.minutesCaptionLabel.textColor = labelColor;
        self.minutesCaptionLabel.textAlignment = NSTextAlignmentCenter;
        self.minutesCaptionLabel.text = @"min";
        [self.minutesCaptionLabel sizeToFit];
        CGRect minutesCaptionFrame = CGRectMake(40.0, 0.0, 40.0, 0.0);
        minutesCaptionFrame.size.height = self.minutesCaptionLabel.bounds.size.height;
        minutesCaptionFrame.origin.y = bottomMargin - self.minutesCaptionLabel.bounds.size.height;;
        self.minutesCaptionLabel.frame = minutesCaptionFrame;
        
        [self addSubview:self.hoursLabel];
        [self addSubview:self.hoursCaptionLabel];
        [self addSubview:self.minutesLabel];
        [self addSubview:self.minutesCaptionLabel];
    }
    
    return self;
}

- (void)setDurationHours:(NSUInteger)hours andMinutes:(NSUInteger)minutes
{
    self.hoursLabel.text = [NSString stringWithFormat:@"%d", hours];
    if (hours == 1)
    {
        self.hoursCaptionLabel.text = @"hr";
    }
    else
    {
        self.hoursCaptionLabel.text = @"hrs";
    }
    
    self.minutesLabel.text = [NSString stringWithFormat:@"%02d", minutes];
    self.minutesCaptionLabel.text = @"min";
    
    [self setNeedsLayout];
}

@end

@interface ShiftOverviewCell : UITableViewCell
{
    ShiftTemplate *_shift;
    DurationLabel *_durationLabel;
    UILabel *_calendarLabel;
}

@property (nonatomic, retain) ShiftTemplate *shift;
@property (nonatomic, retain) DurationLabel *durationLabel;
@property (nonatomic, retain) UILabel *calendarLabel;

- (id)initAndReuseIdentifier:(NSString *)cellIdentifier;
@end

@implementation ShiftOverviewCell

@synthesize shift = _shift;
@synthesize durationLabel = _durationLabel;
@synthesize calendarLabel = _calendarLabel;

- (id)initAndReuseIdentifier:(NSString *)cellIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    if (self)
    {
        self.durationLabel = [[[DurationLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0, 80.0f, CELL_HEIGHT)] autorelease];
        
        self.calendarLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
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
    static double kCellVisualHeight = CELL_HEIGHT - 1.0f;
    static double kTextWidth        = 200.0f;
    
    [super layoutSubviews];
    
    CGRect textFrame = CGRectMake(90.0f, 0.0f, kTextWidth, kCellVisualHeight);
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.frame = textFrame;
    
    CGRect detailFrame = CGRectMake(90.0f, 34.0f, kTextWidth, 18.0f);
    self.detailTextLabel.frame = detailFrame;
    
    //CGRect durationFrame = CGRectMake(0.0f, 0.0, 80.0f, CELL_HEIGHT);
    //self.durationLabel.frame = durationFrame;
    
    CGRect calendarFrame = CGRectMake(100.0f, 0.0, 210.0f, 18.0f);
    self.calendarLabel.frame = calendarFrame;
}

@end

#pragma mark - ShiftOverviewController

@interface ShiftOverviewController ()
{
    // private instance variables
    ModificationCommand *_modificationCommand;
    ShiftTemplateCollection *_shiftCollection;
}

// private properties
@property (nonatomic, retain) ModificationCommand *modificationCommand;
@property (nonatomic, retain) ShiftTemplateCollection *shiftCollection;

// private methods
- (void)calloutCell:(NSIndexPath *)indexPath;
- (void)addAction:(id)sender;
- (void)showHud;
@end

@implementation ShiftOverviewController
@synthesize modificationCommand = _modificationCommand;
@synthesize shiftCollection = _shiftCollection;

- (id)init
{
    return [self initWithStyle:UITableViewStylePlain];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    if (self)
    {
        self.shiftCollection = [[[ShiftTemplateCollection alloc] init] autorelease];
    }
    
    return self;
}

- (void)dealloc
{
    [_modificationCommand release];
    [_shiftCollection release];
    
    [super dealloc];
}

#pragma mark - View callbacks

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Navigation Bar:
    // ---------------------
    // [Edit]  TITLE     [+]
    // ---------------------
    
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                   target:self
                                                                                   action:@selector(addAction:)];
    self.navigationItem.leftBarButtonItem  = [self editButtonItem];
    self.navigationItem.rightBarButtonItem = addButtonItem;
    
    [addButtonItem release];
    
    self.title = @"Shifts";
    
    self.tableView.allowsSelectionDuringEditing = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - TableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section != 0)
    {
        StupidError(@"only one section allowed:  section=%d", section);
    }
    
    return [self.shiftCollection countOfShifts];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"shiftcell";
    
    ShiftOverviewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    NSInteger row = [indexPath row];
    
    if (!cell)
    {
        cell = [[ShiftOverviewCell alloc] initAndReuseIdentifier:kCellIdentifier];
    }
    
    ShiftTemplate *shift = [self.shiftCollection shiftAtIndex:row];
    cell.shift = shift;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSUInteger sourceRow      = [sourceIndexPath row];
    NSUInteger destinationRow = [destinationIndexPath row];
    
    [self.shiftCollection moveObjectFromIndex:sourceRow toIndex:destinationRow];
}

#pragma mark TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger row = [indexPath row];
    ShiftTemplate *shift = [self.shiftCollection shiftAtIndex:row];
    
    if (self.editing)
    {
        EditCommand *editCommand = [[EditCommand alloc] initWithTarget:self forRow:row];
        self.modificationCommand = editCommand;
        
        [self presentModificationViewControllerWithShift:shift];
        
        [editCommand release];
    }
    else
    {
        ShiftAssignmentViewController *assignController = [[ShiftAssignmentViewController alloc] initWithShift:shift];
        
        assignController.delegate = self;
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:assignController];
        
        [self presentViewController:navigationController animated:YES completion:nil];
        
        [assignController release];
        [navigationController release];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];

    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.shiftCollection removeShiftAtIndex:row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
}

#pragma mark - Presented Views

- (void)presentModificationViewController
{
    [self presentModificationViewControllerWithShift:nil];
}

- (void)presentModificationViewControllerWithShift:(ShiftTemplate *)shift
{
    ShiftModificationViewController *modificationController = [[ShiftModificationViewController alloc] initWithShift:shift];//shiftAttributes];
        
    UINavigationController *modificationNavController = [[UINavigationController alloc] initWithRootViewController:modificationController];
    
    modificationController.modificationDelegate = self.modificationCommand;
    
    [[self navigationController] presentViewController:modificationNavController animated:YES completion:nil];
    
    [modificationController release];
    [modificationNavController release];
}

#pragma mark ShiftAssignmentViewController callbacks

- (void)shiftAssignmentViewController:(ShiftAssignmentViewController *)shiftAssignmentViewController didCompleteWithAction:(SCAssignmentViewAction)action
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (action == SCAssignmentViewActionSaved)
    {
        [self showHud];
    }
}

- (void)showHud
{
    // To center vertically, select navigationController.view instead of self.view
    UIView *parentView = self.navigationController.view;
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:parentView];
    [parentView addSubview:hud];
    
    hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hud-checkmark.png"]] autorelease];
    hud.mode       = MBProgressHUDModeCustomView;
    hud.delegate   = self;
    
    [hud show:YES];
    [hud hide:YES afterDelay:0.4];
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
    [hud release];
}

#pragma mark ShiftModificationController callbacks

- (void)modificationCommandFinished:(ModificationCommand *)modificationCommand
{
    if (modificationCommand == self.modificationCommand)
    {
        self.modificationCommand = nil;
    }
}

- (void)addShiftWithAttributs:(NSDictionary *)shiftAttributes
{
    // TODO refactor into notification
    NSInteger row = [self.shiftCollection addShiftWithAttributs:shiftAttributes];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)replaceShiftAtRow:(NSInteger)row withShiftWithAttributes:(NSDictionary *)shiftAttributes
{
    [self.shiftCollection replaceShiftAtIndex:row withShiftWithAttributs:shiftAttributes];

    // TODO refactor into notifications
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self calloutCell:indexPath];
}

- (void)calloutCell:(NSIndexPath *)indexPath
{
    ShiftOverviewController *__unsafe_unretained weakSelf = self;
    [UIView animateWithDuration:0.0
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^void() {
                         [[weakSelf.tableView cellForRowAtIndexPath:indexPath] setHighlighted:YES animated:YES];
                     }
                     completion:^(BOOL finished) {
                         [[weakSelf.tableView cellForRowAtIndexPath:indexPath] setHighlighted:NO animated:YES];
                     }];
}

#pragma mark - UI Actions

- (void)addAction:(id)sender
{
    AddCommand *addCommand = [[AddCommand alloc] initWithTarget:self];
    self.modificationCommand = addCommand;
    
    [self presentModificationViewController];
    
    [addCommand release];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    
    UIBarButtonItem *addButton = self.navigationItem.rightBarButtonItem;
    
    if (editing)
    {
        addButton.enabled = NO;
    }
    else
    {
        addButton.enabled = YES;
        
        [self.shiftCollection persistOrder];
    }
}

@end
