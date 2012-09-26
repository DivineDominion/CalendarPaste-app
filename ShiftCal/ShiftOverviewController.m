//
//  ShiftOverviewController.m
//  ShiftCal
//
//  Created by Christian Tietze on 26.07.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "ShiftOverviewController.h"
#import "ShiftAddViewController.h"
#import "ShiftTemplate.h"

// via http://www.icab.de/blog/2009/11/15/moving-objects-within-an-nsmutablearray/
@interface NSMutableArray (MoveArray)
- (void)moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)to;
@end

@implementation NSMutableArray (MoveArray)
- (void)moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)to
{
    if (to != from) {
        id obj = [self objectAtIndex:from];
        [obj retain];
        [self removeObjectAtIndex:from];
        if (to >= [self count]) {
            [self addObject:obj];
        } else {
            [self insertObject:obj atIndex:to];
        }
        [obj release];
    }
}
@end

@interface ShiftOverviewController ()
{
    // private instance variables
    NSMutableArray *_shifts;
}

// private properties
@property (nonatomic, assign) NSMutableArray *shifts;

// private methods
- (void)addAction:(id)sender;
@end

@implementation ShiftOverviewController

@synthesize shifts = _shifts;

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
    
    // TODO assign shift
    NSLog(@"%@ selected", shift.title);
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
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

- (void)shiftAddViewController:(ShiftAddViewController *)shiftAddViewController didAddShift:(ShiftTemplate *)shift
{
    if (shift)
    {
        NSInteger count = [self.tableView numberOfRowsInSection:0];;
        count++;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:5 inSection:0];
        
        [self.shifts addObject:shift];
        
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UI Actions

- (void)addAction:(id)sender
{
    ShiftAddViewController *additionController = [[ShiftAddViewController alloc] init];
    UINavigationController *additionNavController = [[UINavigationController alloc] initWithRootViewController:additionController];
    
    additionController.additionDelegate = self;
    
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
