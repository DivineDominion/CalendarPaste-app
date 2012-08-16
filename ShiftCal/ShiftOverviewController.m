//
//  ShiftOverviewController.m
//  ShiftCal
//
//  Created by Christian Tietze on 26.07.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "ShiftOverviewController.h"
#import "ShiftAddViewController.h"

@interface ShiftOverviewController ()

// forward declarations
- (void)addAction:(id)sender;

@end

@implementation ShiftOverviewController

- (void)dealloc
{
    [self.view release];
    [super dealloc];
}

- (void)loadView
{
    // Never use same view objects with multiple controllers! -> copy?
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // Navigation Bar:
    // ---------------------
    // [Edit]  TITLE     [+]
    // ---------------------
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                             target:self
                                                                             action:@selector(addAction:)];
    self.navigationItem.leftBarButtonItem  = [self editButtonItem];
    self.navigationItem.rightBarButtonItem = addItem;
    
    [addItem release];
    
    self.title = @"Shifts";
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


#pragma mark - UI Actions

- (void)addAction:(id)sender
{
    ShiftAddViewController *addController = [[ShiftAddViewController alloc] init];
    UINavigationController *addNavController = [[UINavigationController alloc] initWithRootViewController:addController];
    
    [[self navigationController] presentModalViewController:addNavController animated:YES];
    
    [addController release];
    [addNavController release];
}

@end
