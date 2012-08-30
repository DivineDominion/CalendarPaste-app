//
//  ShiftAddController.m
//  ShiftCal
//
//  Created by Christian Tietze on 16.08.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "ShiftAddViewController.h"

#define SECTION_TITLE_LOCATION 0

// TODO refactor to     
#define CELL_TEXT_FIELD @"textfield"
#define CELL_SUB_VIEW   @"sub"
#define CELL_TEXT_AREA  @"textarea"

@implementation ShiftAddViewController

@synthesize shift = shift_;
@synthesize additionDelegate = additionDelegate_;

- (void)loadView
{
    //ShiftAddView *view = [[ShiftAddView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UITableView *view = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStyleGrouped];
    view.delegate = self;
    view.dataSource = self;
    self.view = view;
    
    [view release];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_TITLE_LOCATION:
            return 2;
            break;
            
        default:
            break;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    
    UITableViewCell *cell;
    
    switch (section) {
        case SECTION_TITLE_LOCATION:
            cell = [tableView dequeueReusableCellWithIdentifier:CELL_TEXT_FIELD];
            
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                               reuseIdentifier:CELL_TEXT_FIELD] autorelease];
                
                //20.0f, 40.0f, 280.0f, 30.0f
                UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 285, 30)]; // 110, 10, 185, 30
                [cell.contentView addSubview:textField];
                [textField release];
            }
            
            UITextField *textField = [[cell.contentView subviews] lastObject];
            textField.clearsOnBeginEditing = NO;
            //textField.delegate = self; // TODO implement delegate methods
            
            if (row == 0) {
                textField.placeholder = @"Title";
            }
            else if (row == 1)
            {
                textField.placeholder = @"Location";
            }
            else {
                // TODO throw StupidError
            }
            
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    // TODO add subview
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
