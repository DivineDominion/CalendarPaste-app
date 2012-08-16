//
//  ShiftAddController.m
//  ShiftCal
//
//  Created by Christian Tietze on 16.08.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "ShiftAddViewController.h"

@implementation ShiftAddViewController

@synthesize shift = shift_;
@synthesize addDelegate = addDelegate_;

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
    if (section == 0) {
        return 2;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"] autorelease];
        
        if ([indexPath section] == 0)
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 285, 30)]; // 110, 10, 185, 30
            textField.clearsOnBeginEditing = NO;
            //textField.delegate = self;
            
            if ([indexPath row] == 0)
            {
                // TODO textField.tag
                textField.placeholder = @"Title";
            }
            else if ([indexPath row] == 1) {
                // TODO textField.tag
                textField.placeholder = @"Location";
            }
            
            [cell.contentView addSubview:textField];
        }
        else if ([indexPath section] == 1)
        {
            //cell.textLabel.text = @"label";
        }
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
    if (self.addDelegate) {
        ShiftTemplate *shift = nil;
        
        [self.addDelegate shiftAddViewController:self didAddShift:shift];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
