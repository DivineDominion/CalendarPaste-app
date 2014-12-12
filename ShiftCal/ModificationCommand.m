//
//  ModificationCommand.m
//  ShiftCal
//
//  Created by Christian Tietze on 12/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import "ModificationCommand.h"

#import "ShiftOverviewController.h"

@implementation ModificationCommand

- (instancetype)initWithTarget:(ShiftOverviewController *)target;
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
        self.shiftAttributes = [shiftAttributes copy];
        [self execute];
    }
}

- (void)execute
{
    // Do nothing;  override in implementation
}
@end


@implementation EditCommand

- (instancetype)initWithTarget:(ShiftOverviewController *)target forRow:(NSUInteger)row
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
    [self.target updateShiftAtRow:self.row withAttributes:self.shiftAttributes];
    [self.target modificationCommandFinished:self];
}
@end


@implementation AddCommand
- (void)execute
{
    [self.target addShiftWithAttributes:self.shiftAttributes];
    [self.target modificationCommandFinished:self];
}
@end
