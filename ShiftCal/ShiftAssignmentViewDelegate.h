//
//  ShiftAssignmentDelegate.h
//  ShiftCal
//
//  Created by Christian Tietze on 10.10.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SCAssignmentViewAction) {
    SCAssignmentViewActionCanceled,
    SCAssignmentViewActionSaved
};

@class ShiftAssignmentViewController;

@protocol ShiftAssignmentViewDelegate <NSObject>

@required
- (void)shiftAssignmentViewController:(ShiftAssignmentViewController *)shiftAssignmentViewController didCompleteWithAction:(SCAssignmentViewAction)action;
@end
