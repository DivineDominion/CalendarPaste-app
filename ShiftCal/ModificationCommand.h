//
//  ModificationCommand.h
//  ShiftCal
//
//  Created by Christian Tietze on 12/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShiftModificationDelegate.h"

@class ShiftOverviewController;

@interface ModificationCommand : NSObject <ShiftModificationDelegate>
@property (nonatomic, weak) ShiftOverviewController *target;
@property (nonatomic, strong) NSDictionary *shiftAttributes;

- (instancetype)initWithTarget:(ShiftOverviewController *)target NS_DESIGNATED_INITIALIZER;
- (void)execute;
@end

@interface EditCommand : ModificationCommand
@property (nonatomic, assign) NSUInteger row;

- (instancetype)initWithTarget:(ShiftOverviewController *)target forRow:(NSUInteger)row NS_DESIGNATED_INITIALIZER;
@end

@interface AddCommand : ModificationCommand
@end
