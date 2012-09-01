//
//  ShiftAddController.m
//  ShiftCal
//
//  Created by Christian Tietze on 16.08.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "ShiftAddViewController.h"
#import "DurationPickerController.h"

#define NUM_SECTIONS 6
#define SECTION_TITLE_LOCATION 0
#define SECTION_DURATION       1
#define SECTION_CALENDAR       2
#define SECTION_REMINDER       3
#define SECTION_URL            4
#define SECTION_NOTES          5

// TODO refactor to NSString constants
#define CELL_TEXT_FIELD @"textfield"
#define CELL_SUBVIEW    @"sub"
#define CELL_TEXT_AREA  @"textarea"


@interface ShiftAddViewController ()

// private methods
- (void)resetTextViewToPlaceholder:(UITextView *)textView;
@end

@implementation ShiftAddViewController

@synthesize shift = _shift;
@synthesize additionDelegate = _additionDelegate;

- (void)loadView
{
    _tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStyleGrouped];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    
    self.view = _tableView;
}

- (void)dealloc
{
    [_tableView setDelegate: nil];
    [_tableView setDataSource: nil];
    [_tableView release];
    
    [super dealloc];
}

#pragma mark - View callbacks

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *saveItem   = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                target:self
                                                                                action:@selector(save:)];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                target:self
                                                                                action:@selector(cancel:)];
    
    self.navigationItem.rightBarButtonItem = saveItem;
    self.navigationItem.leftBarButtonItem  = cancelItem;
    
    [saveItem release];
    [cancelItem release];
    
    // TODO title becomeFirstResponder
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - Table View callbacks

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_TITLE_LOCATION:
            return 2;
        case SECTION_DURATION:
        case SECTION_CALENDAR:
        case SECTION_REMINDER:
        case SECTION_URL:
        case SECTION_NOTES:
            return 1;
        default:
            StupidError(@"section %d not supported", section);
            break;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    
    UITableViewCell *cell = nil;
    
    switch (section) {
        case SECTION_TITLE_LOCATION:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:CELL_TEXT_FIELD];
            
            if (!cell)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                               reuseIdentifier:CELL_TEXT_FIELD] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UITextField *textField     = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 300.0f, 30.0f)];
                textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                textField.adjustsFontSizeToFitWidth = YES;
                
                [cell.contentView addSubview:textField];
                
                [textField release];
            }
            
            UITextField *textField = [[cell.contentView subviews] lastObject];
            textField.clearsOnBeginEditing = NO;
            
            if (row == 0)
            {
                textField.placeholder = @"Title";
            }
            else if (row == 1)
            {
                textField.placeholder = @"Location";
            }
            else {
                StupidError(@"no placeholder for row %d", row);
            }
            
            break;
        }
        case SECTION_DURATION:
            cell = [tableView dequeueReusableCellWithIdentifier:CELL_SUBVIEW];
            
            if (!cell)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                               reuseIdentifier:CELL_SUBVIEW] autorelease];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            cell.textLabel.text = @"Duration";
            cell.detailTextLabel.text = @"1h";
            
            break;
        case SECTION_CALENDAR:
            cell = [tableView dequeueReusableCellWithIdentifier:CELL_SUBVIEW];
            
            if (!cell)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                               reuseIdentifier:CELL_SUBVIEW] autorelease];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            cell.textLabel.text = @"Calendar";
            cell.detailTextLabel.text = @"DEFAULT";

            break;
        case SECTION_REMINDER:
            cell = [tableView dequeueReusableCellWithIdentifier:CELL_SUBVIEW];
            
            if (!cell)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                               reuseIdentifier:CELL_SUBVIEW] autorelease];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            cell.textLabel.text = @"Reminder";
            cell.detailTextLabel.text = @"None";
            
            break;
        case SECTION_URL:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:CELL_TEXT_AREA];
            
            if (!cell)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                               reuseIdentifier:CELL_TEXT_FIELD] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UITextField *textField     = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 300.0f, 30.0f)];
                textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                textField.adjustsFontSizeToFitWidth = YES;
                cell.bounds = CGRectMake(0.0f, 0.0f, 300.0f, 110.0f);
                [cell.contentView addSubview:textField];
                
                [textField release];
            }
            
            UITextField *textField = [[cell.contentView subviews] lastObject];
            textField.clearsOnBeginEditing = NO;
            textField.placeholder = @"URL";
            
            break;
        }
        case SECTION_NOTES:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:CELL_TEXT_AREA];
            
            if (!cell)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:CELL_TEXT_AREA] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(4.0f, 10.0f, 292.0f, 90.0f)];
                textView.contentInset = UIEdgeInsetsMake(-4,0,-4,0);
                textView.backgroundColor = cell.backgroundColor;
                textView.font = [UIFont systemFontOfSize:UIFont.labelFontSize];

                [textView setDelegate:self];
                
                [self resetTextViewToPlaceholder:textView];
                
                [cell.contentView addSubview:textView];
                
                [textView release];
            }
                        
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (SECTION_NOTES == [indexPath section]) {
        return 110.0;
    }
    
    return tableView.rowHeight;
}

#pragma mark - TableView interaction

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    
    switch (section) {
        case SECTION_DURATION:
        {
            DurationPickerController *durationController = [[DurationPickerController alloc] init];
            UINavigationController *durationNavController = [[UINavigationController alloc] initWithRootViewController:durationController];
            
            [[self navigationController] presentModalViewController:durationNavController animated:YES];
            
            [durationController release];
            [durationNavController release];
            break;
        }
        default:
            break;
    }
}


#pragma mark - TextView delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (textView.tag == 0)
    {
        textView.tag       = 1;    // Indicates 'editing'
        textView.text      = @"";
        textView.textColor = [UIColor blackColor];
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([textView.text length] == 0)
    {
        [self resetTextViewToPlaceholder:textView];
    }
    
    return YES;
}

- (void)resetTextViewToPlaceholder:(UITextView *)textView
{
    textView.text      = @"Notes";
    textView.textColor = [UIColor lightGrayColor];
    textView.tag       = 0; // Indicates 'default/placeholder state
}

#pragma mark - Save and Cancel

- (void)save:(id)sender
{
    if (self.additionDelegate) {
        ShiftTemplate *shift = nil;
        
        [self.additionDelegate shiftAddViewController:self didAddShift:shift];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
