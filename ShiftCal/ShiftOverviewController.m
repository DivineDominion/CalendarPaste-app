//
//  ShiftOverviewController.m
//  ShiftCal
//
//  Created by Christian Tietze on 26.07.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "ShiftOverviewController.h"
#import "ShiftModificationViewController.h"
#import "ShiftTemplate.h"
#import "NSMutableArray+MoveArray.h"

#define ROW_NONE -1

typedef enum {
    SCModificationNone,
    SCModificationEdit,
    SCModificationAdd
} SCModificationMode;

@interface ShiftOverviewController ()
{
    // private instance variables
    NSMutableArray *_shifts;
    
    SCModificationMode _currentModificationMode;
    NSInteger _editedShiftRow;
}

// private properties
@property (nonatomic, assign) NSMutableArray *shifts;
@property (nonatomic, assign) SCModificationMode currentModificationMode;
@property (nonatomic, assign) NSInteger editedShiftRow;

// private methods
- (void)loadModel;
- (void)calloutCell:(NSIndexPath *)indexPath;
- (void)addAction:(id)sender;
@end

@implementation ShiftOverviewController

@synthesize shifts = _shifts;
@synthesize currentModificationMode = _currentModificationMode;
@synthesize editedShiftRow = _editedShiftRow;

- (id)init
{
    return [self initWithStyle:UITableViewStylePlain];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    if (self)
    {
        self.shifts = [[NSMutableArray alloc] init];
        self.currentModificationMode = SCModificationNone;
        
        [self loadModel];
    }
    
    return self;
}

- (void)loadModel
{
    ShiftTemplate *shift = nil;
    
    for (NSInteger i = 0; i < 5; i++)
    {
        shift = [[ShiftTemplate alloc] init];
        shift.title = [NSString stringWithFormat:@"Test %d", i];
        
        [self.shifts addObject:shift];
        
        [shift release];
    }
}

- (void)dealloc
{
    [self.shifts release];
    
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
    
    return [self.shifts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"shiftcell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    NSInteger row = [indexPath row];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }
    
    ShiftTemplate *shift = [self.shifts objectAtIndex:row];
    cell.textLabel.text = shift.title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSUInteger sourceRow      = [sourceIndexPath row];
    NSUInteger destinationRow = [destinationIndexPath row];
    
    [self.shifts moveObjectFromIndex:sourceRow toIndex:destinationRow];
}

#pragma mark TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger row = [indexPath row];
    ShiftTemplate *shift = [self.shifts objectAtIndex:row];
    
    if (self.editing)
    {
        ShiftModificationViewController *editController = [[ShiftModificationViewController alloc] initWithShift:shift];
        UINavigationController *editNavController = [[UINavigationController alloc] initWithRootViewController:editController];
        
        editController.modificationDelegate = self;
        
        self.currentModificationMode = SCModificationEdit;
        self.editedShiftRow = row;
        
        [[self navigationController] presentModalViewController:editNavController animated:YES];
        
        [editController release];
        [editNavController release];
    }
    else
    {
        // TODO assign shift
        NSLog(@"%@ selected", shift.title);
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
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
        [self.shifts removeObjectAtIndex:row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
}

#pragma mark - manipulating Shifts

- (void)shiftModificationViewController:(ShiftModificationViewController *)shiftAddViewController modifiedShift:(ShiftTemplate *)shift
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (shift)
    {
        if (self.currentModificationMode == SCModificationAdd)
        {
            NSInteger count        = [self.tableView numberOfRowsInSection:0];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count inSection:0];
            
            [self.shifts insertObject:shift atIndex:count];
            
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
        else if (self.currentModificationMode == SCModificationEdit)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.editedShiftRow inSection:0];
            
            [self.shifts replaceObjectAtIndex:self.editedShiftRow withObject:shift];
            
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self calloutCell:indexPath];
        }
        
        self.currentModificationMode = SCModificationNone;
        self.editedShiftRow = ROW_NONE;
    }
}

- (void)calloutCell:(NSIndexPath *)indexPath
{
    [UIView animateWithDuration:0.0
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^void() {
                         [[self.tableView cellForRowAtIndexPath:indexPath] setHighlighted:YES animated:YES];
                     }
                     completion:^(BOOL finished) {
                         [[self.tableView cellForRowAtIndexPath:indexPath] setHighlighted:NO animated:YES];
                     }];
}

#pragma mark - UI Actions

- (void)addAction:(id)sender
{
    ShiftModificationViewController *additionController = [[ShiftModificationViewController alloc] init];
    UINavigationController *additionNavController = [[UINavigationController alloc] initWithRootViewController:additionController];
    
    additionController.modificationDelegate = self;
    self.currentModificationMode = SCModificationAdd;
    
    [[self navigationController] presentModalViewController:additionNavController animated:YES];
    
    [additionController release];
    [additionNavController release];
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
    }
}

@end
